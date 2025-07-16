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

  void _showAddRequestBottomSheet() {
    String requestName = '';
    bool advisorKnown = false;
    String advisorRef = '';
    bool showAdvisorRef = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                builder: (_, controller) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: controller,
                      child: StatefulBuilder(
                        builder: (context, setModalState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 5,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const Text(
                                'Add Advisor Request',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A5F),
                                ),
                              ),
                              const SizedBox(height: 20),
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
                              const Text(
                                'Do you know the advisor?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Radio<bool>(
                                    value: true,
                                    groupValue: advisorKnown,
                                    onChanged: (val) {
                                      setModalState(() {
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
                                      setModalState(() {
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
                              const SizedBox(height: 24),
                              Center(
                                child: GestureDetector(
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
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF169060), Color(0xFF1E3A5F)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Submit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            bottom: 24,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
              stops: [0.3, 0.7, 1],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Center(
                child: Text(
                  'Advisor Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.add, size: 28, color: Colors.white),
                  onPressed: _showAddRequestBottomSheet,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
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
                      req['status'] == 'Completed' ? Icons.check : Icons.hourglass_top,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    Navigator.pushNamed(context, '/advisor_request_detail', arguments: req);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
