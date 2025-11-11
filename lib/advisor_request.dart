import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

import 'add_advisor_request_screen.dart';
import 'color_constants.dart';

class AdvisorRequestsScreen extends StatefulWidget {
  const AdvisorRequestsScreen({super.key});

  @override
  State<AdvisorRequestsScreen> createState() => _AdvisorRequestsScreenState();
}

class _AdvisorRequestsScreenState extends State<AdvisorRequestsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _requestsFuture;
  String selectedFilter = 'All Requests';
  String selectedTopNav = 'Pending';
  String searchQuery = ''; // Added search query variable
  TextEditingController searchController =
      TextEditingController(); // Added controller

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestsFuture = _fetchRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose(); // Dispose controller
    super.dispose();
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
      case 'Accepted':
        return const Color(0xFF4CAF50); // Green
      case 'Rejected':
        return const Color(0xFFE53935); // Red
      case 'Pending':
      default:
        return const Color(0xFFEA6716); // Orange
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

  // Updated date formatting to show "Requested: MM/DD"
  String _formatRequestDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return 'Date: ${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
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
        'https://ds.singledeck.in/api/v1/adviser/client-requests-list/?clnt_id=$clntId';

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

            return processedRequest;
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Fetch requests error: $e');
    }

    return [];
  }

  // Enhanced filtering with search functionality
  List<Map<String, dynamic>> _filterRequests(
    List<Map<String, dynamic>> requests,
  ) {
    List<Map<String, dynamic>> filtered = requests;

    // Filter by status
    if (selectedTopNav != 'All') {
      filtered = filtered.where((req) {
        final status = _getStatusText(req['avrr_status'] ?? '');
        return status == selectedTopNav;
      }).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((req) {
        final title = (req['avrr_title'] ?? '').toString().toLowerCase();
        final id = (req['avrr_id'] ?? '').toString().toLowerCase();
        final desc = (req['avrr_desc'] ?? '').toString().toLowerCase();
        final query = searchQuery.toLowerCase();

        return title.contains(query) ||
            id.contains(query) ||
            desc.contains(query);
      }).toList();
    }

    return filtered;
  }

  Widget _buildShimmerLoading(double width, double height) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(20),
        vertical: scaleHeight(20),
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: scaleHeight(20)),
            padding: EdgeInsets.all(scaleWidth(20)),
            height: scaleHeight(110),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient (33% from top)
          Container(
            height: height * 0.33,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(scaleWidth(20)),
                bottomRight: Radius.circular(scaleWidth(20)),
              ),
            ),
          ),

          // Content with SafeArea
          SafeArea(
            child: Column(
              children: [
                // Header Section
                _buildHeader(),

                // Top Navigation (Status filters)
                _buildTopNavigation(),

                // Search Bar
                _buildSearchBar(),

                SizedBox(height: scaleHeight(10)),

                // Cards List
                Expanded(child: _buildRequestsList()),
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
      child: Row(
        children: [
          Expanded(child: Container()),

          Text(
            'Advisor Requests',
            style: TextStyle(
              color: Colors.white,
              fontSize: scaleFont(24),
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddAdvisorRequestScreen(),
                    ),
                  );
                  if (result == true) {
                    _refreshRequests();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(scaleWidth(8)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: scaleFont(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(20),
        vertical: scaleHeight(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('Pending', selectedTopNav == 'Pending'),
          _buildNavItem('Approved', selectedTopNav == 'Approved'),
          _buildNavItem('Rejected', selectedTopNav == 'Rejected'),
          _buildNavItem('All', selectedTopNav == 'All'),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTopNav = title;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: scaleWidth(16),
          vertical: scaleHeight(8),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: scaleFont(14),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: scaleWidth(20),
        vertical: scaleHeight(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: scaleWidth(15)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: searchController,
        style: TextStyle(color: Colors.white, fontSize: scaleFont(16)),
        decoration: InputDecoration(
          hintText: 'Search Requests',
          hintStyle: TextStyle(color: Colors.white70, fontSize: scaleFont(16)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white70,
            size: scaleFont(20),
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      searchQuery = '';
                      searchController.clear();
                    });
                  },
                  child: Icon(
                    Icons.clear,
                    color: Colors.white70,
                    size: scaleFont(20),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: scaleHeight(15)),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildRequestsList() {
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async {
        _refreshRequests();
        await _requestsFuture;
      },
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: scaleHeight(100)),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: scaleFont(80),
                        color: Colors.grey,
                      ),
                      SizedBox(height: scaleHeight(16)),
                      Text(
                        'No requests found.',
                        style: TextStyle(
                          fontSize: scaleFont(18),
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: scaleHeight(8)),
                      Text(
                        'Pull down to refresh or tap + to add a request.',
                        style: TextStyle(
                          fontSize: scaleFont(14),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          final allRequests = snapshot.data!;
          final filteredRequests = _filterRequests(allRequests);

          if (filteredRequests.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: scaleHeight(100)),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.filter_list_off,
                        size: scaleFont(80),
                        color: Colors.grey,
                      ),
                      SizedBox(height: scaleHeight(16)),
                      Text(
                        searchQuery.isNotEmpty
                            ? 'No requests match your search.'
                            : 'No requests found for this filter.',
                        style: TextStyle(
                          fontSize: scaleFont(18),
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (searchQuery.isNotEmpty) ...[
                        SizedBox(height: scaleHeight(8)),
                        Text(
                          'Try adjusting your search terms.',
                          style: TextStyle(
                            fontSize: scaleFont(14),
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
            itemCount: filteredRequests.length,
            itemBuilder: (context, index) {
              final req = filteredRequests[index];
              return _buildRequestCard(req);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    final status = (req['avrr_status'] ?? '').toString().toUpperCase();
    final statusText = _getStatusText(status);
    final statusColor = _statusColor(_getStatusColorType(status));

    return Container(
      margin: EdgeInsets.only(bottom: scaleHeight(20)),
      padding: EdgeInsets.all(scaleWidth(20)),
      height: scaleHeight(130), // Increased height for better layout
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          print('=== DEBUGGING REQUEST DATA ===');
          print('Request ID: ${req['avrr_id']}');
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
        child: Row(
          children: [
            // Status Icon
            Container(
              width: scaleWidth(50),
              height: scaleWidth(50),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getStatusIcon(status),
                color: Colors.white,
                size: scaleFont(25),
              ),
            ),
            SizedBox(width: scaleWidth(15)),

            // Request Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    req['avrr_title'] ?? '--',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: scaleFont(16),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: scaleHeight(4)),
                  Text(
                    'ID: ${req['avrr_id']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: scaleFont(13),
                    ),
                  ),
                  SizedBox(height: scaleHeight(2)),
                  Text(
                    _formatRequestDate(req['avrr_rdate']),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: scaleFont(12),
                    ),
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: scaleWidth(10),
                vertical: scaleHeight(4),
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: scaleFont(12),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
