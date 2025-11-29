import 'package:flutter/material.dart';
import 'color_constants.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
      backgroundColor: AppColors.lightGray,
      body: Stack(
        children: [
          // Solid Primary Dark Background (Top 30%)
          Container(
            height: height * 0.30,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(scaleWidth(20, context)),
                bottomRight: Radius.circular(scaleWidth(20, context)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                SizedBox(height: scaleHeight(10, context)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(20, context)),
                    child: Column(
                      children: [
                        _buildMainAboutCard(context),
                        SizedBox(height: scaleHeight(10, context)),
                        _buildMissionCard(context),
                        SizedBox(height: scaleHeight(10, context)),
                        _buildFeaturesCard(context),
                        SizedBox(height: scaleHeight(10, context)),
                        _buildContactCard(context),
                        SizedBox(height: scaleHeight(10, context)),
                        _buildCompanyInfoCard(context),
                        SizedBox(height: scaleHeight(10, context)),
                        _buildSocialMediaCard(context),
                        SizedBox(height: scaleHeight(20, context)),
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
          color: AppColors.lightGray,
          fontSize: scaleFont(24, context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, required BuildContext context}) {
    return Container(
      decoration: BoxDecoration(
        color: textWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryDark.withOpacity(0.13),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(scaleWidth(20, context)),
      child: child,
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
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance,
              size: scaleFont(48, context),
              color: AppColors.lightGray,
            ),
          ),
          SizedBox(height: scaleHeight(20, context)),
          Text(
            'Financial Advisor',
            style: TextStyle(
              fontSize: scaleFont(24, context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: scaleHeight(12, context)),
          Text(
            'Empowering your financial journey with expert advice and smart technology.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: scaleFont(16, context),
              color: textGray,
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
              color: textGray,
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
            '256 bit encryption for your total peace of mind',
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
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.lightGray, size: scaleFont(20, context)),
        ),
        SizedBox(width: scaleWidth(12, context)),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: scaleFont(18, context),
            color: AppColors.primaryDark,
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
              color: AppColors.primaryDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryDark,
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
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: scaleHeight(4, context)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: scaleFont(14, context),
                    color: textGray,
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
              color: AppColors.primaryDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryDark,
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
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: scaleHeight(2, context)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: scaleFont(14, context),
                    color: textGray,
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
              color: textGray,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: scaleFont(14, context),
              color: AppColors.primaryDark,
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
          color: AppColors.primaryDark.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryDark, size: scaleFont(20, context)),
            SizedBox(height: scaleHeight(4, context)),
            Text(
              name,
              style: TextStyle(
                fontSize: scaleFont(10, context),
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDark,
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
        color: textGray,
      ),
      textAlign: TextAlign.center,
    );
  }
}
