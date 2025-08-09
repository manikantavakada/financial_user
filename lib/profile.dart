import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

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
          'https://ss.singledeck.in/api/v1/clients/get-client-details/?clnt_id=$clientId',
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
            gradient: const LinearGradient(
              colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
              stops: [0.3, 0.7, 1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to log out?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: scaleFont(16),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                  const SizedBox(width: 12),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
    // Assuming TFN is at least 9 characters (e.g., Australian TFN format)
    return '${tfn.substring(0, 2)}*****${tfn.substring(tfn.length - 2)}';
  }

  double scaleFont(double size) {
    return (size * MediaQuery.of(context).size.width / 375).clamp(
      size * 0.8,
      size * 1.2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: isLoading
          ? _buildShimmerLoading(width, height)
          : errorMessage != null
          ? _buildErrorWidget()
          : _buildProfileContent(width, height),
    );
  }

  Widget _buildShimmerLoading(double width, double height) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Shimmer
          Container(
            height: 300,
            width: width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF169060),
                  Color(0xFF175B58),
                  Color(0xFF19214F),
                ],
                stops: [0.3, 0.7, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: const Color(0xFF169060).withOpacity(0.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar Placeholder
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Name Placeholder
                      Container(
                        width: width * 0.6,
                        height: scaleFont(22),
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      // Email Placeholder
                      Container(
                        width: width * 0.5,
                        height: scaleFont(14),
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      // Client ID Badge Placeholder
                      Container(
                        width:
                            100, // Approximate width of "ID: XXXX" with padding
                        height:
                            scaleFont(12) +
                            12, // Text height + vertical padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Logout Button Placeholder
                      Container(
                        width:
                            110, // Approximate width of icon + "Log Out" with padding
                        height: scaleFont(12) + 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Card Shimmer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: const Color(0xFF169060).withOpacity(0.5),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: TextStyle(
              fontSize: scaleFont(18),
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchClientDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF169060),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: scaleFont(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(double width, double height) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF169060),
                    Color(0xFF175B58),
                    Color(0xFF19214F),
                  ],
                  stops: [0.3, 0.7, 1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white,
                              child: clientData?['clnt_image'] != null
                                  ? ClipOval(
                                      child: Image.network(
                                        clientData!['clnt_image'],
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Text(
                                      (clientData?['clnt_full_name'] ?? 'U')[0]
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF169060),
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: clientData?['clnt_status'] == 'AC'
                                    ? Colors.green
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
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
                      const SizedBox(height: 6),
                      Text(
                        clientData?['clnt_email'] ?? 'No email',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: scaleFont(14),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
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
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
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
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildInfoCard('Personal Information', Icons.person_outline, [
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
                  clientData?['clnt_marital_status'] ?? 'Not provided',
                ),
              ]),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              _buildInfoCard('Professional Information', Icons.work_outline, [
                _buildInfoRow(
                  'Occupation',
                  clientData?['clnt_occupation'] ?? 'Not provided',
                ),
                _buildInfoRow(
                  'Employment Status',
                  clientData?['clnt_employment_status'] ?? 'Not provided',
                ),
                _buildInfoRow('TFN', _maskTFN(clientData?['clnt_tfn'])),
              ]),
              const SizedBox(height: 20),
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
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
          stops: [0.30, 0.70, 1],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF169060).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: const Color(0xFF169060), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
