import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final int totalRequests;
  final int completedRequests;
  final int pendingRequests;

  const DashboardScreen({
    super.key,
    this.totalRequests = 12,
    this.completedRequests = 8,
    this.pendingRequests = 4,
  });

  double scaleFont(double size, BuildContext context) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: const Color(0xFF1E3A5F),
            fontWeight: FontWeight.bold,
            fontSize: scaleFont(22, context),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advisor Requests',
              style: TextStyle(
                fontSize: scaleFont(18, context),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3A5F),
              ),
            ),
            SizedBox(height: height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dashboardCard(
                  context,
                  title: 'Total',
                  count: totalRequests,
                  color: const Color(0xFF242C57),
                  icon: Icons.list_alt,
                ),
                _dashboardCard(
                  context,
                  title: 'Completed',
                  count: completedRequests,
                  color: const Color(0xFF169060),
                  icon: Icons.check_circle_outline,
                ),
                _dashboardCard(
                  context,
                  title: 'Pending',
                  count: pendingRequests,
                  color: const Color(0xFF164454),
                  icon: Icons.pending_actions,
                ),
              ],
            ),
            SizedBox(height: height * 0.04),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: scaleFont(18, context),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3A5F),
              ),
            ),
            SizedBox(height: height * 0.02),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/advisor_requests');
                    },
                    icon: const Icon(Icons.assignment, color: Colors.white),
                    label: const Text('View Requests'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF169060),
                      padding: EdgeInsets.symmetric(vertical: height * 0.025),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: TextStyle(
                        fontSize: scaleFont(16, context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Add new advisor request
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF242C57),
                      padding: EdgeInsets.symmetric(vertical: height * 0.025),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: TextStyle(
                        fontSize: scaleFont(16, context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(BuildContext context,
      {required String title, required int count, required Color color, required IconData icon}) {
    final width = MediaQuery.of(context).size.width;
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: width * 0.01),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}