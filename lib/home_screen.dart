import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedBottomItem = 'dashboard';
  bool _backPressedOnce = false;

  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  Future<bool> _handleBackPress() async {
    if (_backPressedOnce) {
      return true;
    }
    setState(() {
      _backPressedOnce = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Press again to exit'), duration: Duration(seconds: 2)),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _backPressedOnce = false;
        });
      }
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Column(
          children: [
            // Top Bar
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.03),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Text(
                'Hello ! Jim',
                style: TextStyle(
                  fontSize: scaleFont(22),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A5F),
                ),
              ),
            ),
            // Main content placeholder
            const Expanded(child: SizedBox()),
          ],
        ),
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
              onPressed: () {},
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
                  onTap: () {
                    setState(() => _selectedBottomItem = 'requests');
                    if (ModalRoute.of(context)?.settings.name != '/advisor_requests') {
                      Navigator.pushReplacementNamed(context, '/advisor_requests');
                    }
                  },
                  width: width,
                ),
                _buildNavItem(
                  icon: _selectedBottomItem == 'dashboard'
                      ? Icons.dashboard
                      : Icons.dashboard_outlined,
                  label: 'Dashboard',
                  selected: _selectedBottomItem == 'dashboard',
                  onTap: () {
                    setState(() => _selectedBottomItem = 'dashboard');
                    if (ModalRoute.of(context)?.settings.name != '/dashboard') {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    }
                  },
                  width: width,
                ),
                const SizedBox(width: 40), // Space for FAB
                _buildNavItem(
                  icon: _selectedBottomItem == 'profile'
                      ? Icons.person
                      : Icons.person_outline,
                  label: 'Profile',
                  selected: _selectedBottomItem == 'profile',
                  onTap: () {
                    setState(() => _selectedBottomItem = 'profile');
                    if (ModalRoute.of(context)?.settings.name != '/profile') {
                      Navigator.pushReplacementNamed(context, '/profile');
                    }
                  },
                  width: width,
                ),
                _buildNavItem(
                  icon: _selectedBottomItem == 'about'
                      ? Icons.info
                      : Icons.info_outline,
                  label: 'About Us',
                  selected: _selectedBottomItem == 'about',
                  onTap: () {
                    setState(() => _selectedBottomItem = 'about');
                    if (ModalRoute.of(context)?.settings.name != '/about') {
                      Navigator.pushReplacementNamed(context, '/about');
                    }
                  },
                  width: width,
                ),
              ],
            ),
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: scaleFont(24),
              color: selected ? const Color(0xFF1E3A5F) : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: scaleFont(12),
                color: selected ? const Color(0xFF1E3A5F) : Colors.grey,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}