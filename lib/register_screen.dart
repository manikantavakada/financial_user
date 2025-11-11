import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'bg.dart';
import 'color_constants.dart';

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
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _citySuburbController = TextEditingController();
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

  final String baseUrl = 'https://ds.singledeck.in/api/v1/';

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
          _countries = data
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
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
          _states = data
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
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
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
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
      _fullNameError = _fullNameController.text.trim().isEmpty
          ? 'Full name required'
          : '';
      _dobError = _dobController.text.trim().isEmpty
          ? 'Date of birth required'
          : '';
      _genderError = _gender == null ? 'Gender required' : '';
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      _emailError =
          _emailController.text.trim().isEmpty ||
              !emailRegex.hasMatch(_emailController.text)
          ? 'Valid email required'
          : '';
      _phoneError = _phoneController.text.trim().isEmpty
          ? 'Primary phone required'
          : '';
      _addressError = _address1Controller.text.trim().isEmpty
          ? 'Address 1st Line required'
          : '';
      _cityError = _citySuburbController.text.trim().isEmpty
          ? 'City/Suburb required'
          : '';
      _stateError = _selectedStateId == null ? 'State required' : '';
      _zipError = _zipController.text.trim().isEmpty ? 'Zip required' : '';
      _occupationError = _occupationController.text.trim().isEmpty
          ? 'Occupation required'
          : '';
      _maritalStatusError = _maritalStatus == null
          ? 'Marital status required'
          : '';
      _employmentStatusError = _employmentStatus == null
          ? 'Employment status required'
          : '';
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
      request.fields['address'] = _address2Controller.text.trim().isEmpty
          ? _address1Controller.text.trim()
          : '${_address1Controller.text.trim()}, ${_address2Controller.text.trim()}';
      request.fields['city'] = _citySuburbController.text.trim();
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
          SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: primaryColor,
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
          _error =
              'Registration failed: ${errorData['message'] ?? responseBody.body}';
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient (35% from top)
          Container(
            height: height * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(scaleWidth(30)),
                bottomRight: Radius.circular(scaleWidth(30)),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                SizedBox(height: scaleHeight(20)),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
                    child: _buildFormCard(),
                  ),
                ),
              ],
            ),
          ),
          
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(scaleWidth(20)),
      child: Row(
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
          
          Expanded(
            child: Text(
              'Registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: scaleFont(24),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          SizedBox(width: scaleWidth(36)), // Balance layout
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: EdgeInsets.all(scaleWidth(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error.isNotEmpty) _buildErrorCard(),
          
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
            controller: _address1Controller,
            hint: 'Address 1st Line',
            error: _addressError,
            icon: Icons.home_outlined,
          ),
          _buildTextField(
            controller: _address2Controller,
            hint: 'Address 2nd Line (Optional)',
            icon: Icons.home_outlined,
          ),
          _buildTextField(
            controller: _citySuburbController,
            hint: 'City/Suburb',
            error: _cityError,
            icon: Icons.location_city_outlined,
          ),
          _buildCountryDropdown(),
          _buildStateDropdown(),
          _buildTextField(
            controller: _zipController,
            hint: 'Postal/Zip Code',
            error: _zipError,
            icon: Icons.local_post_office_outlined,
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
            items: [
              'Employed',
              'Self-Employed',
              'Transition to Retirement Age',
              'Retired',
              'Student',
            ],
            hint: 'Employment Status',
            error: _employmentStatusError,
            onChanged: (v) => setState(() => _employmentStatus = v),
          ),
          SizedBox(height: scaleHeight(30)),
          _buildRegisterButton(),
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
              fontSize: scaleFont(14),
              color: Colors.grey.shade500,
            ),
            prefixIcon: icon != null
                ? Container(
                    margin: EdgeInsets.all(scaleWidth(8)),
                    padding: EdgeInsets.all(scaleWidth(8)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.1),
                          secondaryColor.withOpacity(0.1)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: primaryColor, size: scaleFont(18)),
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
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: scaleWidth(16),
              vertical: scaleHeight(16),
            ),
          ),
          style: TextStyle(
            fontSize: scaleFont(14),
            color: Colors.black87,
          ),
        ),
        if (error != null && error.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: scaleHeight(6), left: scaleWidth(12)),
            child: Text(
              error,
              style: TextStyle(
                fontSize: scaleFont(12),
                color: Colors.redAccent,
              ),
            ),
          ),
        SizedBox(height: scaleHeight(16)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: scaleFont(14),
                      color: Colors.black87,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: scaleFont(14),
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
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: scaleWidth(16),
              vertical: scaleHeight(16),
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
            padding: EdgeInsets.only(top: scaleHeight(6), left: scaleWidth(12)),
            child: Text(
              error,
              style: TextStyle(
                fontSize: scaleFont(12),
                color: Colors.redAccent,
              ),
            ),
          ),
        SizedBox(height: scaleHeight(16)),
      ],
    );
  }

  Widget _buildCountryDropdown() {
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
                  horizontal: scaleWidth(16),
                  vertical: scaleHeight(16),
                ),
                child: Text(
                  'Loading countries...',
                  style: TextStyle(
                    fontSize: scaleFont(14),
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
                            fontSize: scaleFont(14),
                            color: Colors.black87,
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
                    fontSize: scaleFont(14),
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
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: scaleWidth(16),
                    vertical: scaleHeight(16),
                  ),
                ),
                dropdownColor: Colors.white,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey.shade500,
                  size: scaleFont(24),
                ),
              ),
        SizedBox(height: scaleHeight(16)),
      ],
    );
  }

  Widget _buildStateDropdown() {
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
                  horizontal: scaleWidth(16),
                  vertical: scaleHeight(16),
                ),
                child: Text(
                  'Select a country first',
                  style: TextStyle(
                    fontSize: scaleFont(14),
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
                  horizontal: scaleWidth(16),
                  vertical: scaleHeight(16),
                ),
                child: Text(
                  _isFetchingStates
                      ? 'Loading states...'
                      : 'No states available',
                  style: TextStyle(
                    fontSize: scaleFont(14),
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
                            fontSize: scaleFont(14),
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedStateId = v),
                decoration: InputDecoration(
                  hintText: 'State/Region',
                  hintStyle: TextStyle(
                    fontSize: scaleFont(14),
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
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: scaleWidth(16),
                    vertical: scaleHeight(16),
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
            padding: EdgeInsets.only(top: scaleHeight(6), left: scaleWidth(12)),
            child: Text(
              _stateError,
              style: TextStyle(
                fontSize: scaleFont(12),
                color: Colors.redAccent,
              ),
            ),
          ),
        SizedBox(height: scaleHeight(16)),
      ],
    );
  }

  Widget _buildImagePicker() {
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
              horizontal: scaleWidth(16),
              vertical: scaleHeight(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _clntImage == null ? 'Select Profile Image' : 'Change Image',
                  style: TextStyle(
                    fontSize: scaleFont(14),
                    color: _clntImage == null
                        ? Colors.grey.shade500
                        : Colors.black87,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(scaleWidth(8)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.1),
                        secondaryColor.withOpacity(0.1)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    color: primaryColor,
                    size: scaleFont(18),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_clntImage != null)
          Padding(
            padding: EdgeInsets.only(top: scaleHeight(6), left: scaleWidth(12)),
            child: Text(
              'Selected: ${_clntImage!.name}',
              style: TextStyle(
                fontSize: scaleFont(12),
                color: primaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (_imageError.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: scaleHeight(6), left: scaleWidth(12)),
            child: Text(
              _imageError,
              style: TextStyle(
                fontSize: scaleFont(12),
                color: Colors.redAccent,
              ),
            ),
          ),
        SizedBox(height: scaleHeight(16)),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isLoading ? null : handleRegister,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: scaleHeight(16)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            _isLoading ? 'Registering...' : 'Register',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: scaleFont(16),
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(scaleWidth(20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: primaryColor),
              SizedBox(height: scaleHeight(16)),
              Text(
                'Registering...',
                style: TextStyle(
                  fontSize: scaleFont(16),
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
