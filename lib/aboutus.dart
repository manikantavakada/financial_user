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
          // Header Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF169060),
                  Color(0xFF175B58),
                  Color(0xFF19214F),
                ],
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
          // Content Section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.03,
              ),
              child: Column(
                children: [
                  // Main About Card
                  _buildGradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Logo/Icon
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF169060).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance,
                              size: 48,
                              color: Color(0xFF169060),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Title
                        Center(
                          child: Text(
                            'Financial Advisor',
                            style: TextStyle(
                              fontSize: width * 0.06,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A5F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Empowering your financial journey with expert advice and smart technology.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: const Color(0xFF169060),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Mission Card
                  _buildGradientCard(
                    child: _buildInfoSection(
                      'Our Mission',
                      'assets/Polar_FavIcon.png',
                      'To connect users with certified financial advisors and provide a seamless, secure, and insightful experience for all your financial planning needs.',
                      width,
                      context,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Features Card
                  _buildGradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Key Features', Icons.star, width),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          'Expert Advisors',
                          'Connect with certified financial professionals',
                          Icons.person_outline,
                        ),
                        _buildFeatureItem(
                          'Secure Platform',
                          'Bank-level security for your financial data',
                          Icons.security,
                        ),
                        _buildFeatureItem(
                          'Personalized Advice',
                          'Tailored recommendations for your goals',
                          Icons.lightbulb_outline,
                        ),
                        _buildFeatureItem(
                          '24/7 Support',
                          'Round-the-clock assistance when you need it',
                          Icons.support_agent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Contact Card
                  _buildGradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          'Contact Us',
                          Icons.contact_phone,
                          width,
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(
                          'Email',
                          'support@financialadvisor.com',
                          Icons.email,
                        ),
                        _buildContactItem(
                          'Phone',
                          '+1 234 567 8900',
                          Icons.phone,
                        ),
                        _buildContactItem(
                          'Address',
                          '123 Adelaide Street, Toowong, QLD 4066, Australia',
                          Icons.location_on,
                        ),
                        _buildContactItem(
                          'Business Hours',
                          'Monday - Friday: 9:00 AM - 6:00 PM',
                          Icons.schedule,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Company Info Card
                  _buildGradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          'Company Information',
                          Icons.business,
                          width,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Founded', '2017'),
                        _buildInfoRow('Headquarters', 'Brisbane, Australia'),
                        _buildInfoRow('Team Size', '8+ Professionals'),
                        _buildInfoRow('Clients Served', '10,000+'),
                        _buildInfoRow('App Version', '1.0.0'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Social Media Card
                  _buildGradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Follow Us', Icons.share, width),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSocialButton(
                              'LinkedIn',
                              Icons.business_center,
                              () {},
                            ),
                            _buildSocialButton(
                              'Twitter',
                              Icons.alternate_email,
                              () {},
                            ),
                            _buildSocialButton(
                              'Facebook',
                              Icons.facebook,
                              () {},
                            ),
                            _buildSocialButton(
                              'Instagram',
                              Icons.camera_alt,
                              () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Footer
                  Text(
                    '© 2025 Financial Advisor App. All rights reserved.',
                    style: TextStyle(
                      fontSize: width * 0.032,
                      color: const Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
          stops: [0.30, 0.70, 1],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    String iconPath,
    String content,
    double width,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF169060).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                iconPath,
                width: 20,
                height: 20,
                color: const Color(0xFF169060), // Tint to match theme
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: width * 0.045,
                color: const Color(0xFF242C57),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: width * 0.038,
            color: const Color(0xFF666666),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, double width) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF169060).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF169060), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: width * 0.045,
            color: const Color(0xFF242C57),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF169060), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF242C57),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF169060), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF242C57),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF242C57),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String name, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF169060).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF169060),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF242C57),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}