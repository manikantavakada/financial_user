import 'package:flutter/material.dart';

class AdvisorRequestsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> requests;

  const AdvisorRequestsScreen({
    super.key,
    this.requests = const [
      {
        'name': 'Retirement Planning',
        'status': 'Pending',
        'date': '2025-07-01',
        'reference': 'AR-001',
      },
      {
        'name': 'Investment Advice',
        'status': 'Completed',
        'date': '2025-06-15',
        'reference': 'AR-002',
      },
      {
        'name': 'Tax Consultation',
        'status': 'Pending',
        'date': '2025-06-20',
        'reference': 'AR-003',
      },
    ],
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return const Color(0xFF169060);
      case 'Pending':
        return const Color(0xFF164454);
      default:
        return Colors.grey;
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A5F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Advisor Requests',
          style: TextStyle(
            color: const Color(0xFF1E3A5F),
            fontWeight: FontWeight.bold,
            fontSize: width * 0.055,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF169060)),
            onPressed: () {
              // Add new advisor request
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: height * 0.02),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.01,
              ),
              leading: CircleAvatar(
                backgroundColor: _statusColor(req['status']),
                child: Icon(
                  req['status'] == 'Completed'
                      ? Icons.check
                      : Icons.hourglass_top,
                  color: Colors.white,
                ),
              ),
              title: Text(
                req['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A5F),
                  fontSize: width * 0.045,
                ),
              ),
              subtitle: Text(
                'Ref: ${req['reference']} • ${req['date']}',
                style: TextStyle(
                  color: const Color(0xFF666666),
                  fontSize: width * 0.035,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(req['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req['status'],
                  style: TextStyle(
                    color: _statusColor(req['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
