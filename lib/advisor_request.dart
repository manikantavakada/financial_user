import 'package:flutter/material.dart';

class AdvisorRequestsScreen extends StatefulWidget {
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

  @override
  State<AdvisorRequestsScreen> createState() => _AdvisorRequestsScreenState();
}

class _AdvisorRequestsScreenState extends State<AdvisorRequestsScreen> {
  String _selectedBottomItem = 'requests';

  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

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

  void _showAddRequestDialog() {
    String requestName = '';
    bool advisorKnown = false;
    String advisorRef = '';
    bool showAdvisorRef = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Advisor Request'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Request Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) => requestName = val,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Do you know the advisor?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: advisorKnown,
                          onChanged: (val) {
                            setState(() {
                              advisorKnown = true;
                              showAdvisorRef = true;
                            });
                          },
                        ),
                        const Text('Yes'),
                        Radio<bool>(
                          value: false,
                          groupValue: advisorKnown,
                          onChanged: (val) {
                            setState(() {
                              advisorKnown = false;
                              showAdvisorRef = false;
                              advisorRef = '';
                            });
                          },
                        ),
                        const Text('No'),
                      ],
                    ),
                    if (showAdvisorRef)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Advisor Reference Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (val) => advisorRef = val,
                        ),
                      ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                GestureDetector(
                  onTap: () {
                    if (requestName.trim().isEmpty) return;
                    setState(() {
                      widget.requests.insert(0, {
                        'name': requestName,
                        'status': 'Pending',
                        'date': DateTime.now().toString().substring(0, 10),
                        'reference': 'AR-${widget.requests.length + 1}'.padLeft(6, '0'),
                        'advisorKnown': advisorKnown,
                        'advisorRef': advisorRef,
                      });
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF169060), Color(0xFF1E3A5F)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
            onPressed: _showAddRequestDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        itemCount: widget.requests.length,
        itemBuilder: (context, index) {
          final req = widget.requests[index];
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
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/advisor_request_detail',
                  arguments: req,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        width: width * 0.17,
        height: width * 0.17,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
            stops: [0.30, 0.70, 1],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add, size: 30, color: Colors.black),
            onPressed: () {
              // Add new advisor request
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: height * 0.09,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: _selectedBottomItem == 'requests'
                    ? Icons.assignment
                    : Icons.assignment_outlined,
                label: 'Requests',
                selected: _selectedBottomItem == 'requests',
                onTap: () {
                  setState(() => _selectedBottomItem = 'requests');
                  // Already on this page, do nothing or maybe refresh
                },
                width: width,
              ),
              _buildNavItem(
                icon: _selectedBottomItem == 'dashboard'
                    ? Icons.dashboard
                    : Icons.dashboard_outlined,
                label: 'Dashboard',
                selected: _selectedBottomItem == 'dashboard',
                onTap: () {
                  setState(() => _selectedBottomItem = 'dashboard');
                  if (ModalRoute.of(context)?.settings.name != '/dashboard') {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                },
                width: width,
              ),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(
                icon: _selectedBottomItem == 'profile'
                    ? Icons.person
                    : Icons.person_outline,
                label: 'Profile',
                selected: _selectedBottomItem == 'profile',
                onTap: () {
                  setState(() => _selectedBottomItem = 'profile');
                  if (ModalRoute.of(context)?.settings.name != '/profile') {
                    Navigator.pushReplacementNamed(context, '/profile');
                  }
                },
                width: width,
              ),
              _buildNavItem(
                icon: _selectedBottomItem == 'about'
                    ? Icons.info
                    : Icons.info_outline,
                label: 'About Us',
                selected: _selectedBottomItem == 'about',
                onTap: () {
                  setState(() => _selectedBottomItem = 'about');
                  if (ModalRoute.of(context)?.settings.name != '/about') {
                    Navigator.pushReplacementNamed(context, '/about');
                  }
                },
                width: width,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required double width,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: scaleFont(24),
              color: selected ? const Color(0xFF1E3A5F) : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: scaleFont(12),
                color: selected ? const Color(0xFF1E3A5F) : Colors.grey,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
