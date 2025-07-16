import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = {
      'name': 'Denial Rozar',
      'email': 'denialrozer@gmail.com',
      'school': 'The Lawrenceville School',
      'nickname': 'r.denial',
      'emergencyContact': 'Jessica Curl',
      'emergencyNumber': '+1-987654321',
    };

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
              stops: [0.3, 0.7, 1],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/edit_profile');
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF169060),
                  Color(0xFF175B58),
                  Color(0xFF19214F),
                ],
                stops: [0.3, 0.7, 1],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundImage: AssetImage(
<<<<<<< HEAD
                    'assets/profile.png',
=======
                    'assets/profile.jpg',
>>>>>>> 241c32e004e6b0b7e56c85f89a78edb6114a6316
                  ), // Replace with your image
                ),
                const SizedBox(height: 12),
                Text(
                  user['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _infoTile(Icons.school, 'School', user['school']!),
          _infoTile(Icons.person_outline, 'Nick Name', user['nickname']!),
          _infoTile(
            Icons.contacts,
            'Emergency Contact',
            user['emergencyContact']!,
          ),
          _infoTile(Icons.phone, 'Emergency Number', user['emergencyNumber']!),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE5F2F1),
            child: Icon(icon, color: Color(0xFF175B58)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
