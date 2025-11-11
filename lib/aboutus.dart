import 'package:flutter/material.dart';

import 'color_constants.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  // Responsive scaling functions
  double scaleFont(double size, BuildContext context) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  double scaleWidth(double width, BuildContext context) {
    return width * MediaQuery.of(context).size.width / 375;
  }

  double scaleHeight(double height, BuildContext context) {
    return height * MediaQuery.of(context).size.height / 812;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient (35% from top)
          Container(
            height: height * 0.30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(scaleWidth(20, context)),
                bottomRight: Radius.circular(scaleWidth(20, context)),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header Section
                _buildHeader(context),

                SizedBox(height: scaleHeight(10, context)),

                // Content Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleWidth(20, context),
                    ),
                    child: Column(
                      children: [
                        // Main About Card
                        _buildMainAboutCard(context),

                        SizedBox(height: scaleHeight(10, context)),

                        // Mission Card
                        _buildMissionCard(context),

                        SizedBox(height: scaleHeight(10, context)),

                        // Features Card
                        _buildFeaturesCard(context),

                        SizedBox(height: scaleHeight(10, context)),

                        // Contact Card
                        _buildContactCard(context),

                        SizedBox(height: scaleHeight(10, context)),

                        // Company Info Card
                        _buildCompanyInfoCard(context),

                        SizedBox(height: scaleHeight(10, context)),

                        // Social Media Card
                        _buildSocialMediaCard(context),

                        SizedBox(height: scaleHeight(20, context)),

                        // Footer
                        _buildFooter(context),

                        SizedBox(height: scaleHeight(30, context)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(scaleWidth(20, context)),
      child: Text(
        'About Us',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: scaleFont(24, context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, required BuildContext context}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(scaleWidth(3, context)), // Gradient border width
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(scaleWidth(20, context)),
        child: child,
      ),
    );
  }

  Widget _buildMainAboutCard(BuildContext context) {
    return _buildCard(
      context: context,
      child: Column(
        children: [
          // App Logo/Icon
          Container(
            padding: EdgeInsets.all(scaleWidth(20, context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance,
              size: scaleFont(48, context),
              color: Colors.white,
            ),
          ),

          SizedBox(height: scaleHeight(20, context)),

          // Title
          Text(
            'Financial Advisor',
            style: TextStyle(
              fontSize: scaleFont(24, context),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: scaleHeight(12, context)),

          Text(
            'Empowering your financial journey with expert advice and smart technology.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: scaleFont(16, context),
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context) {
    return _buildCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Our Mission', Icons.flag, context),

          SizedBox(height: scaleHeight(16, context)),

          Text(
            'To connect users with certified financial advisors and provide a seamless, secure, and insightful experience for all your financial planning needs.',
            style: TextStyle(
              fontSize: scaleFont(15, context),
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    return _buildCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Key Features', Icons.star, context),

          SizedBox(height: scaleHeight(16, context)),

          _buildFeatureItem(
            'Expert Advisors',
            'Connect with certified financial professionals',
            Icons.person_outline,
            context,
          ),
          _buildFeatureItem(
            'Secure Platform',
            'Bank-level security for your financial data',
            Icons.security,
            context,
          ),
          _buildFeatureItem(
            'Personalized Advice',
            'Tailored recommendations for your goals',
            Icons.lightbulb_outline,
            context,
          ),
          _buildFeatureItem(
            '24/7 Support',
            'Round-the-clock assistance when you need it',
            Icons.support_agent,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return _buildCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Contact Us', Icons.contact_phone, context),

          SizedBox(height: scaleHeight(16, context)),

          _buildContactItem(
            'Email',
            'support@financialadvisor.com',
            Icons.email,
            context,
          ),
          _buildContactItem('Phone', '+1 234 567 8900', Icons.phone, context),
          _buildContactItem(
            'Address',
            '123 Adelaide Street, Toowong, QLD 4066, Australia',
            Icons.location_on,
            context,
          ),
          _buildContactItem(
            'Business Hours',
            'Monday - Friday: 9:00 AM - 6:00 PM',
            Icons.schedule,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoCard(BuildContext context) {
    return _buildCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Company Information', Icons.business, context),

          SizedBox(height: scaleHeight(16, context)),

          _buildInfoRow('Founded', '2017', context),
          _buildInfoRow('Headquarters', 'Brisbane, Australia', context),
          _buildInfoRow('Team Size', '8+ Professionals', context),
          _buildInfoRow('Clients Served', '10,000+', context),
          _buildInfoRow('App Version', '1.0.0', context),
        ],
      ),
    );
  }

  Widget _buildSocialMediaCard(BuildContext context) {
    return _buildCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Follow Us', Icons.share, context),

          SizedBox(height: scaleHeight(16, context)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                'LinkedIn',
                Icons.business_center,
                () {},
                context,
              ),
              _buildSocialButton(
                'Twitter',
                Icons.alternate_email,
                () {},
                context,
              ),
              _buildSocialButton('Facebook', Icons.facebook, () {}, context),
              _buildSocialButton('Instagram', Icons.camera_alt, () {}, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(scaleWidth(8, context)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: scaleFont(20, context)),
        ),

        SizedBox(width: scaleWidth(12, context)),

        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: scaleFont(18, context),
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    String title,
    String description,
    IconData icon,
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: scaleHeight(16, context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(scaleWidth(8, context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  secondaryColor.withOpacity(0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: scaleFont(20, context),
            ),
          ),

          SizedBox(width: scaleWidth(12, context)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: scaleFont(16, context),
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: scaleHeight(4, context)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: scaleFont(14, context),
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: scaleHeight(16, context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(scaleWidth(6, context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  secondaryColor.withOpacity(0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: scaleFont(18, context),
            ),
          ),

          SizedBox(width: scaleWidth(12, context)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: scaleFont(14, context),
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: scaleHeight(2, context)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: scaleFont(14, context),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: scaleHeight(12, context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: scaleFont(14, context),
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: scaleFont(14, context),
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    String name,
    IconData icon,
    VoidCallback onTap,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: scaleWidth(60, context),
        padding: EdgeInsets.symmetric(
          vertical: scaleHeight(12, context),
          horizontal: scaleWidth(8, context),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.1),
              secondaryColor.withOpacity(0.1),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primaryColor, size: scaleFont(20, context)),
            SizedBox(height: scaleHeight(4, context)),
            Text(
              name,
              style: TextStyle(
                fontSize: scaleFont(10, context),
                fontWeight: FontWeight.w500,
                color: Colors.black87,
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

  Widget _buildFooter(BuildContext context) {
    return Text(
      '© 2025 Financial Advisor App. All rights reserved.',
      style: TextStyle(
        fontSize: scaleFont(12, context),
        color: Colors.grey[500],
      ),
      textAlign: TextAlign.center,
    );
  }
}
