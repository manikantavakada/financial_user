import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:financial_user/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:encrypt/encrypt.dart' show RSAKeyParser;
import 'package:shared_preferences/shared_preferences.dart';

import 'bg.dart';
import 'installation_tracker.dart';

// RSA encryption function (unchanged)
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  String _error = '';
  String _emailError = '';
  String _passwordError = '';
  bool _showPassword = false;
  String _phoneNumber = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.easeOutQuart),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.easeOutQuart),
    ));

    _animationController.forward();

    // Auto-login if already logged in
    _checkLoginStatus();
  }

  // Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = (prefs.getString('access_token') ?? '').trim();
    final clientId = prefs.getInt('client_id') ?? -1;
    debugPrint('Auto-login check: token present=${accessToken.isNotEmpty}, tokenPreview=${_maskToken(accessToken)}, client_id=$clientId');

    if (accessToken.isNotEmpty) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
      _emailError = _phoneNumber.isEmpty && _emailController.text.trim().isEmpty
          ? 'Phone number is required'
          : '';
      
      final password = _passwordController.text.trim();
      if (password.isEmpty) {
        _passwordError = 'Password is required';
      } else if (password.length < 5) {
        // ✅ Changed: Accept any type, minimum 5 characters
        _passwordError = 'Password must be at least 5 characters';
      } else {
        _passwordError = '';
      }
      isValid = _emailError.isEmpty && _passwordError.isEmpty;
    });
    return isValid;
  }

  Future<void> handleLogin() async {
    if (!validateForm()) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final String username = _phoneNumber.isNotEmpty
        ? _phoneNumber
        : _emailController.text.trim();

    // Encrypt password
    final rawPassword = _passwordController.text.trim();
    final String encryptedPassword = encryptPasswordRSA(rawPassword, serverPublicKeyPem);

    // Log key debug info (DO NOT log raw password)
    debugPrint('--- LOGIN ATTEMPT ---');
    debugPrint('username: $username');
    debugPrint('encryptedPassword (len): ${encryptedPassword.length}');
    debugPrint('encryptedPassword preview: ${encryptedPassword.length > 10 ? encryptedPassword.substring(0,6) + "..." : encryptedPassword}');

    final url = Uri.parse('https://ds.singledeck.in/api/v1/clients/client-login/');
    const String fcmToken = 'staticfcm1234567890';

    final body = {
      "username": username,
      "password": encryptedPassword,
      "fcm_token": fcmToken,
    };

    // Show request payload (without raw password)
    debugPrint('POST $url');
    debugPrint('Request body keys: ${body.keys.toList()}');
    debugPrint('Request body (json): ${jsonEncode(body)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 60));

      debugPrint('--- LOGIN RESPONSE ---');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      // Defensive JSON parse
      Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Failed to parse JSON: $e');
        _showError('Invalid response from server');
        return;
      }

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        // Defensive extraction
        final session = jsonResponse['session_token'];
        final userData = jsonResponse['user'] as Map<String, dynamic>?;

        if (session == null || userData == null) {
          debugPrint('Login success but missing session or user in response');
          _showError('Login response missing data');
          return;
        }

        String accessToken = '';
        String refreshToken = '';

        try {
          accessToken = (session['access'] as String).trim();
          refreshToken = (session['refresh'] as String).trim();
        } catch (_) {
          debugPrint('session token fields missing or unexpected structure: $session');
          _showError('Invalid session token from server');
          return;
        }

        // Defensive: avoid double "Bearer " if backend returns it already
        if (accessToken.toLowerCase().startsWith('bearer ')) {
          accessToken = accessToken.substring(7).trim();
          debugPrint('Trimmed leading "Bearer " from access token');
        }

        // Save to prefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        await prefs.setString('user_data', jsonEncode(userData));
        final int clientId = (userData['clnt_id'] is int)
            ? userData['clnt_id']
            : int.tryParse('${userData['clnt_id']}') ?? 0;
        await prefs.setInt('client_id', clientId);
        await prefs.setBool('is_logged_in', true);

        // Log what's saved (masked)
        debugPrint('Saved to prefs: access_token=${_maskToken(accessToken)}, refresh_token=${_maskToken(refreshToken)}, client_id=$clientId');
        final decoded = _decodeJwtPayload(accessToken);
        debugPrint('access token payload (decoded): $decoded');

        try {
          await InstallationTracker.trackInstallation(clientId);
          debugPrint('✅ Installation tracked successfully for client_id: $clientId');
        } catch (e) {
          debugPrint('⚠️ Installation tracking failed (non-blocking): $e');
          // Don't block login if tracking fails
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Welcome back!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // If API sends structured error
        final errorMsg = jsonResponse['message'] ??
            jsonResponse['error'] ??
            jsonResponse['detail'] ??
            'Invalid phone number or password';
        debugPrint('Login failed: $errorMsg');
        _showError(errorMsg);
      }
    } on TimeoutException {
      debugPrint('Login request timed out');
      _showError('No internet connection or server is slow');
    } on SocketException catch (e) {
      debugPrint('SocketException during login: $e');
      _showError('No internet connection');
    } on FormatException catch (e) {
      debugPrint('FormatException during login: $e');
      _showError('Invalid response from server');
    } catch (e, st) {
      debugPrint('Unexpected login error: $e');
      debugPrint('Stack: $st');
      _showError('Something went wrong. Please try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              height: size.height * 0.45,
              color: AppColors.primaryDark,
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: size.height * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: EdgeInsets.all(scaleWidth(20)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/Polar_FavIcon.png',
                              width: scaleWidth(60),
                              height: scaleWidth(60),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: scaleHeight(20)),
                        
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: scaleFont(32),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: scaleHeight(8)),
                              Text(
                                'Sign in to your account',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: scaleFont(16),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

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
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_error.isNotEmpty) _buildErrorCard(),

                            Text(
                              'Phone Number',
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
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: IntlPhoneField(
                                decoration: InputDecoration(
                                  hintText: 'Enter phone number',
                                  hintStyle: TextStyle(
                                    fontSize: scaleFont(14),
                                    color: Colors.grey.shade400,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
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
                                  counterText: '',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: scaleWidth(16),
                                    vertical: scaleHeight(16),
                                  ),
                                ),
                                initialCountryCode: 'IN',
                                showCountryFlag: true,
                                showDropdownIcon: false,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: scaleFont(14),
                                  color: Colors.black87,
                                ),
                                onChanged: (phone) {
                                  setState(() {
                                    _phoneNumber = phone.number;
                                  });
                                },
                              ),
                            ),

                            if (_emailError.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: scaleHeight(8), left: scaleWidth(4)),
                                child: Text(
                                  _emailError,
                                  style: TextStyle(fontSize: scaleFont(12), color: Colors.red[600]),
                                ),
                              ),

                            SizedBox(height: scaleHeight(24)),

                            Text(
                              'Password',
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
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                keyboardType: TextInputType.text, // ✅ Changed to text
                                style: TextStyle(fontSize: scaleFont(14), color: Colors.black87),
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(fontSize: scaleFont(14), color: Colors.grey.shade400),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(() => _showPassword = !_showPassword),
                                    child: Container(
                                      margin: EdgeInsets.all(scaleWidth(8)),
                                      padding: EdgeInsets.all(scaleWidth(8)),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryDark.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _showPassword ? Icons.visibility : Icons.visibility_off,
                                        size: scaleFont(18),
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primaryDark, width: 2)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: scaleWidth(16), vertical: scaleHeight(16)),
                                ),
                              ),
                            ),

                            if (_passwordError.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: scaleHeight(8), left: scaleWidth(4)),
                                child: Text(
                                  _passwordError,
                                  style: TextStyle(fontSize: scaleFont(12), color: Colors.red[600]),
                                ),
                              ),

                            SizedBox(height: scaleHeight(20)),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) => setState(() => _rememberMe = value!),
                                        activeColor: AppColors.primaryDark,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                    ),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(fontSize: scaleFont(14), color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/forgot_password'),
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: scaleFont(14),
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: scaleHeight(32)),

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
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: _isLoading ? null : handleLogin,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? SizedBox(
                                            width: scaleWidth(24),
                                            height: scaleWidth(24),
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                          )
                                        : Text(
                                            'Sign In',
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

                  SizedBox(height: scaleHeight(24)),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: scaleFont(14), color: Colors.grey[600]),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register'),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: scaleFont(14),
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

String _maskToken(String? token) {
  if (token == null || token.isEmpty) return '<null>';
  final t = token.trim();
  if (!t.contains('.')) return t.length <= 10 ? t : '${t.substring(0,6)}...${t.substring(t.length-4)}';
  // JWT-like mask: show start and end
  final parts = t.split('.');
  final start = parts[0].length > 6 ? parts[0].substring(0, 6) : parts[0];
  final end = parts[2].length > 6 ? parts[2].substring(parts[2].length - 6) : parts[2];
  return '$start...$end';
}

// Decode JWT payload (safe debug)
Map<String, dynamic>? _decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    String normalize(String str) {
      var output = str.replaceAll('-', '+').replaceAll('_', '/');
      switch (output.length % 4) {
        case 0:
          break;
        case 2:
          output += '==';
          break;
        case 3:
          output += '=';
          break;
        default:
          return '';
      }
      return output;
    }

    final payload = base64Url.decode(normalize(parts[1]));
    final payloadMap = json.decode(utf8.decode(payload)) as Map<String, dynamic>;
    return payloadMap;
  } catch (e) {
    debugPrint('JWT decode failed: $e');
    return null;
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
