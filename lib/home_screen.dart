import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'aboutus.dart';
import 'add_advisor_request_screen.dart';
import 'advisor_request.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'package:financial_user/color_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  String _selectedBottomItem = 'requests';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  // Session handling variables
  Timer? _sessionTimer;
  Timer? _tokenRefreshTimer;
  DateTime? _lastInteractionTime;
  static const Duration _sessionTimeout = Duration(minutes: 30);
  static const Duration _tokenRefreshInterval = Duration(minutes: 50);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Initialize session management
    _initSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _sessionTimer?.cancel();
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }

  // Session Management Methods
  void _initSession() {
    _checkTokenValidity();
    _startSessionTimer();
    _startTokenRefreshTimer();
    _updateLastInteraction();
  }

  Future<void> _checkTokenValidity() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn || accessToken == null || accessToken.isEmpty) {
      _logout('Session expired. Please login again.');
    }
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_lastInteractionTime != null) {
        final inactiveDuration = DateTime.now().difference(_lastInteractionTime!);
        if (inactiveDuration >= _sessionTimeout) {
          _logout('Session expired due to inactivity.');
        }
      }
    });
  }

  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(_tokenRefreshInterval, (timer) async {
      await _refreshToken();
    });
  }

  Future<void> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) {
        _logout('Session expired. Please login again.');
        return;
      }

      // TODO: Implement your token refresh API call here
      // Example:
      // final response = await http.post(
      //   Uri.parse('https://ds.singledeck.in/api/v1/clients/token-refresh/'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'refresh': refreshToken}),
      // );
      // 
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   await prefs.setString('access_token', data['access']);
      // } else {
      //   _logout('Session expired. Please login again.');
      // }
    } catch (e) {
      print('Token refresh failed: $e');
    }
  }

  void _updateLastInteraction() {
    setState(() {
      _lastInteractionTime = DateTime.now();
    });
  }

  Future<void> _logout(String message) async {
    _sessionTimer?.cancel();
    _tokenRefreshTimer?.cancel();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused) {
      _updateLastInteraction();
    } else if (state == AppLifecycleState.resumed) {
      _checkTokenValidity();
      _updateLastInteraction();
    }
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
        return AdvisorRequestsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: _updateLastInteraction,
      onPanDown: (_) => _updateLastInteraction(),
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        body: _getCurrentTab(),
        floatingActionButton: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 0.5,
                child: Container(
                  width: width * 0.17,
                  height: width * 0.17,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.3 * _scaleAnimation.value),
                        blurRadius: 15 * _scaleAnimation.value,
                        offset: Offset(0, 5 * _scaleAnimation.value),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: textWhite,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        size: 30 + (10 * (_scaleAnimation.value - 1)),
                        color: AppColors.primaryDark,
                      ),
                      onPressed: () async {
                        _updateLastInteraction();
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddAdvisorRequestScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: textWhite,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          elevation: 8,
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
                    _updateLastInteraction();
                    setState(() => _selectedBottomItem = 'requests');
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
                    _updateLastInteraction();
                    setState(() => _selectedBottomItem = 'dashboard');
                  },
                  width: width,
                ),
                const SizedBox(width: 40),
                _buildNavItem(
                  icon: _selectedBottomItem == 'profile'
                      ? Icons.person
                      : Icons.person_outline,
                  label: 'Profile',
                  selected: _selectedBottomItem == 'profile',
                  onTap: () {
                    _updateLastInteraction();
                    setState(() => _selectedBottomItem = 'profile');
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
                    _updateLastInteraction();
                    setState(() => _selectedBottomItem = 'about');
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
        splashColor: AppColors.primaryDark.withOpacity(0.2),
        highlightColor: AppColors.primaryDark.withOpacity(0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: scaleFont(24),
              color: selected ? AppColors.primaryDark : textGray,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: scaleFont(12),
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? AppColors.primaryDark : textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
