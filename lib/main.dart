
import 'package:flutter/material.dart';
import 'aboutus.dart';
import 'add_advisor_request_screen.dart';
import 'advisor_request.dart';
import 'advisor_request_details.dart';
import 'edit_profile.dart';
import 'profile.dart';
import 'dashboard.dart';
import 'splash_screen.dart';
import 'intro_screen.dart';
import 'intro_screen2.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/intro1': (context) => const IntroScreen(),
        '/intro2': (context) => const IntroScreen2(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/advisor_requests': (context) => AdvisorRequestsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/about': (context) => AboutUsScreen(),
        '/advisor_request_detail': (context) => AdvisorRequestDetailScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/add_advisor_request': (context) => const AddAdvisorRequestScreen(),
      },
    );
  }
}
