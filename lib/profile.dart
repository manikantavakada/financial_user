import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

import 'color_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? clientData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchClientDetails();
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

  Future<void> _fetchClientDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final clientId = prefs.getInt('client_id');

      if (clientId == null) {
        setState(() {
          errorMessage = 'Please login again';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://ds.singledeck.in/api/v1/clients/get-client-details/?clnt_id=$clientId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' &&
            data['data'] != null &&
            data['data'].isNotEmpty) {
          setState(() {
            clientData = data['data'][0];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'No client data found';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load profile data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error occurred';
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(scaleWidth(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: scaleFont(20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: scaleHeight(12)),
              Text(
                'Are you sure you want to log out?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: scaleFont(16),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: scaleHeight(20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: scaleHeight(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
                          fontSize: scaleFont(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: scaleWidth(12)),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: scaleHeight(12),
                        ),
                      ),
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: scaleFont(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  String _maskTFN(String? tfn) {
    if (tfn == null || tfn.isEmpty || tfn.length < 4) {
      return 'Not provided';
    }
    return '${tfn.substring(0, 2)}*****${tfn.substring(tfn.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? _buildLoadingScreen(width, height)
          : errorMessage != null
          ? _buildErrorWidget()
          : _buildProfileContent(width, height),
    );
  }

  Widget _buildLoadingScreen(double width, double height) {
    return Stack(
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
              bottomLeft: Radius.circular(scaleWidth(20)),
              bottomRight: Radius.circular(scaleWidth(20)),
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              // Header with shimmer
              Container(
                padding: EdgeInsets.all(scaleWidth(20)),
                child: Column(
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: scaleFont(24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: scaleHeight(20)),
                    Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.3),
                      highlightColor: Colors.white.withOpacity(0.1),
                      child: Column(
                        children: [
                          Container(
                            width: scaleWidth(90),
                            height: scaleWidth(90),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(height: scaleHeight(15)),
                          Container(
                            width: width * 0.6,
                            height: scaleHeight(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: scaleHeight(6)),
                          Container(
                            width: width * 0.5,
                            height: scaleHeight(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: scaleHeight(20)),

              // Cards shimmer
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
                  child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          margin: EdgeInsets.only(bottom: scaleHeight(16)),
                          height: scaleHeight(120),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    final height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
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
              Container(
                padding: EdgeInsets.all(scaleWidth(20)),
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: scaleFont(24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: scaleFont(80),
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: scaleHeight(16)),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          fontSize: scaleFont(18),
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: scaleHeight(24)),
                      GestureDetector(
                        onTap: _fetchClientDetails,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: scaleWidth(32),
                            vertical: scaleHeight(12),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: scaleFont(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent(double width, double height) {
    return Stack(
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
              // Header with profile info
              _buildProfileHeader(),

              SizedBox(height: scaleHeight(20)),

              // Profile cards
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        'Personal Information',
                        Icons.person_outline,
                        [
                          _buildInfoRow(
                            'Full Name',
                            clientData?['clnt_full_name'] ?? 'Not provided',
                          ),
                          _buildInfoRow(
                            'Date of Birth',
                            _formatDate(clientData?['clnt_dob']),
                          ),
                          _buildInfoRow(
                            'Gender',
                            _formatGender(clientData?['clnt_gender']),
                          ),
                          _buildInfoRow(
                            'Marital Status',
                            clientData?['clnt_marital_status'] ??
                                'Not provided',
                          ),
                        ],
                      ),

                      SizedBox(height: scaleHeight(10)),

                      _buildInfoCard(
                        'Contact Information',
                        Icons.contact_phone_outlined,
                        [
                          _buildInfoRow(
                            'Email',
                            clientData?['clnt_email'] ?? 'Not provided',
                          ),
                          _buildInfoRow(
                            'Phone',
                            clientData?['clnt_phone'] ?? 'Not provided',
                          ),
                          _buildInfoRow(
                            'Alternative Phone',
                            clientData?['clnt_alt_phone'] ?? 'Not provided',
                          ),
                          _buildInfoRow('Address', _formatAddress()),
                        ],
                      ),

                      SizedBox(height: scaleHeight(10)),

                      _buildInfoCard(
                        'Professional Information',
                        Icons.work_outline,
                        [
                          _buildInfoRow(
                            'Occupation',
                            clientData?['clnt_occupation'] ?? 'Not provided',
                          ),
                          _buildInfoRow(
                            'Employment Status',
                            clientData?['clnt_employment_status'] ??
                                'Not provided',
                          ),
                          _buildInfoRow(
                            'TFN',
                            _maskTFN(clientData?['clnt_tfn']),
                          ),
                        ],
                      ),

                      SizedBox(height: scaleHeight(10)),

                      _buildInfoCard(
                        'Account Information',
                        Icons.account_circle_outlined,
                        [
                          _buildInfoRow(
                            'Client ID',
                            clientData?['clnt_uid'] ?? 'Not provided',
                          ),
                          _buildInfoRow(
                            'Status',
                            _formatStatus(clientData?['clnt_status']),
                          ),
                          _buildInfoRow(
                            'Registration Date',
                            _formatDate(clientData?['clnt_rdate']),
                          ),
                          _buildInfoRow(
                            'Last Updated',
                            _formatDate(clientData?['clnt_ludate']),
                          ),
                        ],
                      ),

                      SizedBox(height: scaleHeight(40)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(scaleWidth(20)),
      child: Column(
        children: [
          // Title and Edit button
          Row(
            children: [
              Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: scaleFont(24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/edit_profile'),
                child: Container(
                  padding: EdgeInsets.all(scaleWidth(8)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: scaleFont(20),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: scaleHeight(10)),

          // Profile Avatar
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(scaleWidth(3)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: scaleWidth(45),
                  backgroundColor: Colors.white,
                  child: clientData?['clnt_image'] != null
                      ? ClipOval(
                          child: Image.network(
                            clientData!['clnt_image'],
                            width: scaleWidth(90),
                            height: scaleWidth(90),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          (clientData?['clnt_full_name'] ?? 'U')[0]
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: scaleFont(32),
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: scaleWidth(20),
                  height: scaleWidth(20),
                  decoration: BoxDecoration(
                    color: clientData?['clnt_status'] == 'AC'
                        ? Colors.green
                        : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: scaleHeight(15)),

          // Name and Email
          Text(
            clientData?['clnt_full_name'] ?? 'Unknown',
            style: TextStyle(
              color: Colors.white,
              fontSize: scaleFont(22),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: scaleHeight(6)),

          Text(
            clientData?['clnt_email'] ?? 'No email',
            style: TextStyle(
              color: Colors.white70,
              fontSize: scaleFont(14),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: scaleHeight(15)),

          // ID and Logout buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scaleWidth(12),
                  vertical: scaleHeight(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  'ID: ${clientData?['clnt_uid'] ?? '--'}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: scaleFont(12),
                  ),
                ),
              ),

              SizedBox(width: scaleWidth(12)),

              GestureDetector(
                onTap: _logout,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleWidth(12),
                    vertical: scaleHeight(6),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: scaleFont(16),
                      ),
                      SizedBox(width: scaleWidth(6)),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: scaleFont(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(scaleWidth(3)), // Gradient border width
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(scaleWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(scaleWidth(8)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: scaleFont(20)),
                ),
                SizedBox(width: scaleWidth(12)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: scaleFont(18),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleHeight(16)),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: scaleHeight(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: scaleWidth(120),
            child: Text(
              label,
              style: TextStyle(
                fontSize: scaleFont(14),
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: scaleWidth(16)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: scaleFont(14),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Utility methods remain the same
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not provided';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatGender(String? gender) {
    if (gender == null) return 'Not provided';
    return gender.toLowerCase() == 'male'
        ? 'Male'
        : gender.toLowerCase() == 'female'
        ? 'Female'
        : gender;
  }

  String _formatStatus(String? status) {
    if (status == null) return 'Not provided';
    return status == 'AC' ? 'Active' : 'Inactive';
  }

  String _formatAddress() {
    final address = clientData?['clnt_address'] ?? '';
    final city = clientData?['clnt_city'] ?? '';
    final zip = clientData?['clnt_zip'] ?? '';

    if (address.isEmpty && city.isEmpty && zip.isEmpty) {
      return 'Not provided';
    }

    return [address, city, zip].where((e) => e.isNotEmpty).join(', ');
  }
}
