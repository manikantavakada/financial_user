import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example user data, replace with real data as needed
    final user = {
      'name': 'Jim Halpert',
      'email': 'jim@dundermifflin.com',
      'phone': '+1 234 567 8900',
      'address': '1725 Slough Ave, Scranton, PA',
      'nationality': 'American',
      'occupation': 'Salesman',
      'maritalStatus': 'Married',
    };

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: const Color(0xFF1E3A5F),
            fontWeight: FontWeight.bold,
            fontSize: width * 0.055,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF169060)),
            onPressed: () {
              // Navigate to edit profile
              Navigator.pushNamed(context, '/edit_profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.07, vertical: height * 0.04),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(width * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: width * 0.13,
                    backgroundColor: const Color(0xFF169060),
                    child: Text(
                      user['name']![0],
                      style: TextStyle(
                        fontSize: width * 0.13,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    user['name'] ?? '',
                    style: TextStyle(
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    user['email'] ?? '',
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Divider(color: Colors.grey[300]),
                _profileRow('Phone', user['phone'] ?? '', width),
                _profileRow('Address', user['address'] ?? '', width),
                _profileRow('Nationality', user['nationality'] ?? '', width),
                _profileRow('Occupation', user['occupation'] ?? '', width),
                _profileRow('Marital Status', user['maritalStatus'] ?? '', width),
                const SizedBox(height: 18),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Handle logout
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF242C57),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.08,
                        vertical: height * 0.018,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: TextStyle(
                        fontSize: width * 0.045,
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
    );
  }

  Widget _profileRow(String label, String value, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: width * 0.32,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF242C57),
                fontWeight: FontWeight.w600,
                fontSize: width * 0.04,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: const Color(0xFF666666),
                fontSize: width * 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }
}