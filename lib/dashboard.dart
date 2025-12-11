import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

import 'color_constants.dart';

class DashboardScreen extends StatefulWidget {
  final String? accessToken;
  final VoidCallback? onUnauthorized;

  const DashboardScreen({
    super.key,
    this.accessToken,
    this.onUnauthorized,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = _fetchDashboardData();
  }

  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  double scaleWidth(double width) {
    return width * MediaQuery.of(context).size.width / 375;
  }

  double scaleHeight(double height) {
    return height * MediaQuery.of(context).size.height / 812;
  }

  Future<void> _logout(String message) async {
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

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final clntId = prefs.getInt('client_id');
    final token = prefs.getString('access_token');
    
    print(token);

    if (token == null || token.isEmpty || clntId == null) {
      _logout('Session expired. Please login again.');
      return _fallbackData();
    }

    final url = 'https://ds.singledeck.in/api/v1/adviser/client-dashboard-counts/?clnt_id=$clntId';
    debugPrint('📡 Fetching from: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'sessiontoken': token,
          'sessiontype': 'CLNT',
        },
      ).timeout(const Duration(seconds: 60));

      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode == 401) {
        _logout('Session expired. Please login again.');
        return _fallbackData();
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('✅ Body parsed: $jsonData');
        
        if (jsonData['status'] == 'success' && jsonData['data'] != null) {
          return {
            'total_requests': jsonData['data']['total_requests'] ?? 0,
            'completed_requests': jsonData['data']['completed_requests'] ?? 0,
            'pending_requests': jsonData['data']['pending_requests'] ?? 0,
          };
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error: $e');
      debugPrint('Stack: $stackTrace');
    }

    return _fallbackData();
  }

  Map<String, dynamic> _fallbackData() => {
        "total_requests": 0,
        "completed_requests": 0,
        "pending_requests": 0,
      };

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Stack(
        children: [
          Container(
            height: height * 0.35,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(scaleWidth(30)),
                bottomRight: Radius.circular(scaleWidth(30)),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: scaleHeight(20)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<Map<String, dynamic>>(
                          future: _dashboardData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return _buildShimmerCards();
                            }

                            final data = snapshot.data ?? _fallbackData();
                            final int total = data['total_requests'] ?? 0;
                            final int completed = data['completed_requests'] ?? 0;
                            final int pending = data['pending_requests'] ?? 0;

                            return Column(
                              children: [
                                _buildDashboardCards(total, completed, pending),
                                SizedBox(height: scaleHeight(24)),
                                _buildChartCard(total, completed, pending),
                              ],
                            );
                          },
                        ),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(scaleWidth(20)),
      child: Text(
        'Dashboard',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.lightGray,
          fontSize: scaleFont(24),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDashboardCards(int total, int completed, int pending) {
    return Row(
      children: [
        Expanded(
          child: _buildDashboardCard(
            title: 'Total',
            count: total,
            icon: Icons.assignment,
            color: AppColors.lightGray.withOpacity(0.8), // ✅ Lighter opacity
          ),
        ),
        SizedBox(width: scaleWidth(12)),
        Expanded(
          child: _buildDashboardCard(
            title: 'Completed',
            count: completed,
            icon: Icons.check_circle,
            color: AppColors.green.withOpacity(0.8), // ✅ Lighter opacity
          ),
        ),
        SizedBox(width: scaleWidth(12)),
        Expanded(
          child: _buildDashboardCard(
            title: 'Pending',
            count: pending,
            icon: Icons.pending_actions,
            color: AppColors.blue.withOpacity(0.8), // ✅ Lighter opacity
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(scaleWidth(16)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2), // ✅ Lighter shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryDark, size: scaleFont(32)),
          SizedBox(height: scaleHeight(8)),
          Text(
            '$count',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: scaleFont(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: scaleHeight(4)),
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryDark.withOpacity(0.8),
              fontSize: scaleFont(12),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(int total, int completed, int pending) {
    return Container(
      padding: EdgeInsets.all(scaleWidth(24)),
      decoration: BoxDecoration(
        color: textWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(scaleWidth(8)),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: AppColors.lightGray,
                  size: scaleFont(20),
                ),
              ),
              SizedBox(width: scaleWidth(12)),
              Text(
                'Request Overview',
                style: TextStyle(
                  fontSize: scaleFont(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: scaleHeight(20)),
          // ✅ Equal width summary chips using Expanded
          Row(
            children: [
              Expanded(child: _buildSummaryChip('Total', total, AppColors.yellow)),
              SizedBox(width: scaleWidth(8)),
              Expanded(child: _buildSummaryChip('Completed', completed, AppColors.green)),
              SizedBox(width: scaleWidth(8)),
              Expanded(child: _buildSummaryChip('Pending', pending, AppColors.blue)),
            ],
          ),
          SizedBox(height: scaleHeight(24)),
          total > 0 ? _buildPieChart(completed, pending) : _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, int value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(8), // ✅ Reduced padding for better fit
        vertical: scaleHeight(8),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // ✅ Lighter background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5), // ✅ Lighter border
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // ✅ Center align
            children: [
              Container(
                width: scaleWidth(8),
                height: scaleWidth(8),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: scaleWidth(4)),
              Flexible( // ✅ Make text flexible
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: scaleFont(11),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: scaleHeight(4)),
          Text(
            '$value',
            style: TextStyle(
              fontSize: scaleFont(18),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(int completed, int pending) {
    final total = completed + pending;
    return SizedBox(
      height: scaleHeight(200),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: scaleWidth(60),
          startDegreeOffset: -90,
          sections: [
            if (completed > 0)
              PieChartSectionData(
                color: AppColors.green,
                value: completed.toDouble(),
                title: '${((completed / total) * 100).toStringAsFixed(1)}%',
                radius: scaleWidth(40),
                titleStyle: TextStyle(
                  fontSize: scaleFont(12),
                  fontWeight: FontWeight.bold,
                  color: textWhite,
                ),
              ),
            if (pending > 0)
              PieChartSectionData(
                color: AppColors.blue,
                value: pending.toDouble(),
                title: '${((pending / total) * 100).toStringAsFixed(1)}%',
                radius: scaleWidth(40),
                titleStyle: TextStyle(
                  fontSize: scaleFont(12),
                  fontWeight: FontWeight.bold,
                  color: textWhite,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
  return Container(
    height: scaleHeight(200),
    alignment: Alignment.center, // ✅ Center align content
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center horizontally
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.pie_chart_outline, size: scaleFont(60), color: textGray),
        SizedBox(height: scaleHeight(16)),
        Text(
          'No data available',
          style: TextStyle(
            fontSize: scaleFont(16),
            color: textGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: scaleHeight(8)),
        Text(
          'Create your first advisor request',
          style: TextStyle(fontSize: scaleFont(14), color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}


  Widget _buildShimmerCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildShimmerCard()),
            SizedBox(width: scaleWidth(12)),
            Expanded(child: _buildShimmerCard()),
            SizedBox(width: scaleWidth(12)),
            Expanded(child: _buildShimmerCard()),
          ],
        ),
        SizedBox(height: scaleHeight(24)),
        _buildShimmerChart(),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGray,
      highlightColor: textWhite,
      child: Container(
        padding: EdgeInsets.all(scaleWidth(16)),
        decoration: BoxDecoration(
          color: textWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: scaleWidth(32),
              height: scaleWidth(32),
              decoration: BoxDecoration(
                color: textWhite,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: scaleHeight(8)),
            Container(
              width: scaleWidth(40),
              height: scaleHeight(24),
              decoration: BoxDecoration(
                color: textWhite,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: scaleHeight(4)),
            Container(
              width: scaleWidth(60),
              height: scaleHeight(12),
              decoration: BoxDecoration(
                color: textWhite,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerChart() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGray,
      highlightColor: textWhite,
      child: Container(
        padding: EdgeInsets.all(scaleWidth(24)),
        decoration: BoxDecoration(
          color: textWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: scaleWidth(28),
                  height: scaleWidth(28),
                  decoration: BoxDecoration(
                    color: textWhite,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: scaleWidth(12)),
                Container(
                  width: scaleWidth(120),
                  height: scaleHeight(18),
                  decoration: BoxDecoration(
                    color: textWhite,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleHeight(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShimmerChip(),
                _buildShimmerChip(),
                _buildShimmerChip(),
              ],
            ),
            SizedBox(height: scaleHeight(24)),
            Center(
              child: Container(
                width: scaleWidth(150),
                height: scaleWidth(150),
                decoration: const BoxDecoration(
                  color: textWhite,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerChip() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(12),
        vertical: scaleHeight(8),
      ),
      decoration: BoxDecoration(
        color: textWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: scaleWidth(60),
            height: scaleHeight(12),
            decoration: BoxDecoration(
              color: textWhite,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: scaleHeight(4)),
          Container(
            width: scaleWidth(30),
            height: scaleHeight(18),
            decoration: BoxDecoration(
              color: textWhite,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
