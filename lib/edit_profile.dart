import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic>? clientData;
  bool isLoading = true;
  bool isSubmitting = false;
  String error = '';

  // Controllers
  late TextEditingController fullNameController;
  late TextEditingController dobController;
  late TextEditingController altPhoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController zipController;
  late TextEditingController tfnController;
  late TextEditingController occupationController;

  // Dropdown values
  String? selectedGender;
  String? selectedMaritalStatus;
  String? selectedEmploymentStatus;
  String? selectedCountryId;
  String? selectedStateId;

  // Country and State lists
  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> states = [];
  bool isFetchingStates = false;

  // Error messages
  String fullNameError = '';
  String dobError = '';
  String genderError = '';
  String addressError = '';
  String cityError = '';
  String stateError = '';
  String zipError = '';
  String occupationError = '';
  String maritalStatusError = '';
  String employmentStatusError = '';

  final String baseUrl = 'https://ss.singledeck.in/api/v1/';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    dobController = TextEditingController();
    altPhoneController = TextEditingController();
    addressController = TextEditingController();
    cityController = TextEditingController();
    zipController = TextEditingController();
    tfnController = TextEditingController();
    occupationController = TextEditingController();

    _fetchClientDetails();
    _fetchCountries();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    altPhoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    zipController.dispose();
    tfnController.dispose();
    occupationController.dispose();
    super.dispose();
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
          countries = data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        setState(() {
          error = 'Failed to load countries: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching countries: $e';
      });
    }
  }

  Future<void> _fetchStates(String countryId) async {
    setState(() {
      isFetchingStates = true;
      states = [];
      selectedStateId = null;
    });
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}master-entry/get-states/?cntr_id=$countryId'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        setState(() {
          states = data.map((item) => Map<String, dynamic>.from(item)).toList();
          isFetchingStates = false;
        });
      } else {
        setState(() {
          error = 'Failed to load states: ${response.statusCode}';
          isFetchingStates = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching states: $e';
        isFetchingStates = false;
      });
    }
  }

  Future<void> _fetchClientDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final prefs = await SharedPreferences.getInstance();
      final clientId = prefs.getInt('client_id');

      if (clientId == null) {
        setState(() {
          error = 'Please login again';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${baseUrl}clients/get-client-details/?clnt_id=$clientId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null && data['data'].isNotEmpty) {
          setState(() {
            clientData = data['data'][0];
            isLoading = false;
            _populateFields();
          });
        } else {
          setState(() {
            error = 'No client data found';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Failed to load profile data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error occurred: $e';
        isLoading = false;
      });
    }
  }

  void _populateFields() {
    fullNameController.text = clientData?['clnt_full_name'] ?? '';
    dobController.text = _formatDate(clientData?['clnt_dob']) ?? '';
    selectedDate = clientData?['clnt_dob'] != null ? DateTime.parse(clientData?['clnt_dob']) : null;
    // Normalize gender to match dropdown items (Male, Female, Other)
    selectedGender = clientData?['clnt_gender'] != null
        ? clientData!['clnt_gender'].toString().toLowerCase().replaceFirst(
              clientData!['clnt_gender'].toString().toLowerCase()[0],
              clientData!['clnt_gender'].toString().toLowerCase()[0].toUpperCase())
        : null;
    altPhoneController.text = clientData?['clnt_alt_phone'] ?? '';
    addressController.text = clientData?['clnt_address'] ?? '';
    cityController.text = clientData?['clnt_city'] ?? '';
    zipController.text = clientData?['clnt_zip'] ?? '';
    tfnController.text = clientData?['clnt_tfn'] ?? '';
    occupationController.text = clientData?['clnt_occupation'] ?? '';
    selectedMaritalStatus = clientData?['clnt_marital_status'] == 'Yes' ? 'Married' : 'Single';
    selectedEmploymentStatus = clientData?['clnt_employment_status'] == 'yes' ? 'Employed' : 'Unemployed';
    selectedCountryId = clientData?['clnt_countrie']?.toString();
    selectedStateId = clientData?['clnt_state']?.toString();

    if (selectedCountryId != null) {
      _fetchStates(selectedCountryId!);
    }
  }

  bool validateForm() {
    bool isValid = true;
    setState(() {
      fullNameError = fullNameController.text.trim().isEmpty ? 'Full name required' : '';
      dobError = dobController.text.trim().isEmpty ? 'Date of birth required' : '';
      genderError = selectedGender == null ? 'Gender required' : '';
      addressError = addressController.text.trim().isEmpty ? 'Address required' : '';
      cityError = cityController.text.trim().isEmpty ? 'City required' : '';
      stateError = selectedStateId == null ? 'State required' : '';
      zipError = zipController.text.trim().isEmpty ? 'Zip required' : '';
      occupationError = occupationController.text.trim().isEmpty ? 'Occupation required' : '';
      maritalStatusError = selectedMaritalStatus == null ? 'Marital status required' : '';
      employmentStatusError = selectedEmploymentStatus == null ? 'Employment status required' : '';

      isValid = [
        fullNameError,
        dobError,
        genderError,
        addressError,
        cityError,
        stateError,
        zipError,
        occupationError,
        maritalStatusError,
        employmentStatusError,
      ].every((e) => e.isEmpty);
    });
    return isValid;
  }

  Future<void> _updateProfile() async {
    if (!validateForm()) return;

    setState(() {
      isSubmitting = true;
      error = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final clientId = prefs.getInt('client_id');

      if (clientId == null) {
        throw Exception('Client ID not found');
      }

      final response = await http.put(
        Uri.parse('${baseUrl}clients/update-client-details/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'clnt_id': clientId,
          'full_name': fullNameController.text.trim(),
          'dob': dobController.text.trim(),
          'gender': selectedGender!.toLowerCase(),
          'alt_phone': altPhoneController.text.trim(),
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'zip': zipController.text.trim(),
          'tfn': tfnController.text.trim(),
          'occupation': occupationController.text.trim(),
          'marital_status': selectedMaritalStatus!.toLowerCase() == 'married' ? 'Yes' : 'No',
          'employment_status': selectedEmploymentStatus!.toLowerCase() == 'employed' ? 'yes' : 'no',
          'country': selectedCountryId,
          'state': selectedStateId,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF169060),
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          error = 'Update failed: ${data['message'] ?? response.body}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = 'Error during update: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(1990, 1, 1),
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
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  double scaleFont(double size) {
    return (size * MediaQuery.of(context).size.width / 375).clamp(size * 0.8, size * 1.2);
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
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: scaleFont(24),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: scaleFont(24)),
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
                        if (error.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              error,
                              style: TextStyle(
                                fontSize: scaleFont(14),
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        SizedBox(height: height * 0.02),
                        _buildTextField(
                          controller: fullNameController,
                          hint: 'Full Name',
                          error: fullNameError,
                          icon: Icons.person_outline,
                        ),
                        _buildTextField(
                          controller: dobController,
                          hint: 'Date of Birth',
                          error: dobError,
                          icon: Icons.calendar_today,
                          readOnly: true,
                          onTap: _selectDate,
                        ),
                        _buildDropdown(
                          value: selectedGender,
                          items: ['Male', 'Female', 'Other'],
                          hint: 'Gender',
                          error: genderError,
                          onChanged: (v) => setState(() => selectedGender = v),
                        ),
                        _buildTextField(
                          controller: altPhoneController,
                          hint: 'Secondary Phone',
                          icon: Icons.phone_iphone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          controller: addressController,
                          hint: 'Full Address',
                          error: addressError,
                          icon: Icons.home_outlined,
                        ),
                        _buildTextField(
                          controller: cityController,
                          hint: 'City',
                          error: cityError,
                          icon: Icons.location_city_outlined,
                        ),
                        _buildCountryDropdown(),
                        _buildStateDropdown(),
                        _buildTextField(
                          controller: zipController,
                          hint: 'Postal/Zip Code',
                          error: zipError,
                          icon: Icons.local_post_office_outlined,
                        ),
                        _buildTextField(
                          controller: tfnController,
                          hint: 'Tax File Number (TFN)',
                          icon: Icons.description_outlined,
                        ),
                        _buildTextField(
                          controller: occupationController,
                          hint: 'Occupation',
                          error: occupationError,
                          icon: Icons.work_outline,
                        ),
                        _buildDropdown(
                          value: selectedMaritalStatus,
                          items: ['Single', 'Married', 'Divorced', 'Widowed'],
                          hint: 'Marital Status',
                          error: maritalStatusError,
                          onChanged: (v) => setState(() => selectedMaritalStatus = v),
                        ),
                        _buildDropdown(
                          value: selectedEmploymentStatus,
                          items: ['Employed', 'Self-Employed', 'Unemployed', 'Retired', 'Student'],
                          hint: 'Employment Status',
                          error: employmentStatusError,
                          onChanged: (v) => setState(() => selectedEmploymentStatus = v),
                        ),
                        SizedBox(height: height * 0.04),
                        _buildUpdateButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isLoading || isSubmitting)
          Container(
            color: Colors.black54,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF169060)),
                    const SizedBox(height: 10),
                    Text(
                      isLoading ? 'Loading...' : 'Updating...',
                      style: TextStyle(
                        fontSize: scaleFont(16).clamp(14.0, 18.0),
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
    bool isProcessing = false;

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
          onChanged: isLoading || isSubmitting || isProcessing
              ? null
              : (v) {
                  if (!isProcessing) {
                    isProcessing = true;
                    onChanged(v);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      isProcessing = false;
                    });
                  }
                },
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
        countries.isEmpty
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
                value: selectedCountryId,
                items: countries
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
                onChanged: isLoading || isSubmitting
                    ? null
                    : (v) {
                        setState(() {
                          selectedCountryId = v;
                          states = [];
                          selectedStateId = null;
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
        selectedCountryId == null
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
            : isFetchingStates || states.isEmpty
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
                      isFetchingStates ? 'Loading states...' : 'No states available',
                      style: TextStyle(
                        fontSize: scaleFont(16),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    value: selectedStateId,
                    items: states
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
                    onChanged: isLoading || isSubmitting
                        ? null
                        : (v) => setState(() => selectedStateId = v),
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
        if (stateError.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6, left: 12),
            child: Text(
              stateError,
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

  Widget _buildUpdateButton() {
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
        onPressed: isSubmitting ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: height * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isSubmitting ? 'Updating...' : 'Update Profile',
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

  String? _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return dateString;
    }
  }
}