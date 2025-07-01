import 'package:flutter/material.dart';

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
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _tfnController = TextEditingController();
  final _occupationController = TextEditingController();
  String? _maritalStatus;
  String? _employmentStatus;

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

  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

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
      _stateError = _stateController.text.trim().isEmpty ? 'State required' : '';
      _zipError = _zipController.text.trim().isEmpty ? 'Zip required' : '';
      _nationalityError = _nationalityController.text.trim().isEmpty ? 'Nationality required' : '';
      _occupationError = _occupationController.text.trim().isEmpty ? 'Occupation required' : '';
      _maritalStatusError = _maritalStatus == null ? 'Marital status required' : '';
      _employmentStatusError = _employmentStatus == null ? 'Employment status required' : '';

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

    // Simulate registration delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
    Navigator.pushReplacementNamed(context, '/login');
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
                  // Full Name
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
                  // Add this for spacing after the first field (and its error)
                  SizedBox(height: height * 0.018),
                  // DOB
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
                    SizedBox(height: height * 0.018),
                  // Gender
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
                    SizedBox(height: height * 0.018),
                  // Email
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
                    SizedBox(height: height * 0.018),
                  // Primary Phone
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
                    SizedBox(height: height * 0.018),
                  // Secondary Phone
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
                  // Address
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
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.red,
                        ),
                      ),
                    ),
                  // Zip & Nationality
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
                  // TFN
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
                  // Occupation
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
                  // Marital Status
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
                  // Employment Status
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
}