import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

// --- RSA utility imports ----
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:encrypt/encrypt.dart' show RSAKeyParser;
import 'package:shared_preferences/shared_preferences.dart';

// ---- Place your server's PEM public key here ----
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

  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  bool validateForm() {
    bool isValid = true;
    setState(() {
      _emailError = _emailController.text.trim().isEmpty
          ? 'Email is required'
          : '';
      _passwordError = _passwordController.text.trim().isEmpty
          ? 'Password is required'
          : '';
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

    // Encrypt the password using the RSA utility function
    String encryptedPassword = encryptPasswordRSA(
      _passwordController.text.trim(),
      serverPublicKeyPem,
    );

    final url = Uri.parse(
      'https://ss.singledeck.in/api/v1/clients/client-login/',
    );
    const String fcmToken = 'staticfcm1234567890';

    final body = {
      "username": _emailController.text.trim(),
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
        // Parse the JSON response
        final json = jsonDecode(response.body);

        // Extract tokens & user details
        String accessToken = json['session_token']?['access'] ?? '';
        String refreshToken = json['session_token']?['refresh'] ?? '';
        Map<String, dynamic> userMap = json['user'] ?? {};

        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        prefs.setString('access_token', accessToken);
        prefs.setString('refresh_token', refreshToken);
        prefs.setString(
          'user',
          jsonEncode(userMap),
        ); // Store user as JSON string
        prefs.setInt('client_id', json['user']?['clnt_id'] ?? 0);

        // Optional: Show snackbar or toast
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Error feedback
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

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
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
                        'assets/Polar_logo.png', // <-- update the path as needed
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
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email / Phone number',
                        hintStyle: TextStyle(fontSize: scaleFont(16)),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFD3D3D3)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFD3D3D3)),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
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
                    Stack(
                      children: [
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(fontSize: scaleFont(16)),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFD3D3D3)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFD3D3D3)),
                            ),
                          ),
                          obscureText: !_showPassword,
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
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF169060),
                            Color(0xFF175B58),
                            Color(0xFF19214F),
                          ],
                          stops: [0.30, 0.70, 1],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
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
