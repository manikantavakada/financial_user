import 'dart:convert';
import 'package:financial_user/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:encrypt/encrypt.dart' show RSAKeyParser;
import 'package:shared_preferences/shared_preferences.dart';

import 'bg.dart';

// RSA encryption function (unchanged)
const String serverPublicKeyPem = """
-----BEGIN PUBLIC KEY-----
\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC9ITaISnuVTdhWW0008bVKqwMF\nEkxBB4dA0svzCuQMmRXCZ9EFP8PL4VVqsju3lNdcpgRa8MzwCPRJ932+M7d6WNPz\nfHoF/nK85//sVQdHCj0rF5PDfvTGOnDeYvN/cdI/cnqQCsSb5ThqO/lr5w+hPuPq\nri1okYc3yE2cWaYHSQIDAQAB\n
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Responsive scaling functions
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
      } else if (!RegExp(r'^\d{5,8}$').hasMatch(password)) {
        _passwordError = 'Password must be 5-8 digits';
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

    String encryptedPassword = encryptPasswordRSA(
      _passwordController.text.trim(),
      serverPublicKeyPem,
    );

    final url = Uri.parse(
      'https://ds.singledeck.in/api/v1/clients/client-login/',
    );
    const String fcmToken = 'staticfcm1234567890';

    final body = {
      "username": _phoneNumber.isNotEmpty
          ? _phoneNumber
          : _emailController.text.trim(),
      "password": encryptedPassword,
      "fcm_token": fcmToken,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        String accessToken = json['session_token']?['access'] ?? '';
        String refreshToken = json['session_token']?['refresh'] ?? '';
        Map<String, dynamic> userMap = json['user'] ?? {};

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('access_token', accessToken);
        prefs.setString('refresh_token', refreshToken);
        prefs.setString('user', jsonEncode(userMap));
        prefs.setInt('client_id', json['user']?['clnt_id'] ?? 0);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        String errorMsg = 'Login failed';
        try {
          final json = jsonDecode(response.body);
          errorMsg = json['message']?.toString() ?? response.body;
        } catch (_) {
          errorMsg = response.body;
        }

        if (mounted) {
          setState(() {
            _error = errorMsg;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = "Network error: $e";
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Curved Header with Gradient
          ClipPath(
            clipper: HeaderClipper(),
            child: Container(
              height: size.height * 0.45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Content
                  Container(
                    height: size.height * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with Animation
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
                        
                        // Welcome Text with Animation
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

                  // Login Form Card with Animation
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

                            // Phone Field
                            Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: scaleFont(16),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
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
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                  counterText: '',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: scaleWidth(16),
                                    vertical: scaleHeight(16),
                                  ),
                                ),
                                initialCountryCode: 'AU',
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
                                padding: EdgeInsets.only(
                                  top: scaleHeight(8),
                                  left: scaleWidth(4),
                                ),
                                child: Text(
                                  _emailError,
                                  style: TextStyle(
                                    fontSize: scaleFont(12),
                                    color: Colors.red[600],
                                  ),
                                ),
                              ),

                            SizedBox(height: scaleHeight(24)),

                            // Password Field
                            Text(
                              'Password',
                              style: TextStyle(
                                fontSize: scaleFont(16),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
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
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: scaleFont(14),
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(
                                    fontSize: scaleFont(14),
                                    color: Colors.grey.shade400,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(
                                      () => _showPassword = !_showPassword,
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(scaleWidth(8)),
                                      padding: EdgeInsets.all(scaleWidth(8)),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _showPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: scaleFont(18),
                                        color: primaryColor,
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
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: scaleWidth(16),
                                    vertical: scaleHeight(16),
                                  ),
                                ),
                              ),
                            ),

                            if (_passwordError.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: scaleHeight(8),
                                  left: scaleWidth(4),
                                ),
                                child: Text(
                                  _passwordError,
                                  style: TextStyle(
                                    fontSize: scaleFont(12),
                                    color: Colors.red[600],
                                  ),
                                ),
                              ),

                            SizedBox(height: scaleHeight(20)),

                            // Remember me and Forgot password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) =>
                                            setState(() => _rememberMe = value!),
                                        activeColor: primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        fontSize: scaleFont(14),
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: scaleFont(14),
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: scaleHeight(32)),

                            // Login Button
                            Container(
                              width: double.infinity,
                              height: scaleHeight(56),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
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
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
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

                  // Register link with Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: scaleFont(14),
                            color: Colors.grey[600],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: scaleFont(14),
                              color: primaryColor,
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
              style: TextStyle(
                fontSize: scaleFont(14),
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for curved header
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    
    // Create a smooth curve
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
