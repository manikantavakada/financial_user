import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
  final _zipController = TextEditingController();
  
  final _tfnController = TextEditingController();
  final _occupationController = TextEditingController();
  String? _maritalStatus;
  String? _employmentStatus;
  XFile? _clntImage;

  final String _fcmToken = 'static-fcm-token';

  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _states = [];
  String? _selectedCountryId;
  String? _selectedStateId;
  bool _isFetchingStates = false;

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
  String _imageError = '';

  final String baseUrl = 'https://ss.singledeck.in/api/v1/';

  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}master-entry/get-countries/'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        setState(() {
          _countries = data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        setState(() {
          _error = 'Failed to load countries: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching countries: $e';
      });
    }
  }

  Future<void> _fetchStates(String countryId) async {
    setState(() {
      _isFetchingStates = true;
      _states = [];
      _selectedStateId = null;
    });
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}master-entry/get-states/?cntr_id=$countryId'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        setState(() {
          _states = data.map((item) => Map<String, dynamic>.from(item)).toList();
          _isFetchingStates = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load states: ${response.statusCode}';
          _isFetchingStates = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching states: $e';
        _isFetchingStates = false;
      });
    }
  }

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

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF169060),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E3A5F),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF169060),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

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
      _stateError = _selectedStateId == null ? 'State required' : '';
      _zipError = _zipController.text.trim().isEmpty ? 'Zip required' : '';
      
      _occupationError = _occupationController.text.trim().isEmpty ? 'Occupation required' : '';
      _maritalStatusError = _maritalStatus == null ? 'Marital status required' : '';
      _employmentStatusError = _employmentStatus == null ? 'Employment status required' : '';
      _imageError = _clntImage == null ? 'Profile image required' : '';

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
        _imageError,
      ].every((e) => e.isEmpty);
    });
    return isValid;
  }

  Future<void> handleRegister() async {
    if (!validateForm()) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}clients/client-register/'),
      );
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
      
      request.fields['tfn'] = _tfnController.text.trim();
      request.fields['occupation'] = _occupationController.text.trim();
      request.fields['marital_status'] =
          _maritalStatus!.toLowerCase() == 'married' ? 'Yes' : 'No';
      request.fields['employment_status'] =
          _employmentStatus!.toLowerCase() == 'employed' ||
                  _employmentStatus!.toLowerCase() == 'self-employed'
              ? 'yes'
              : 'no';
      request.fields['fcm_token'] = _fcmToken;

      if (_clntImage != null) {
        if (kIsWeb) {
          final bytes = await _clntImage!.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'clnt_image',
              bytes,
              filename: _clntImage!.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('clnt_image', _clntImage!.path),
          );
        }
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (responseBody.statusCode == 200 || responseBody.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Color(0xFF169060),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final errorData = jsonDecode(responseBody.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration failed: ${errorData['message'] ?? responseBody.body}',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() {
          _error = 'Registration failed: ${errorData['message'] ?? responseBody.body}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error during registration: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Header with Back Button
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 20,
                  left: 16,
                  right: 16,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF169060),
                      Color(0xFF175B58),
                      Color(0xFF19214F),
                    ],
                    stops: [0.30, 0.70, 1],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: scaleFont(24),
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Registration',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: scaleFont(24),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: scaleFont(24)), // Spacer for alignment
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                      vertical: height * 0.03,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_error.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _error,
                              style: TextStyle(
                                fontSize: scaleFont(14),
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        SizedBox(height: height * 0.02),
                        _buildTextField(
                          controller: _fullNameController,
                          hint: 'Full Name',
                          error: _fullNameError,
                          icon: Icons.person_outline,
                        ),
                        _buildTextField(
                          controller: _dobController,
                          hint: 'Date of Birth',
                          error: _dobError,
                          icon: Icons.calendar_today,
                          readOnly: true,
                          onTap: _selectDate,
                        ),
                        _buildDropdown(
                          value: _gender,
                          items: ['Male', 'Female', 'Other'],
                          hint: 'Gender',
                          error: _genderError,
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'Email',
                          error: _emailError,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                        ),
                        _buildTextField(
                          controller: _phoneController,
                          hint: 'Primary Phone',
                          error: _phoneError,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          controller: _altPhoneController,
                          hint: 'Secondary Phone',
                          icon: Icons.phone_iphone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          controller: _addressController,
                          hint: 'Full Address',
                          error: _addressError,
                          icon: Icons.home_outlined,
                        ),
                        _buildTextField(
                          controller: _cityController,
                          hint: 'City',
                          error: _cityError,
                          icon: Icons.location_city_outlined,
                        ),
                        _buildCountryDropdown(),
                        _buildStateDropdown(),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _zipController,
                                hint: 'Postal/Zip Code',
                                error: _zipError,
                                icon: Icons.local_post_office_outlined,
                              ),
                            ),
                            
                          ],
                        ),
                        _buildImagePicker(),
                        _buildTextField(
                          controller: _tfnController,
                          hint: 'Tax File Number (TFN)',
                          icon: Icons.description_outlined,
                        ),
                        _buildTextField(
                          controller: _occupationController,
                          hint: 'Occupation',
                          error: _occupationError,
                          icon: Icons.work_outline,
                        ),
                        _buildDropdown(
                          value: _maritalStatus,
                          items: ['Single', 'Married', 'Divorced', 'Widowed'],
                          hint: 'Marital Status',
                          error: _maritalStatusError,
                          onChanged: (v) => setState(() => _maritalStatus = v),
                        ),
                        _buildDropdown(
                          value: _employmentStatus,
                          items: ['Employed', 'Self-Employed', 'Unemployed', 'Retired', 'Student'],
                          hint: 'Employment Status',
                          error: _employmentStatusError,
                          onChanged: (v) => setState(() => _employmentStatus = v),
                        ),
                        SizedBox(height: height * 0.04),
                        _buildRegisterButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                    'Registering...',
                    style: TextStyle(
                      fontSize: scaleFont(16),
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? error,
    IconData? icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool autocorrect = true,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    VoidCallback? onTap,
  }) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          autocorrect: autocorrect,
          textCapitalization: textCapitalization,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: scaleFont(16),
              color: Colors.grey.shade500,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: Colors.grey.shade500,
                    size: scaleFont(20),
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF169060), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.02,
            ),
          ),
          style: TextStyle(
            fontSize: scaleFont(16),
            color: const Color(0xFF1E3A5F),
          ),
        ),
        if (error != null && error.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6, left: 12),
            child: Text(
              error,
              style: TextStyle(
                fontSize: scaleFont(12),
                color: Colors.redAccent,
              ),
            ),
          ),
        SizedBox(height: height * 0.015),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    String? error,
    required ValueChanged<String?> onChanged,
  }) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: scaleFont(16),
                        color: const Color(0xFF1E3A5F),
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: scaleFont(16),
              color: Colors.grey.shade500,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF169060), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.02,
            ),
          ),
          dropdownColor: Colors.white,
          icon: Icon(
            Icons.arrow_drop_down,
            color: Colors.grey.shade500,
            size: scaleFont(24),
          ),
        ),
        if (error != null && error.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6, left: 12),
            child: Text(
              error,
              style: TextStyle(
                fontSize: scaleFont(12),
                color: Colors.redAccent,
              ),
            ),
          ),
        SizedBox(height: height * 0.015),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _countries.isEmpty
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.02,
                ),
                child: Text(
                  'Loading countries...',
                  style: TextStyle(
                    fontSize: scaleFont(16),
                    color: Colors.grey.shade500,
                  ),
                ),
              )
            : DropdownButtonFormField<String>(
                value: _selectedCountryId,
                items: _countries
                    .map(
                      (country) => DropdownMenuItem(
                        value: country['cntr_id'].toString(),
                        child: Text(
                          country['cntr_name'] ?? '',
                          style: TextStyle(
                            fontSize: scaleFont(16),
                            color: const Color(0xFF1E3A5F),
                          ),
                        ),
                      ),
                    )
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
                  hintText: 'Country',
                  hintStyle: TextStyle(
                    fontSize: scaleFont(16),
                    color: Colors.grey.shade500,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF169060), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.02,
                  ),
                ),
                dropdownColor: Colors.white,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey.shade500,
                  size: scaleFont(24),
                ),
              ),
        SizedBox(height: height * 0.015),
      ],
    );
  }

  Widget _buildStateDropdown() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _selectedCountryId == null
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.02,
                ),
                child: Text(
                  'Select a country first',
                  style: TextStyle(
                    fontSize: scaleFont(16),
                    color: Colors.grey.shade500,
                  ),
                ),
              )
            : _isFetchingStates || _states.isEmpty
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.02,
                    ),
                    child: Text(
                      _isFetchingStates ? 'Loading states...' : 'No states available',
                      style: TextStyle(
                        fontSize: scaleFont(16),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    value: _selectedStateId,
                    items: _states
                        .map(
                          (state) => DropdownMenuItem(
                            value: state['stat_id'].toString(),
                            child: Text(
                              state['stat_name'] ?? '',
                              style: TextStyle(
                                fontSize: scaleFont(16),
                                color: const Color(0xFF1E3A5F),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedStateId = v),
                    decoration: InputDecoration(
                      hintText: 'State/Region',
                      hintStyle: TextStyle(
                        fontSize: scaleFont(16),
                        color: Colors.grey.shade500,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF169060), width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: height * 0.02,
                      ),
                    ),
                    dropdownColor: Colors.white,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade500,
                      size: scaleFont(24),
                    ),
                  ),
        if (_stateError.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6, left: 12),
            child: Text(
              _stateError,
              style: TextStyle(
                fontSize: scaleFont(12),
                color: Colors.redAccent,
              ),
            ),
          ),
        SizedBox(height: height * 0.015),
      ],
    );
  }

  Widget _buildImagePicker() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _selectImage,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.02,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _clntImage == null ? 'Select Profile Image' : 'Change Image',
                  style: TextStyle(
                    fontSize: scaleFont(16),
                    color: _clntImage == null ? Colors.grey.shade500 : const Color(0xFF1E3A5F),
                  ),
                ),
                Icon(
                  Icons.photo_camera_outlined,
                  color: _clntImage == null ? Colors.grey.shade500 : const Color(0xFF169060),
                  size: scaleFont(20),
                ),
              ],
            ),
          ),
        ),
        if (_clntImage != null)
          Padding(
            padding: EdgeInsets.only(top: 6, left: 12),
            child: Text(
              'Selected: ${_clntImage!.name}',
              style: TextStyle(
                fontSize: scaleFont(12),
                color: const Color(0xFF1E3A5F),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (_imageError.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6, left: 12),
            child: Text(
              _imageError,
              style: TextStyle(
                fontSize: scaleFont(12),
                color: Colors.redAccent,
              ),
            ),
          ),
        SizedBox(height: height * 0.015),
      ],
    );
  }

  Widget _buildRegisterButton() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: height * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _isLoading ? 'Registering...' : 'Register',
          style: TextStyle(
            fontSize: scaleFont(16),
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}