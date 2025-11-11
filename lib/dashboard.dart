import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

import 'color_constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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

  // Responsive scaling functions
  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  double scaleWidth(double width) {
    return width * MediaQuery.of(context).size.width / 375;
  }

  double scaleHeight(double height) {
    return height * MediaQuery.of(context).size.height / 812;
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final clntId = prefs.getInt('client_id') ?? 17;

    final url =
        'https://ds.singledeck.in/api/v1/adviser/client-dashboard-counts/?clnt_id=$clntId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        return jsonData['data'];
      }
    }
    // Fallback data if API fails
    return {
      "total_requests": 3,
      "completed_requests": 1,
      "pending_requests": 2,
    };
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
            height: height * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(scaleWidth(30)),
                bottomRight: Radius.circular(scaleWidth(30)),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                SizedBox(height: scaleHeight(20)),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard Cards
                        FutureBuilder<Map<String, dynamic>>(
                          future: _dashboardData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return _buildShimmerCards();
                            }

                            final data = snapshot.data ?? {
                              "total_requests": 3,
                              "completed_requests": 1,
                              "pending_requests": 2,
                            };

                            final int total = data['total_requests'] ?? 3;
                            final int completed = data['completed_requests'] ?? 1;
                            final int pending = data['pending_requests'] ?? 2;

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
          color: Colors.white,
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
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SizedBox(width: scaleWidth(12)),
        Expanded(
          child: _buildDashboardCard(
            title: 'Completed',
            count: completed,
            icon: Icons.check_circle,
            gradient: LinearGradient(
              colors: [Colors.green[600]!, Colors.green[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SizedBox(width: scaleWidth(12)),
        Expanded(
          child: _buildDashboardCard(
            title: 'Pending',
            count: pending,
            icon: Icons.pending_actions,
            gradient: LinearGradient(
              colors: [Colors.orange[600]!, Colors.orange[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required int count,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(scaleWidth(16)),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: scaleFont(32),
          ),
          SizedBox(height: scaleHeight(8)),
          Text(
            '$count',
            style: TextStyle(
              color: Colors.white,
              fontSize: scaleFont(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: scaleHeight(4)),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(scaleWidth(8)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: Colors.white,
                  size: scaleFont(20),
                ),
              ),
              SizedBox(width: scaleWidth(12)),
              Text(
                'Request Overview',
                style: TextStyle(
                  fontSize: scaleFont(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          SizedBox(height: scaleHeight(20)),
          
          // Summary Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryChip('Total', total, Colors.blue[600]!),
              _buildSummaryChip('Completed', completed, Colors.green[600]!),
              _buildSummaryChip('Pending', pending, Colors.orange[600]!),
            ],
          ),
          
          SizedBox(height: scaleHeight(24)),
          
          // Pie Chart or Empty State
          total > 0 
              ? _buildPieChart(completed, pending)
              : _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, int value, Color color) {
    final total = value;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(12),
        vertical: scaleHeight(8),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: scaleWidth(8),
                height: scaleWidth(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: scaleWidth(6)),
              Text(
                label,
                style: TextStyle(
                  fontSize: scaleFont(12),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
    
    return Container(
      height: scaleHeight(200),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: scaleWidth(60),
          startDegreeOffset: -90,
          sections: [
            if (completed > 0)
              PieChartSectionData(
                color: Colors.green[600]!,
                value: completed.toDouble(),
                title: '${((completed / total) * 100).toStringAsFixed(1)}%',
                radius: scaleWidth(40),
                titleStyle: TextStyle(
                  fontSize: scaleFont(12),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (pending > 0)
              PieChartSectionData(
                color: Colors.orange[600]!,
                value: pending.toDouble(),
                title: '${((pending / total) * 100).toStringAsFixed(1)}%',
                radius: scaleWidth(40),
                titleStyle: TextStyle(
                  fontSize: scaleFont(12),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: scaleFont(60),
            color: Colors.grey[400],
          ),
          SizedBox(height: scaleHeight(16)),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: scaleFont(16),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: scaleHeight(8)),
          Text(
            'Create your first advisor request',
            style: TextStyle(
              fontSize: scaleFont(14),
              color: Colors.grey[500],
            ),
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
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(scaleWidth(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: scaleWidth(32),
              height: scaleWidth(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: scaleHeight(8)),
            Container(
              width: scaleWidth(40),
              height: scaleHeight(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: scaleHeight(4)),
            Container(
              width: scaleWidth(60),
              height: scaleHeight(12),
              decoration: BoxDecoration(
                color: Colors.white,
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
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(scaleWidth(24)),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: scaleWidth(12)),
                Container(
                  width: scaleWidth(120),
                  height: scaleHeight(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                decoration: BoxDecoration(
                  color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: scaleWidth(60),
            height: scaleHeight(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: scaleHeight(4)),
          Container(
            width: scaleWidth(30),
            height: scaleHeight(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
