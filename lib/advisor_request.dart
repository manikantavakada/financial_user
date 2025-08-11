import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

import 'add_advisor_request_screen.dart';

class AdvisorRequestsScreen extends StatefulWidget {
  const AdvisorRequestsScreen({super.key});

  @override
  State<AdvisorRequestsScreen> createState() => _AdvisorRequestsScreenState();
}

class _AdvisorRequestsScreenState extends State<AdvisorRequestsScreen> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _fetchRequests();
  }

  double scaleFont(double size) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
      case 'Accepted':
        return const Color(0xFF169060); // Green for approved
      case 'Rejected':
        return const Color(0xFFE53935); // Red for rejected
      case 'Pending':
      default:
        return const Color(0xFF164454); // Blue for pending
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'APVD':
        return Icons.check_circle;
      case 'RECT':
        return Icons.cancel;
      case 'PEND':
      default:
        return Icons.hourglass_top;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'APVD':
        return 'Approved';
      case 'RECT':
        return 'Rejected';
      case 'PEND':
      default:
        return 'Pending';
    }
  }

  String _getStatusColorType(String status) {
    switch (status.toUpperCase()) {
      case 'APVD':
        return 'Approved';
      case 'RECT':
        return 'Rejected';
      case 'PEND':
      default:
        return 'Pending';
    }
  }

  String _formatRequestDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<int?> _getClientIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('client_id');
    } catch (_) {
      return null;
    }
  }

  void _refreshRequests() {
    debugPrint('Refreshing advisor requests...');
    setState(() {
      _requestsFuture = _fetchRequests();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchRequests() async {
    int? clntId = await _getClientIdFromPrefs();
    if (clntId == null) return [];

    final url =
        'https://ss.singledeck.in/api/v1/adviser/client-requests-list/?clnt_id=$clntId';

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('=== RAW API RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Raw Body: ${response.body}');
      debugPrint('=== END RAW RESPONSE ===');

      if (response.statusCode == 200) {
        final resp = json.decode(response.body);

        if (resp['status'] == 'success' &&
            resp['data'] != null &&
            resp['data'].isNotEmpty) {
          final List<dynamic> allRequests = resp['data'][0]['requests'] ?? [];

          debugPrint('=== PARSING REQUESTS ===');
          debugPrint('Total requests found: ${allRequests.length}');

          for (int i = 0; i < allRequests.length; i++) {
            final rawRequest = allRequests[i];
            debugPrint(
              '--- Request ${i + 1} (ID: ${rawRequest['avrr_id']}) ---',
            );
            debugPrint('Raw questionnaire: ${rawRequest['questionnaire']}');
            debugPrint('Raw goals: ${rawRequest['goals']}');
            debugPrint(
              'Raw additional_needs: ${rawRequest['additional_needs']}',
            );
          }
          debugPrint('=== END PARSING ===');

          return allRequests.map<Map<String, dynamic>>((request) {
            final Map<String, dynamic> processedRequest = {
              'avrr_id': request['avrr_id'],
              'avrr_title': request['avrr_title'],
              'avrr_desc': request['avrr_desc'],
              'avrr_status': request['avrr_status'],
              'avrr_comment': request['avrr_comment'],
              'avrr_rdate': request['avrr_rdate'],
              'avrr_ludate': request['avrr_ludate'],
              'avrr_assigntype': request['avrr_assigntype'],
              'avrr_advr': request['avrr_advr'],
              'avrr_clnt': request['avrr_clnt'],
              'questionnaire': List<Map<String, dynamic>>.from(
                (request['questionnaire'] ?? []).map(
                  (q) => Map<String, dynamic>.from(q),
                ),
              ),
              'goals': List<Map<String, dynamic>>.from(
                (request['goals'] ?? []).map(
                  (g) => Map<String, dynamic>.from(g),
                ),
              ),
              'additional_needs': List<Map<String, dynamic>>.from(
                (request['additional_needs'] ?? []).map(
                  (a) => Map<String, dynamic>.from(a),
                ),
              ),
              // inside your mapping for processedRequest in _fetchRequests()
              'solutions': List<Map<String, dynamic>>.from(
                (request['solutions'] ?? []).map(
                  (s) => Map<String, dynamic>.from(s),
                ),
              ),
            };

            debugPrint('=== PROCESSED REQUEST ${request['avrr_id']} ===');
            debugPrint(
              'Questionnaire count: ${processedRequest['questionnaire'].length}',
            );
            debugPrint('Goals count: ${processedRequest['goals'].length}');
            debugPrint(
              'Additional needs count: ${processedRequest['additional_needs'].length}',
            );

            if (processedRequest['questionnaire'].isNotEmpty) {
              debugPrint(
                'Questionnaire content: ${processedRequest['questionnaire']}',
              );
            }
            if (processedRequest['goals'].isNotEmpty) {
              debugPrint('Goals content: ${processedRequest['goals']}');
            }
            if (processedRequest['additional_needs'].isNotEmpty) {
              debugPrint(
                'Additional needs content: ${processedRequest['additional_needs']}',
              );
            }
            debugPrint('=== END PROCESSED REQUEST ===');

            return processedRequest;
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Fetch requests error: $e');
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> _fetchAdvisors(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://ss.singledeck.in/api/v1/adviser/advisor-profile-details/',
        ),
      );
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
      debugPrint('Response submitRequest: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting request: $e');
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
    bool showAdvisorList = false;
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final modalContext = ctx;
        return GestureDetector(
          onTap: () => Navigator.of(modalContext).pop(),
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
                                        showAdvisorList = false;
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
                                  readOnly: selectedAdvisor != null,
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
                                              showAdvisorList = false;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
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
                              Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    if (requestName.trim().isEmpty) {
                                      ScaffoldMessenger.of(
                                        modalContext,
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
                                        modalContext,
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
                                    final clientId =
                                        await _getClientIdFromPrefs();
                                    if (clientId == null || clientId == 0) {
                                      ScaffoldMessenger.of(
                                        modalContext,
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
                                      Navigator.of(modalContext).pop();
                                      _refreshRequests();
                                      Future.delayed(
                                        const Duration(milliseconds: 350),
                                        () {
                                          if (mounted) {
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
                                          }
                                        },
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        modalContext,
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

  Widget _buildShimmerLoading(double width, double height) {
    return Column(
      children: [
        // Card Shimmer
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.02,
            ),
            itemCount: 4, // Show 4 placeholder cards
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: height * 0.02),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Color(0xFF169060).withOpacity(0.5),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: height * 0.01,
                      ),
                      child: Row(
                        children: [
                          // Leading Avatar
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: width * 0.04),
                          // Title and Subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: width * 0.6,
                                  height: scaleFont(width * 0.045),
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: width * 0.4,
                                  height: scaleFont(width * 0.035),
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: width * 0.3,
                                  height: scaleFont(width * 0.033),
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          // Trailing Status Badge
                          Container(
                            width: 80,
                            height: scaleFont(14) + 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddAdvisorRequestScreen(),
                      ),
                    );
                    if (result == true) {
                      _refreshRequests(); // Refresh list if submission was successful
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF169060),
            onRefresh: () async {
              _refreshRequests();
              await _requestsFuture;
            },
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _requestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoading(width, height);
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return ListView(
                    children: [
                      SizedBox(height: height * 0.3),
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No requests found.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pull down to refresh or tap + to add a request.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                final requests = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.02,
                  ),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    final status = (req['avrr_status'] ?? '')
                        .toString()
                        .toUpperCase();
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
                          backgroundColor: _statusColor(
                            _getStatusColorType(status),
                          ),
                          child: Icon(
                            _getStatusIcon(status),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          req['avrr_title'] ?? '--',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A5F),
                            fontSize: scaleFont(width * 0.045),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Request ID: ${req['avrr_id']}',
                              style: TextStyle(
                                color: const Color(0xFF666666),
                                fontSize: scaleFont(width * 0.035),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Date: ${_formatRequestDate(req['avrr_rdate'])}',
                              style: TextStyle(
                                color: const Color(0xFF666666),
                                fontSize: scaleFont(width * 0.033),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(
                              _getStatusColorType(status),
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusText(status),
                            style: TextStyle(
                              color: _statusColor(_getStatusColorType(status)),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () async {
                          print('=== DEBUGGING REQUEST DATA ===');
                          print('Request ID: ${req['avrr_id']}');
                          print(
                            'Questionnaire length: ${(req['questionnaire'] ?? []).length}',
                          );
                          print('Goals length: ${(req['goals'] ?? []).length}');
                          print(
                            'Additional needs length: ${(req['additional_needs'] ?? []).length}',
                          );
                          print('Full request data: ${req.toString()}');
                          print('=== END DEBUG ===');

                          final result = await Navigator.pushNamed(
                            context,
                            '/advisor_request_detail',
                            arguments: req,
                          );

                          debugPrint(
                            'User returned from detail screen - Refreshing requests...',
                          );
                          _refreshRequests();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
