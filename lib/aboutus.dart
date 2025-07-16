import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
                stops: [0.30, 0.70, 1],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Center(
              child: Text(
                'About Us',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.055,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * 0.07, vertical: height * 0.04),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(width * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Advisor App',
                        style: TextStyle(
                          fontSize: width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A5F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Empowering your financial journey with expert advice and smart technology.',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: const Color(0xFF169060),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Our Mission',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.045,
                          color: const Color(0xFF242C57),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'To connect users with certified financial advisors and provide a seamless, secure, and insightful experience for all your financial planning needs.',
                        style: TextStyle(
                          fontSize: width * 0.038,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Contact Us',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.045,
                          color: const Color(0xFF242C57),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Email: support@financialadvisor.com\nPhone: +1 234 567 8900',
                        style: TextStyle(
                          fontSize: width * 0.038,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
