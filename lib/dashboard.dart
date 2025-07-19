import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

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

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final clntId = prefs.getInt('client_id') ?? 17; // Fallback to 17 if not found

    final url = 'https://ss.singledeck.in/api/v1/adviser/client-dashboard-counts/?clnt_id=$clntId';
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

  double scaleFont(double size, BuildContext context) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  Widget _buildShimmerLoading(BuildContext context, double width, double height) {
    return Column(
      children: [
        // Original Header (No Shimmer)
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
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: scaleFont(22, context),
              ),
            ),
          ),
        ),
        // Shimmer Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Shimmer
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Color(0xFF169060).withOpacity(0.5),
                    child: Container(
                      width: width * 0.6,
                      height: scaleFont(18, context),
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                // Dashboard Cards Shimmer
                Row(
                  children: [
                    _buildShimmerCard(context, width, const Color(0xFF242C57)),
                    SizedBox(width: width * 0.02),
                    _buildShimmerCard(context, width, const Color(0xFF169060)),
                    SizedBox(width: width * 0.02),
                    _buildShimmerCard(context, width, const Color(0xFF164454)),
                  ],
                ),
                SizedBox(height: height * 0.03),
                // Chart Section Shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Color(0xFF169060).withOpacity(0.5),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: width * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chart Title
                          Container(
                            width: width * 0.5,
                            height: scaleFont(16, context),
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          // Summary Chips
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildShimmerChip(context, width),
                              _buildShimmerChip(context, width),
                              _buildShimmerChip(context, width),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Pie Chart Placeholder
                          Container(
                            height: 150,
                            width: width * 0.5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Shimmer for Dashboard Card
  Widget _buildShimmerCard(BuildContext context, double width, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: width * 0.04, horizontal: width * 0.02),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Color(0xFF169060).withOpacity(0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width * 0.08,
                height: width * 0.08,
                color: Colors.white,
              ),
              SizedBox(height: width * 0.02),
              Container(
                width: width * 0.2,
                height: scaleFont(20, context),
                color: Colors.white,
              ),
              SizedBox(height: width * 0.01),
              Container(
                width: width * 0.25,
                height: scaleFont(12, context),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer for Summary Chip
  Widget _buildShimmerChip(BuildContext context, double width) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: width * 0.15,
                height: scaleFont(11, context),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: width * 0.1,
            height: scaleFont(16, context),
            color: Colors.white,
          ),
          const SizedBox(height: 4),
          Container(
            width: width * 0.1,
            height: scaleFont(10, context),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading(context, width, height);
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
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: scaleFont(22, context),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                        child: Text(
                          'Advisor Requests Overview',
                          style: TextStyle(
                            fontSize: scaleFont(18, context),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E3A5F),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),

                      // Dashboard Cards
                      Row(
                        children: [
                          _dashboardCard(
                            context,
                            title: 'Total',
                            count: total,
                            color: const Color(0xFF242C57),
                            icon: Icons.list_alt,
                          ),
                          SizedBox(width: width * 0.02),
                          _dashboardCard(
                            context,
                            title: 'Completed',
                            count: completed,
                            color: const Color(0xFF169060),
                            icon: Icons.check_circle_outline,
                          ),
                          SizedBox(width: width * 0.02),
                          _dashboardCard(
                            context,
                            title: 'Pending',
                            count: pending,
                            color: const Color(0xFF164454),
                            icon: Icons.pending_actions,
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.03),

                      // Chart Section
                      _buildChartSection(context, total, completed, pending),
                      SizedBox(height: height * 0.02),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, int totalRequests, int completedRequests, int pendingRequests) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: width * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section Title
            Text(
              'Requests Distribution',
              style: TextStyle(
                fontSize: scaleFont(16, context),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 16),

            // Request Summary Chips
            _buildRequestSummary(context, totalRequests, completedRequests, pendingRequests),
            const SizedBox(height: 20),

            // Pie Chart
            totalRequests > 0 
                ? _buildCompactPieChart(context, completedRequests, pendingRequests)
                : _buildEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSummary(BuildContext context, int totalRequests, int completedRequests, int pendingRequests) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryChip(
          'Total',
          totalRequests,
          const Color(0xFF242C57),
          context,
          totalRequests,
        ),
        _buildSummaryChip(
          'Completed',
          completedRequests,
          const Color(0xFF169060),
          context,
          totalRequests,
        ),
        _buildSummaryChip(
          'Pending',
          pendingRequests,
          const Color(0xFF164454),
          context,
          totalRequests,
        ),
      ],
    );
  }

  Widget _buildSummaryChip(String label, int value, Color color, BuildContext context, int totalRequests) {
    final percentage = totalRequests > 0 ? (value / totalRequests * 100) : 0.0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: scaleFont(11, context),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: scaleFont(16, context),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (label != 'Total')
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: scaleFont(10, context),
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactPieChart(BuildContext context, int completedRequests, int pendingRequests) {
    final width = MediaQuery.of(context).size.width;
    
    return Container(
      height: width * 0.5, // Responsive height based on width
      constraints: const BoxConstraints(
        maxHeight: 200,
        minHeight: 150,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              startDegreeOffset: -90,
              sections: _buildPieChartSections(completedRequests, pendingRequests),
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(int completedRequests, int pendingRequests) {
    final sections = <PieChartSectionData>[];
    
    if (completedRequests > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFF169060),
          value: completedRequests.toDouble(),
          title: '',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 0),
        ),
      );
    }
    
    if (pendingRequests > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFF164454),
          value: pendingRequests.toDouble(),
          title: '',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 0),
        ),
      );
    }
    
    return sections;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No requests data available',
            style: TextStyle(
              fontSize: scaleFont(14, context),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create your first advisor request',
            style: TextStyle(
              fontSize: scaleFont(12, context),
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: width * 0.04, horizontal: width * 0.02),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: Colors.white, 
              size: width * 0.08,
            ),
            SizedBox(height: width * 0.02),
            Text(
              '$count',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: scaleFont(20, context),
              ),
            ),
            SizedBox(height: width * 0.01),
            Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: scaleFont(12, context),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}