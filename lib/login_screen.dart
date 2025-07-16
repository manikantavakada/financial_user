<<<<<<< HEAD
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/api.dart' hide Padding;
import 'package:pointycastle/export.dart' as crypto;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import 'package:asn1lib/asn1lib.dart';
=======
import 'package:flutter/material.dart';
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316

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

<<<<<<< HEAD
  final String baseUrl =
      'https://ss.singledeck.in/api/v1/'; // Replace with your actual base URL

  // RSA Public Key
  static const String rsaPublicKey = '''-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC9ITaISnuVTdhWW0008bVKqwMF
EkxBB4dA0svzCuQMmRXCZ9EFP8PL4VVqsju3lNdcpgRa8MzwCPRJ932+M7d6WNPz
fHoF/nK85//sVQdHCj0rF5PDfvTGOnDeYvN/cdI/cnqQCsSb5ThqO/lr5w+hPuPq
ri1okYc3yE2cWaYHSQIDAQAB
-----END PUBLIC KEY-----''';

=======
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  bool validateForm() {
    bool isValid = true;
    setState(() {
<<<<<<< HEAD
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      _emailError = _emailController.text.trim().isEmpty
          ? 'Email is required'
          : !emailRegex.hasMatch(_emailController.text)
          ? 'Valid email required'
          : '';
      _passwordError = _passwordController.text.trim().isEmpty
          ? 'Password is required'
          : '';
=======
      _emailError = _emailController.text.trim().isEmpty ? 'Email is required' : '';
      _passwordError = _passwordController.text.trim().isEmpty ? 'Password is required' : '';
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
      isValid = _emailError.isEmpty && _passwordError.isEmpty;
    });
    return isValid;
  }

<<<<<<< HEAD
  // Parse PEM public key
  crypto.RSAPublicKey parsePublicKeyFromPem(String pem) {
    final key = pem
        .replaceAll('-----BEGIN PUBLIC KEY-----', '')
        .replaceAll('-----END PUBLIC KEY-----', '')
        .replaceAll('\n', '')
        .trim();
    final keyBytes = base64.decode(key);
    final parser = ASN1Parser(keyBytes);
    final topLevelSeq = parser.nextObject() as ASN1Sequence;

    // The second element is the BIT STRING which contains the actual RSA key
    final bitString = topLevelSeq.elements[1] as ASN1BitString;

    // Parse the content of the BIT STRING
    final publicKeyAsn = ASN1Parser(bitString.stringValue as Uint8List);
    final publicKeySeq = publicKeyAsn.nextObject() as ASN1Sequence;

    final modulus =
        (publicKeySeq.elements[0] as ASN1Integer).valueAsBigInteger!;
    final exponent =
        (publicKeySeq.elements[1] as ASN1Integer).valueAsBigInteger!;

    return crypto.RSAPublicKey(modulus, exponent);
  }

  // Encrypt password using RSA
  String encryptPassword(String password) {
    final publicKey = parsePublicKeyFromPem(rsaPublicKey);
    final cipher = RSAEngine()
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    final plainText = utf8.encode(password);
    final encrypted = cipher.process(plainText);
    return base64.encode(encrypted);
  }

  Future<void> handleLogin() async {
    // if (!validateForm()) return;
=======
  // Mock login with static data
  Future<void> handleLogin() async {
    //if (!validateForm()) return;
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316

    // setState(() {
    //   _isLoading = true;
    //   _error = '';
    // });

<<<<<<< HEAD
    // try {
    //   final plainPassword = _passwordController.text.trim();
    //   final encryptedPassword = encryptPassword(plainPassword);

    //   // 🔍 Debug prints
    //   print('Plain password: $plainPassword');
    //   print('Encrypted password (base64): $encryptedPassword');

    //   final fcmToken =
    //       'xxxxxxxxxxxxxxx'; // Replace with actual token if you have it

    //   final response = await http.post(
    //     Uri.parse('${baseUrl}clients/client-login/'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode({
    //       'email': _emailController.text.trim(),
    //       'password': encryptedPassword,
    //       'fcm_token': fcmToken,
    //     }),
    //   );

    //   print('Login Response: ${response.statusCode} - ${response.body}');

    //   if (response.statusCode == 200 || response.statusCode == 201) {
    //     final responseData = jsonDecode(response.body);
    //     if (responseData['status'] == 'success') {
    //       final prefs = await SharedPreferences.getInstance();
    //       await prefs.setString(
    //         'access_token',
    //         responseData['session_token']['access'],
    //       );
    //       await prefs.setString(
    //         'refresh_token',
    //         responseData['session_token']['refresh'],
    //       );
    //       await prefs.setInt('clnt_id', responseData['user']['clnt_id']);
    //       await prefs.setString(
    //         'clnt_full_name',
    //         responseData['user']['clnt_full_name'],
    //       );
    //       await prefs.setString(
    //         'clnt_email',
    //         responseData['user']['clnt_email'],
    //       );
    //       await prefs.setBool('remember_me', _rememberMe);

    //       Navigator.pushReplacementNamed(context, '/home');
    //     } else {
    //       setState(() {
    //         _error =
    //             'Login failed: ${responseData['message'] ?? 'Unknown error'}';
    //       });
    //     }
    //   } else {
    //     String errorMessage = 'Login failed: Status ${response.statusCode}';
    //     try {
    //       final errorData = jsonDecode(response.body);
    //       errorMessage =
    //           'Login failed: ${errorData['message'] ?? response.body}';
    //     } catch (e) {
    //       errorMessage =
    //           'Login failed: Invalid response format (${response.body.substring(0, response.body.length > 50 ? 50 : response.body.length)}...)';
    //     }
    //     setState(() {
    //       _error = errorMessage;
    //     });
    //   }
    // } catch (e) {
    //   setState(() {
    //     _error = 'Error during login: $e';
    //   });
    //   print('Login Exception: $e');
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
=======
    //await Future.delayed(const Duration(seconds: 1));
    // if (_emailController.text == "a" && _passwordController.text == "a") {
    //   Navigator.pushReplacementNamed(context, '/home');
    // } else {
    //   setState(() {
    //     _error = 'Invalid credentials';
    //   });
    // }
    // setState(() {
    //   _isLoading = false;
    // });
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
    Navigator.pushReplacementNamed(context, '/home');
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
                    Container(
                      padding: const EdgeInsets.all(5),
<<<<<<< HEAD
                      decoration: const BoxDecoration(color: Color(0xFF242C57)),
=======
                      decoration: const BoxDecoration(
                        color: Color(0xFF242C57),
                      ),
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Financial',
                              style: TextStyle(
                                fontSize: scaleFont(20),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: height * 0.03,
                              vertical: height * 0.01,
                            ),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
<<<<<<< HEAD
                                colors: [
                                  Color(0xFF169060),
                                  Color(0xFF175B58),
                                  Color(0xFF19214F),
                                ],
=======
                                colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                                stops: [0.30, 0.70, 1],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Text(
                              'Advisor',
                              style: TextStyle(
                                fontSize: scaleFont(20),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.04),
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
<<<<<<< HEAD
                            onTap: () =>
                                setState(() => _showPassword = !_showPassword),
                            child: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
=======
                            onTap: () => setState(() => _showPassword = !_showPassword),
                            child: Icon(
                              _showPassword ? Icons.visibility : Icons.visibility_off,
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
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
<<<<<<< HEAD
                                onChanged: (value) =>
                                    setState(() => _rememberMe = value!),
=======
                                onChanged: (value) => setState(() => _rememberMe = value!),
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
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
<<<<<<< HEAD
                          colors: [
                            Color(0xFF169060),
                            Color(0xFF175B58),
                            Color(0xFF19214F),
                          ],
=======
                          colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
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
<<<<<<< HEAD
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.025,
                          ),
=======
                          padding: EdgeInsets.symmetric(vertical: height * 0.025),
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
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
<<<<<<< HEAD
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
=======
                          onTap: () => Navigator.pushNamed(context, '/register'),
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
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
<<<<<<< HEAD
}
=======
}
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
