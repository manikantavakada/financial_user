import 'package:flutter/material.dart';
import 'aboutus.dart';
import 'advisor_request.dart';
import 'dashboard.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedBottomItem = 'requests';

  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  Widget _getCurrentTab() {
    switch (_selectedBottomItem) {
      case 'dashboard':
        return const DashboardScreen();
      case 'profile':
        return const ProfileScreen();
      case 'about':
        return const AboutUsScreen();
      case 'requests':
      default:
        return const AdvisorRequestsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: _getCurrentTab(),
      floatingActionButton: Container(
        width: width * 0.17,
        height: width * 0.17,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
            stops: [0.30, 0.70, 1],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add, size: 30, color: Colors.black),
            onPressed: () {
              if (_selectedBottomItem == 'requests') {
                
              }
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: height * 0.09,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: _selectedBottomItem == 'requests'
                    ? Icons.assignment
                    : Icons.assignment_outlined,
                label: 'Requests',
                selected: _selectedBottomItem == 'requests',
                onTap: () => setState(() => _selectedBottomItem = 'requests'),
                width: width,
              ),
              _buildNavItem(
                icon: _selectedBottomItem == 'dashboard'
                    ? Icons.dashboard
                    : Icons.dashboard_outlined,
                label: 'Dashboard',
                selected: _selectedBottomItem == 'dashboard',
                onTap: () => setState(() => _selectedBottomItem = 'dashboard'),
                width: width,
              ),
              const SizedBox(width: 40),
              _buildNavItem(
                icon: _selectedBottomItem == 'profile'
                    ? Icons.person
                    : Icons.person_outline,
                label: 'Profile',
                selected: _selectedBottomItem == 'profile',
                onTap: () => setState(() => _selectedBottomItem = 'profile'),
                width: width,
              ),
              _buildNavItem(
                icon: _selectedBottomItem == 'about'
                    ? Icons.info
                    : Icons.info_outline,
                label: 'About Us',
                selected: _selectedBottomItem == 'about',
                onTap: () => setState(() => _selectedBottomItem = 'about'),
                width: width,
              ),
            ],
          ),
        ),
      ),
    );
  }
  

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required double width,
  }) {
    const gradient = LinearGradient(
      colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
      stops: [0.30, 0.70, 1],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selected
                ? ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return gradient.createShader(bounds);
                    },
                    child: Icon(icon, size: scaleFont(24), color: Colors.white),
                  )
                : Icon(icon, size: scaleFont(24), color: Colors.grey),
            const SizedBox(height: 4),
            selected
                ? ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return gradient.createShader(bounds);
                    },
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: scaleFont(12),
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Will be overridden by shader
                      ),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: scaleFont(12),
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
