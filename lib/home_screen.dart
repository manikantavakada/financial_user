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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _selectedBottomItem = 'requests';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  void _onFabPressed() {
    // Start the animation
    _animationController.forward().then((_) {
      // Reset animation after completion
      _animationController.reset();
    });

    // Add your existing FAB functionality here
    if (_selectedBottomItem == 'requests') {
      // Your existing logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add new request in Advisor Request Screen!'),
          backgroundColor: Color(0xFF169060),
          duration: Duration(milliseconds: 1500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: _getCurrentTab(),
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 0.5, // Half rotation for subtle effect
              child: Container(
                width: width * 0.17,
                height: width * 0.17,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
                    stops: [0.30, 0.70, 1],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2 * _scaleAnimation.value),
                      blurRadius: 15 * _scaleAnimation.value,
                      offset: Offset(0, 5 * _scaleAnimation.value),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 30 + (10 * (_scaleAnimation.value - 1)), // Scale icon size too
                      color: Colors.black,
                    ),
                    onPressed: _onFabPressed,
                  ),
                ),
              ),
            ),
          );
        },
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
