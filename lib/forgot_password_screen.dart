import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'color_constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String _error = '';
  String _emailError = '';
  bool _emailSent = false;

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
    _emailController.dispose();
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
      final email = _emailController.text.trim();
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      
      if (email.isEmpty) {
        _emailError = 'Email is required';
      } else if (!emailRegex.hasMatch(email)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = '';
      }

      isValid = _emailError.isEmpty;
    });
    return isValid;
  }

  Future<void> handleForgotPassword() async {
    if (!validateForm()) return;

    setState(() {
      _isLoading = true;
      _error = '';
      _emailSent = false;
    });

    try {
      final url = Uri.parse('${baseUrl}clients/client-forget-password/');

      final body = {
        'email': _emailController.text.trim(),
      };

      debugPrint('📤 Forgot password request for: ${_emailController.text.trim()}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        setState(() {
          _emailSent = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? 'Password sent to your email!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        final errorMsg = data['message'] ?? 
            data['error'] ?? 
            'Failed to send reset link';
        _showError(errorMsg);
      }
    } on TimeoutException {
      _showError('Request timed out. Please try again');
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
              height: size.height * 0.40,
              color: AppColors.primaryDark,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    height: size.height * 0.30,
                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
                    child: Column(
                      children: [
                        SizedBox(height: scaleHeight(20)),
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
                        SizedBox(height: scaleHeight(30)),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(scaleWidth(20)),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lock_reset,
                                  size: scaleWidth(50),
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: scaleHeight(5)),
                              Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: scaleFont(32),
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
                        child: _emailSent
                            ? _buildSuccessContent()
                            : _buildFormContent(),
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

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error.isNotEmpty) _buildErrorCard(),

        // Email Field
        Text(
          'Email Address',
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
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            style: TextStyle(fontSize: scaleFont(14), color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(
                fontSize: scaleFont(14),
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: Container(
                margin: EdgeInsets.all(scaleWidth(8)),
                padding: EdgeInsets.all(scaleWidth(8)),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: scaleFont(18),
                  color: AppColors.primaryDark,
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
        if (_emailError.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: scaleHeight(8), left: scaleWidth(4)),
            child: Text(
              _emailError,
              style: TextStyle(fontSize: scaleFont(12), color: Colors.red[600]),
            ),
          ),

        SizedBox(height: scaleHeight(12)),

        // Info Card
        Container(
          padding: EdgeInsets.all(scaleWidth(12)),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[700],
                size: scaleFont(18),
              ),
              SizedBox(width: scaleWidth(12)),
              Expanded(
                child: Text(
                  'We will send your password to your registered email address',
                  style: TextStyle(
                    fontSize: scaleFont(12),
                    color: Colors.blue[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: scaleHeight(32)),

        // Send Reset Link Button
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
              onTap: _isLoading ? null : handleForgotPassword,
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
                        'Send Password',
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

        SizedBox(height: scaleHeight(20)),

        // Back to Login
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back,
                  size: scaleFont(16),
                  color: AppColors.primaryDark,
                ),
                SizedBox(width: scaleWidth(8)),
                Text(
                  'Back to Login',
                  style: TextStyle(
                    fontSize: scaleFont(14),
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(scaleWidth(20)),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read,
            size: scaleWidth(60),
            color: Colors.green[600],
          ),
        ),
        SizedBox(height: scaleHeight(24)),
        Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: scaleFont(24),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        SizedBox(height: scaleHeight(12)),
        Text(
          'We have sent  password to',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: scaleFont(14),
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: scaleHeight(8)),
        Text(
          _emailController.text.trim(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: scaleFont(15),
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        SizedBox(height: scaleHeight(24)),
        Container(
          padding: EdgeInsets.all(scaleWidth(16)),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.blue[700],
                size: scaleFont(20),
              ),
              SizedBox(height: scaleHeight(8)),
              Text(
                'Please check your email and Login with your New password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: scaleFont(13),
                  color: Colors.blue[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: scaleHeight(32)),
        Container(
          width: double.infinity,
          height: scaleHeight(56),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pop(context),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                    fontSize: scaleFont(16),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: scaleHeight(16)),
        GestureDetector(
          onTap: () {
            setState(() {
              _emailSent = false;
              _emailController.clear();
            });
          },
          child: Text(
            'Didn\'t receive the email? Try again',
            style: TextStyle(
              fontSize: scaleFont(14),
              color: Colors.grey[600],
              decoration: TextDecoration.underline,
            ),
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
