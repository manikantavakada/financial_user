import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:encrypt/encrypt.dart' show RSAKeyParser;
import 'color_constants.dart';

// RSA encryption (same as login)
const String serverPublicKeyPem = """
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC9ITaISnuVTdhWW0008bVKqwMF
EkxBB4dA0svzCuQMmRXCZ9EFP8PL4VVqsju3lNdcpgRa8MzwCPRJ932+M7d6WNPz
fHoF/nK85//sVQdHCj0rF5PDfvTGOnDeYvN/cdI/cnqQCsSb5ThqO/lr5w+hPuPq
ri1okYc3yE2cWaYHSQIDAQAB
-----END PUBLIC KEY-----
""";

String encryptPasswordRSA(String password, String publicKeyPem) {
  final publicKey = RSAKeyParser().parse(publicKeyPem) as RSAPublicKey;
  final encrypter = Encrypter(
    RSA(publicKey: publicKey, encoding: RSAEncoding.PKCS1),
  );
  final encrypted = encrypter.encrypt(password);
  return base64.encode(encrypted.bytes);
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with TickerProviderStateMixin {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  String _error = '';
  String _oldPasswordError = '';
  String _newPasswordError = '';
  String _confirmPasswordError = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final String baseUrl = 'https://ds.singledeck.in/api/v1/';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuart),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuart),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  double scaleWidth(double width) {
    return width * MediaQuery.of(context).size.width / 375;
  }

  double scaleHeight(double height) {
    return height * MediaQuery.of(context).size.height / 812;
  }

  bool validateForm() {
    bool isValid = true;
    setState(() {
      // Old password validation
      final oldPassword = _oldPasswordController.text.trim();
      if (oldPassword.isEmpty) {
        _oldPasswordError = 'Current password is required';
      } else if (oldPassword.length < 6) {
        _oldPasswordError = 'Password must be at least 6 characters';
      } else {
        _oldPasswordError = '';
      }

      // New password validation
      final newPassword = _newPasswordController.text.trim();
      if (newPassword.isEmpty) {
        _newPasswordError = 'New password is required';
      } else if (newPassword.length < 8) {
        _newPasswordError = 'Password must be at least 8 characters';
      } else if (newPassword == oldPassword) {
        _newPasswordError = 'New password must be different from current';
      } else {
        _newPasswordError = '';
      }

      // Confirm password validation
      final confirmPassword = _confirmPasswordController.text.trim();
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Please confirm your new password';
      } else if (confirmPassword != newPassword) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = '';
      }

      isValid = _oldPasswordError.isEmpty &&
          _newPasswordError.isEmpty &&
          _confirmPasswordError.isEmpty;
    });
    return isValid;
  }

  Future<void> handleChangePassword() async {
    if (!validateForm()) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('Please login again');
      }

      // Encrypt passwords
      final oldPasswordEncrypted = encryptPasswordRSA(
        _oldPasswordController.text.trim(),
        serverPublicKeyPem,
      );
      final newPasswordEncrypted = encryptPasswordRSA(
        _newPasswordController.text.trim(),
        serverPublicKeyPem,
      );

      final url = Uri.parse('${baseUrl}clients/change_password/');

      final body = {
        'old_password': oldPasswordEncrypted,
        'new_password': newPasswordEncrypted,
      };

      debugPrint('📤 Changing password');
      debugPrint('URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'sessiontype': 'CLNT',
          'sessiontoken': token.trim(),
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 120)); // ✅ Increased timeout to 60 seconds

      debugPrint('Response: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 401) {
        await prefs.clear();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Password changed successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final errorMsg = data['message'] ?? 
            data['error'] ?? 
            'Failed to change password';
        _showError(errorMsg);
      }
    } on TimeoutException {
      _showError('Request timed out. Please check your internet connection');
    } on http.ClientException {
      _showError('Network error. Please check your internet connection');
    } catch (e) {
      debugPrint('Error: $e');
      _showError('Something went wrong. Please try again');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() => _error = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Curved Header
          ClipPath(
            clipper: HeaderClipper(),
            child: Container(
              height: size.height * 0.37,
              color: AppColors.primaryDark,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    height: size.height * 0.25,
                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(10)),
                    child: Column(
                      children: [
                        SizedBox(height: scaleHeight(5)),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(scaleWidth(8)),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: scaleFont(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: scaleHeight(5)),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(scaleWidth(16)),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lock_reset,
                                  size: scaleWidth(40),
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: scaleHeight(16)),
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: scaleFont(28),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form Card
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
                        padding: EdgeInsets.all(scaleWidth(32)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_error.isNotEmpty) _buildErrorCard(),

                            // Current Password
                            _buildPasswordField(
                              controller: _oldPasswordController,
                              label: 'Current Password',
                              hint: 'Enter current password',
                              error: _oldPasswordError,
                              showPassword: _showOldPassword,
                              onToggle: () => setState(() => _showOldPassword = !_showOldPassword),
                            ),

                            SizedBox(height: scaleHeight(24)),

                            // New Password
                            _buildPasswordField(
                              controller: _newPasswordController,
                              label: 'New Password',
                              hint: 'Enter new password',
                              error: _newPasswordError,
                              showPassword: _showNewPassword,
                              onToggle: () => setState(() => _showNewPassword = !_showNewPassword),
                            ),

                            SizedBox(height: scaleHeight(24)),

                            // Confirm Password
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              label: 'Confirm New Password',
                              hint: 'Re-enter new password',
                              error: _confirmPasswordError,
                              showPassword: _showConfirmPassword,
                              onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                            ),

                            SizedBox(height: scaleHeight(12)),

                            // Password Requirements
                            Container(
                              padding: EdgeInsets.all(scaleWidth(12)),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue[700],
                                    size: scaleFont(18),
                                  ),
                                  SizedBox(width: scaleWidth(12)),
                                  Expanded(
                                    child: Text(
                                      'Password must be at least 8 characters',
                                      style: TextStyle(
                                        fontSize: scaleFont(12),
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: scaleHeight(32)),

                            // Change Password Button
                            Container(
                              width: double.infinity,
                              height: scaleHeight(56),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryDark.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: _isLoading ? null : handleChangePassword,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? SizedBox(
                                            width: scaleWidth(24),
                                            height: scaleWidth(24),
                                            child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : Text(
                                            'Change Password',
                                            style: TextStyle(
                                              fontSize: scaleFont(18),
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: scaleHeight(40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String error,
    required bool showPassword,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: scaleFont(16),
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        SizedBox(height: scaleHeight(8)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: !showPassword,
            keyboardType: TextInputType.text, // ✅ Changed to text (any type)
            style: TextStyle(fontSize: scaleFont(14), color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: scaleFont(14),
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Container(
                  margin: EdgeInsets.all(scaleWidth(8)),
                  padding: EdgeInsets.all(scaleWidth(8)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                    size: scaleFont(18),
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: scaleWidth(16),
                vertical: scaleHeight(16),
              ),
            ),
          ),
        ),
        if (error.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: scaleHeight(8), left: scaleWidth(4)),
            child: Text(
              error,
              style: TextStyle(fontSize: scaleFont(12), color: Colors.red[600]),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: EdgeInsets.only(bottom: scaleHeight(20)),
      padding: EdgeInsets.all(scaleWidth(16)),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: scaleFont(20)),
          SizedBox(width: scaleWidth(12)),
          Expanded(
            child: Text(
              _error,
              style: TextStyle(fontSize: scaleFont(14), color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
