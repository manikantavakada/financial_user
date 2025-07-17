import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  Future<List<Map<String, dynamic>>> _fetchAdvisors(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://ss.singledeck.in/api/v1/adviser/advisor-profile-details/',
        ),
      );
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> advisors = data['data'];
          if (query.isNotEmpty) {
            advisors = advisors
                .where(
                  (advisor) => advisor['advr_full_name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList();
          }
          return advisors.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> _submitRequest({
    required int clntId,
    required String title,
    required String desc,
    int? advrId,
    required String assignType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://ss.singledeck.in/api/v1/adviser/advisor-request/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'clnt_id': clntId,
          'title': title,
          'advr_id': advrId,
          'desc': desc,
          'assigntype': assignType,
        }),
      );
      print('Response submitRequest: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error submitting request: $e');
      return false;
    }
  }

  void _showAddRequestBottomSheet() {
    String requestName = '';
    String description = '';
    bool advisorKnown = false;
    Map<String, dynamic>? selectedAdvisor;
    String searchQuery = '';
    List<Map<String, dynamic>> filteredAdvisors = [];
    bool isLoadingAdvisors = false;
    bool showAdvisorList = false; // Add this flag
    final TextEditingController searchController = TextEditingController();

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
                initialChildSize: 0.7,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                builder: (_, controller) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
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
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                maxLines: 3,
                                onChanged: (val) => description = val,
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
                                        showAdvisorList =
                                            false; // Reset list visibility
                                        selectedAdvisor = null;
                                        searchController.clear();
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
                                        selectedAdvisor = null;
                                        searchQuery = '';
                                        filteredAdvisors = [];
                                        showAdvisorList = false;
                                        searchController.clear();
                                      });
                                    },
                                  ),
                                  const Text('No'),
                                ],
                              ),
                              if (advisorKnown) ...[
                                const SizedBox(height: 16),
                                TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    labelText: selectedAdvisor != null
                                        ? 'Selected: ${selectedAdvisor!['advr_full_name']}'
                                        : 'Search and Select Advisor',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isLoadingAdvisors)
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        if (selectedAdvisor != null)
                                          IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              setModalState(() {
                                                selectedAdvisor = null;
                                                searchController.clear();
                                                showAdvisorList = false;
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                  readOnly:
                                      selectedAdvisor !=
                                      null, // Make read-only when selected
                                  onTap: selectedAdvisor != null
                                      ? null
                                      : () {
                                          setModalState(() {
                                            showAdvisorList = true;
                                          });
                                        },
                                  onChanged: selectedAdvisor != null
                                      ? null
                                      : (val) {
                                          setModalState(() {
                                            searchQuery = val;
                                            isLoadingAdvisors = true;
                                            showAdvisorList = true;
                                          });
                                          _fetchAdvisors(val).then((advisors) {
                                            setModalState(() {
                                              filteredAdvisors = advisors;
                                              isLoadingAdvisors = false;
                                            });
                                          });
                                        },
                                ),
                                const SizedBox(height: 8),
                                if (showAdvisorList &&
                                    filteredAdvisors.isNotEmpty &&
                                    !isLoadingAdvisors &&
                                    selectedAdvisor == null)
                                  Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListView.builder(
                                      itemCount: filteredAdvisors.length,
                                      itemBuilder: (context, index) {
                                        final advisor = filteredAdvisors[index];
                                        return ListTile(
                                          dense: true,
                                          title: Text(
                                            advisor['advr_full_name'],
                                          ),
                                          subtitle: Text(
                                            'ID: ${advisor['advr_uid']} • ${advisor['advr_expertise_area']}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            child: Text(
                                              advisor['advr_full_name'][0]
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            setModalState(() {
                                              selectedAdvisor = advisor;
                                              searchController.text =
                                                  advisor['advr_full_name'];
                                              showAdvisorList =
                                                  false; // Close the list after selection
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                              const SizedBox(height: 24),
                              Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    if (requestName.trim().isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter request name',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (advisorKnown &&
                                        selectedAdvisor == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please select an advisor',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    int clientId = 0;
                                    try {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      print("UserValidation");

                                      clientId = prefs.getInt('client_id') ?? 0;
                                      
                                    } catch (e) {
                                      print('SharedPreferences error: $e');
                                      // Fallback: use a default value or show error
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Unable to access user data. Please restart the app.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (clientId == 0) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Client ID not found. Please login again.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    final success = await _submitRequest(
                                      clntId: clientId,
                                      title: requestName,
                                      desc: description,
                                      advrId: advisorKnown
                                          ? selectedAdvisor!['advr_id']
                                          : null,
                                      assignType: advisorKnown
                                          ? 'DIRCT'
                                          : 'ADMIN',
                                    );

                                    if (success) {
                                      setState(() {
                                        widget.requests.insert(0, {
                                          'name': requestName,
                                          'status': 'Pending',
                                          'date': DateTime.now()
                                              .toString()
                                              .substring(0, 10),
                                          'reference':
                                              'AR-${widget.requests.length + 1}'
                                                  .padLeft(6, '0'),
                                        });
                                      });
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Request submitted successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Failed to submit request. Please try again.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF169060),
                                          Color(0xFF1E3A5F),
                                        ],
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
        ),
      ],
    );
  }
}
