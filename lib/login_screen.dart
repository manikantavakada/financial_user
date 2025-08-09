import 'dart:convert';
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

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  String _error = '';
  String _emailError = '';
  String _passwordError = '';
  bool _showPassword = false;
  String _phoneNumber = '';

  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  bool validateForm() {
    bool isValid = true;
    setState(() {
      _emailError = _phoneNumber.isEmpty && _emailController.text.trim().isEmpty
          ? 'Phone number is required'
          : '';
      // if (_phoneNumber.isNotEmpty ) {
      //   _emailError = 'Phone number is required';
      // }
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

    final url = Uri.parse('https://ss.singledeck.in/api/v1/clients/client-login/');
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
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Gradient for input field borders
    const gradient = LinearGradient(
      colors: [
        Color(0xFF169060),
        Color(0xFF175B58),
        Color(0xFF19214F),
      ],
      stops: [0.30, 0.70, 1],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Apply common background
          const Bg(),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * 0.02,
                        bottom: height * 0.02,
                      ),
                      child: Image.asset(
                        'assets/Polar_logo.png',
                        width: height * 0.18,
                        height: height * 0.18,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: scaleFont(28),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    if (_error.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: height * 0.02),
                        child: Text(
                          _error,
                          style: TextStyle(
                            fontSize: scaleFont(14),
                            color: Colors.red,
                          ),
                        ),
                      ),
                    // Phone number field with gradient border
                    Container(
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IntlPhoneField(
                          decoration: InputDecoration(
                            hintText: 'Phone number',
                            hintStyle: TextStyle(fontSize: scaleFont(16)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            counterText: '', // Hide character counter
                          ),
                          initialCountryCode: 'AU',
                          showCountryFlag: true, // Show country flag
                          showDropdownIcon: false, // Hide dropdown
                          keyboardType: TextInputType.number,
                          
                          onChanged: (phone) {
                            setState(() {
                              _phoneNumber = phone.number; // Capture raw number
                            });
                          },
                          validator: (phone) {
                            if (phone == null || phone.number.isEmpty) {
                              return 'Phone number is required';
                            }
                            // if (!RegExp(r'^04\d{8}$').hasMatch(phone.number)) {
                            //   return 'Australian numbers must be 04 followed by 8 digits';
                            // }
                            return null;
                          },
                        ),
                      ),
                    ),
                    if (_emailError.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 0, bottom: height * 0.02),
                        child: Text(
                          _emailError,
                          style: TextStyle(
                            fontSize: scaleFont(12),
                            color: Colors.red,
                          ),
                        ),
                      ),
                    SizedBox(height: height * 0.02), // Margin between fields
                    // Password field with gradient border
                    Container(
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(fontSize: scaleFont(16)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                              ),
                              obscureText: !_showPassword,
                              keyboardType: TextInputType.number,
                            ),
                            Positioned(
                              right: 10,
                              top: height * 0.02,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _showPassword = !_showPassword),
                                child: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: scaleFont(20),
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_passwordError.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 0, bottom: height * 0.02),
                        child: Text(
                          _passwordError,
                          style: TextStyle(
                            fontSize: scaleFont(12),
                            color: Colors.red,
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(bottom: height * 0.03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) =>
                                    setState(() => _rememberMe = value!),
                              ),
                              Text(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: scaleFont(14),
                                  color: const Color(0xFF666666),
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
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: width * 0.85,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.025,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _isLoading ? 'Logging in...' : 'Log In',
                          style: TextStyle(
                            fontSize: scaleFont(16),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: scaleFont(14),
                            color: const Color(0xFF666666),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: Text(
                            'Register now!',
                            style: TextStyle(
                              fontSize: scaleFont(15),
                              color: const Color(0xFF00A962),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF169060)),
                    const SizedBox(height: 10),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: scaleFont(16),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}