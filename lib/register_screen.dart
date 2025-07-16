<<<<<<< HEAD

import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
=======
import 'package:flutter/material.dart';
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  String? _gender;
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
<<<<<<< HEAD
=======
  final _stateController = TextEditingController();
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
  final _zipController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _tfnController = TextEditingController();
  final _occupationController = TextEditingController();
  String? _maritalStatus;
  String? _employmentStatus;
<<<<<<< HEAD
  XFile? _clntImage; // Changed to XFile for cross-platform compatibility

  // Static FCM token
  final String _fcmToken = 'static-fcm-token';

  // State and country dropdown data
  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _states = [];
  String? _selectedCountryId;
  String? _selectedStateId;
  bool _isFetchingStates = false; // Track state fetching status
=======
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316

  bool _isLoading = false;
  String _error = '';
  String _fullNameError = '';
  String _dobError = '';
  String _genderError = '';
  String _emailError = '';
  String _phoneError = '';
  String _addressError = '';
  String _cityError = '';
  String _stateError = '';
  String _zipError = '';
  String _nationalityError = '';
  String _occupationError = '';
  String _maritalStatusError = '';
  String _employmentStatusError = '';
<<<<<<< HEAD
  String _imageError = '';

  final String baseUrl = 'https://ss.singledeck.in/api/v1/'; // Replace with your actual base URL
=======
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316

  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

<<<<<<< HEAD
  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  // Fetch countries from API
  Future<void> _fetchCountries() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}master-entry/get-countries/'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        print('Countries Response: ${response.body}');
        setState(() {
          _countries = data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        setState(() {
          _error = 'Failed to load countries: ${response.statusCode}';
        });
        print('Countries Error: Status ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching countries: $e';
      });
      print('Countries Exception: $e');
    }
  }

  // Fetch states based on selected country
  Future<void> _fetchStates(String countryId) async {
    setState(() {
      _isFetchingStates = true;
      _states = [];
      _selectedStateId = null;
    });
    try {
      final response = await http.get(Uri.parse('${baseUrl}master-entry/get-states/?cntr_id=$countryId'));
      print('States Response: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        setState(() {
          _states = data.map((item) => Map<String, dynamic>.from(item)).toList();
          _isFetchingStates = false;
          print('States Loaded: $_states');
        });
      } else {
        setState(() {
          _error = 'Failed to load states: ${response.statusCode}';
          _isFetchingStates = false;
        });
        print('States Error: Status ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching states: $e';
        _isFetchingStates = false;
      });
      print('States Exception: $e');
    }
  }

  // Select image
  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _clntImage = pickedFile;
        _imageError = '';
      });
    }
  }

  // Select date
=======
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

<<<<<<< HEAD
  // Validate form
=======
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
  bool validateForm() {
    bool isValid = true;
    setState(() {
      _fullNameError = _fullNameController.text.trim().isEmpty ? 'Full name required' : '';
      _dobError = _dobController.text.trim().isEmpty ? 'Date of birth required' : '';
      _genderError = _gender == null ? 'Gender required' : '';
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      _emailError = _emailController.text.trim().isEmpty || !emailRegex.hasMatch(_emailController.text)
          ? 'Valid email required'
          : '';
      _phoneError = _phoneController.text.trim().isEmpty ? 'Primary phone required' : '';
      _addressError = _addressController.text.trim().isEmpty ? 'Address required' : '';
      _cityError = _cityController.text.trim().isEmpty ? 'City required' : '';
<<<<<<< HEAD
      _stateError = _selectedStateId == null ? 'State required' : '';
=======
      _stateError = _stateController.text.trim().isEmpty ? 'State required' : '';
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
      _zipError = _zipController.text.trim().isEmpty ? 'Zip required' : '';
      _nationalityError = _nationalityController.text.trim().isEmpty ? 'Nationality required' : '';
      _occupationError = _occupationController.text.trim().isEmpty ? 'Occupation required' : '';
      _maritalStatusError = _maritalStatus == null ? 'Marital status required' : '';
      _employmentStatusError = _employmentStatus == null ? 'Employment status required' : '';
<<<<<<< HEAD
      _imageError = _clntImage == null ? 'Profile image required' : '';
=======
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316

      isValid = [
        _fullNameError,
        _dobError,
        _genderError,
        _emailError,
        _phoneError,
        _addressError,
        _cityError,
        _stateError,
        _zipError,
        _nationalityError,
        _occupationError,
        _maritalStatusError,
        _employmentStatusError,
<<<<<<< HEAD
        _imageError,
=======
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
      ].every((e) => e.isEmpty);
    });
    return isValid;
  }

<<<<<<< HEAD
  // Register API call
  Future<void> handleRegister() async {
    //if (!validateForm()) return;
=======
  Future<void> handleRegister() async {
    if (!validateForm()) return;
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316

    setState(() {
      _isLoading = true;
      _error = '';
    });

<<<<<<< HEAD
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}clients/client-register/'));
      request.fields['email'] = _emailController.text.trim();
      request.fields['mobile'] = _phoneController.text.trim();
      request.fields['full_name'] = _fullNameController.text.trim();
      request.fields['dob'] = _dobController.text.trim();
      request.fields['gender'] = _gender!.toLowerCase();
      request.fields['alt_phone'] = _altPhoneController.text.trim();
      request.fields['address'] = _addressController.text.trim();
      request.fields['city'] = _cityController.text.trim();
      request.fields['state'] = _selectedStateId!;
      request.fields['country'] = _selectedCountryId!;
      request.fields['zip'] = _zipController.text.trim();
      request.fields['nationality'] = _nationalityController.text.trim();
      request.fields['tfn'] = _tfnController.text.trim();
      request.fields['occupation'] = _occupationController.text.trim();
      request.fields['marital_status'] = _maritalStatus!.toLowerCase() == 'married' ? 'Yes' : 'No';
      request.fields['employment_status'] = _employmentStatus!.toLowerCase() == 'employed' || _employmentStatus!.toLowerCase() == 'self-employed' ? 'yes' : 'no';
      request.fields['fcm_token'] = _fcmToken;

      if (_clntImage != null) {
        if (kIsWeb) {
          // Web: Use bytes for file upload
          final bytes = await _clntImage!.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'clnt_image',
            bytes,
            filename: _clntImage!.name,
          ));
        } else {
          // Mobile/Desktop: Use file path
          request.files.add(await http.MultipartFile.fromPath(
            'clnt_image',
            _clntImage!.path,
          ));
        }
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      print('Registration Response: ${responseBody.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final errorData = jsonDecode(responseBody.body);
        setState(() {
          _error = 'Registration failed: ${errorData['message'] ?? responseBody.body}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error during registration: $e';
      });
      print('Registration Exception: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
=======
    // Simulate registration delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
    Navigator.pushReplacementNamed(context, '/login');
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: height * 0.02),
                      child: Text(
                        '<',
                        style: TextStyle(
                          fontSize: scaleFont(30),
                          color: const Color(0xFF1E3A5F),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Create account',
                    style: TextStyle(
                      fontSize: scaleFont(22),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: scaleFont(14),
                      color: const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
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
<<<<<<< HEAD
=======
                  // Full Name
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  TextField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      hintStyle: TextStyle(fontSize: scaleFont(16)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                    ),
                  ),
                  if (_fullNameError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        _fullNameError,
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
<<<<<<< HEAD
                  SizedBox(height: height * 0.018),
=======
                  // Add this for spacing after the first field (and its error)
                  SizedBox(height: height * 0.018),
                  // DOB
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  TextField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Date of Birth',
                      hintStyle: TextStyle(fontSize: scaleFont(16)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                      suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF666666), size: scaleFont(20)),
                    ),
                    onTap: _selectDate,
                  ),
                  if (_dobError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        _dobError,
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
<<<<<<< HEAD
                  SizedBox(height: height * 0.018),
=======
                    SizedBox(height: height * 0.018),
                  // Gender
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  DropdownButtonFormField<String>(
                    value: _gender,
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _gender = v),
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                    ),
                  ),
                  if (_genderError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        _genderError,
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
<<<<<<< HEAD
                  SizedBox(height: height * 0.018),
=======
                    SizedBox(height: height * 0.018),
                  // Email
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(fontSize: scaleFont(16)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                  ),
                  if (_emailError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        _emailError,
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
<<<<<<< HEAD
                  SizedBox(height: height * 0.018),
=======
                    SizedBox(height: height * 0.018),
                  // Primary Phone
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Primary Phone',
                      hintStyle: TextStyle(fontSize: scaleFont(16)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  if (_phoneError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        _phoneError,
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
<<<<<<< HEAD
                  SizedBox(height: height * 0.018),
=======
                    SizedBox(height: height * 0.018),
                  // Secondary Phone
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  TextField(
                    controller: _altPhoneController,
                    decoration: InputDecoration(
                      hintText: 'Secondary Phone',
                      hintStyle: TextStyle(fontSize: scaleFont(16)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
<<<<<<< HEAD
=======
                  // Address
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  SizedBox(height: height * 0.018),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Full Address',
                      hintStyle: TextStyle(fontSize: scaleFont(16)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                    ),
                  ),
                  if (_addressError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        _addressError,
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
<<<<<<< HEAD
                  SizedBox(height: height * 0.018),
                  // Country Dropdown
                  _countries.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD3D3D3)),
                            borderRadius: BorderRadius.circular(height * 0.01),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.03,
                            vertical: height * 0.015,
                          ),
                          child: Text(
                            'Loading countries...',
                            style: TextStyle(
                              fontSize: scaleFont(16),
                              color: Color(0xFF666666),
                            ),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedCountryId,
                          items: _countries
                              .map((country) => DropdownMenuItem(
                                    value: country['cntr_id'].toString(),
                                    child: Text(country['cntr_name'] ?? ''),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedCountryId = v;
                              _states = [];
                              _selectedStateId = null;
                            });
                            if (v != null) {
                              _fetchStates(v);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Country',
=======
                  // City & State
                  SizedBox(height: height * 0.018),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            hintText: 'City',
                            hintStyle: TextStyle(fontSize: scaleFont(16)),
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(height * 0.01),
                              borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(height * 0.01),
                              borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: width * 0.03,
                              vertical: height * 0.015,
                            ),
                          ),
                        ),
<<<<<<< HEAD
                  SizedBox(height: height * 0.018),
                  // State Dropdown
                  _selectedCountryId == null
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD3D3D3)),
                            borderRadius: BorderRadius.circular(height * 0.01),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.03,
                            vertical: height * 0.015,
                          ),
                          child: Text(
                            'Select a country first',
                            style: TextStyle(
                              fontSize: scaleFont(16),
                              color: Color(0xFF666666),
                            ),
                          ),
                        )
                      : _isFetchingStates || _states.isEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFD3D3D3)),
                                borderRadius: BorderRadius.circular(height * 0.01),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.03,
                                vertical: height * 0.015,
                              ),
                              child: Text(
                                _isFetchingStates ? 'Loading states...' : 'No states available',
                                style: TextStyle(
                                  fontSize: scaleFont(16),
                                  color: Color(0xFF666666),
                                ),
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              value: _selectedStateId,
                              items: _states
                                  .map((state) => DropdownMenuItem(
                                        value: state['stat_id'].toString(),
                                        child: Text(state['stat_name'] ?? ''),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedStateId = v),
                              decoration: InputDecoration(
                                labelText: 'State/Region',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(height * 0.01),
                                  borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(height * 0.01),
                                  borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: width * 0.03,
                                  vertical: height * 0.015,
                                ),
                              ),
                            ),
                  if (_stateError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        _stateError,
=======
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: TextField(
                          controller: _stateController,
                          decoration: InputDecoration(
                            hintText: 'State/Region',
                            hintStyle: TextStyle(fontSize: scaleFont(16)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(height * 0.01),
                              borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(height * 0.01),
                              borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: width * 0.03,
                              vertical: height * 0.015,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_cityError.isNotEmpty || _stateError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        '${_cityError.isNotEmpty ? _cityError : ''} ${_stateError.isNotEmpty ? _stateError : ''}',
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
<<<<<<< HEAD
=======
                  // Zip & Nationality
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  SizedBox(height: height * 0.018),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _zipController,
                          decoration: InputDecoration(
                            hintText: 'Postal/Zip Code',
                            hintStyle: TextStyle(fontSize: scaleFont(16)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(height * 0.01),
                              borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(height * 0.01),
                              borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: width * 0.03,
                              vertical: height * 0.015,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: TextField(
                          controller: _nationalityController,
                          decoration: InputDecoration(
                            hintText: 'Nationality',
                            hintStyle: TextStyle(fontSize: scaleFont(16)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(height * 0.01),
                              borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(height * 0.01),
                              borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: width * 0.03,
                              vertical: height * 0.015,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_zipError.isNotEmpty || _nationalityError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        '${_zipError.isNotEmpty ? _zipError : ''} ${_nationalityError.isNotEmpty ? _nationalityError : ''}',
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
<<<<<<< HEAD
                  SizedBox(height: height * 0.018),
                  GestureDetector(
                    onTap: _selectImage,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFD3D3D3)),
                        borderRadius: BorderRadius.circular(height * 0.01),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _clntImage == null ? 'Select Profile Image' : 'Image Selected',
                            style: TextStyle(
                              fontSize: scaleFont(16),
                              color: _clntImage == null ? Color(0xFF666666) : Colors.black,
                            ),
                          ),
                          Icon(Icons.image, color: Color(0xFF666666), size: scaleFont(20)),
                        ],
                      ),
                    ),
                  ),
                  if (_imageError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        _imageError,
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
=======
                  // TFN
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  SizedBox(height: height * 0.018),
                  TextField(
                    controller: _tfnController,
                    decoration: InputDecoration(
                      hintText: 'Tax File Number (TFN)',
                      hintStyle: TextStyle(fontSize: scaleFont(16)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                    ),
                  ),
<<<<<<< HEAD
=======
                  // Occupation
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  SizedBox(height: height * 0.018),
                  TextField(
                    controller: _occupationController,
                    decoration: InputDecoration(
                      hintText: 'Occupation',
                      hintStyle: TextStyle(fontSize: scaleFont(16)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                    ),
                  ),
                  if (_occupationError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        _occupationError,
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
<<<<<<< HEAD
=======
                  // Marital Status
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  SizedBox(height: height * 0.018),
                  DropdownButtonFormField<String>(
                    value: _maritalStatus,
                    items: ['Single', 'Married', 'Divorced', 'Widowed']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _maritalStatus = v),
                    decoration: InputDecoration(
                      labelText: 'Marital Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                    ),
                  ),
                  if (_maritalStatusError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        _maritalStatusError,
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
<<<<<<< HEAD
=======
                  // Employment Status
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  SizedBox(height: height * 0.018),
                  DropdownButtonFormField<String>(
                    value: _employmentStatus,
                    items: ['Employed', 'Self-Employed', 'Unemployed', 'Retired', 'Student']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _employmentStatus = v),
                    decoration: InputDecoration(
                      labelText: 'Employment Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(height * 0.01),
                        borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.015,
                      ),
                    ),
                  ),
                  if (_employmentStatusError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.01),
                      child: Text(
                        _employmentStatusError,
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
                  SizedBox(height: height * 0.03),
                  Container(
                    width: width * 0.85,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00A962), Color(0xFF242C57), Color(0xFF164454)],
                        stops: [0.40, 1, 0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(height * 0.01),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: height * 0.025),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(height * 0.01),
                        ),
                      ),
                      child: Text(
                        _isLoading ? 'Registering...' : 'Register',
                        style: TextStyle(
                          fontSize: scaleFont(16),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
