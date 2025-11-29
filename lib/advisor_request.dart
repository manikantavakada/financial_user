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
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestsFuture = _fetchRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
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
        return AppColors.green;
      case 'Rejected':
        return AppColors.orange;
      case 'Pending':
      default:
        return AppColors.yellow;
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

  // Add this helper in your State class
Future<void> _handleUnauthorized({String message = 'Session expired. Please login again.'}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  if (!mounted) return;
  // show small snackbar so user knows what happened
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: AppColors.orange, duration: const Duration(seconds: 3)),
  );
  // navigate to login (adjust route if yours differs)
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
}

// Replace your _fetchRequests() with this
Future<List<Map<String, dynamic>>> _fetchRequests() async {
  int? clntId = await _getClientIdFromPrefs();
  if (clntId == null) {
    debugPrint('No client_id in prefs');
    return [];
  }

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  debugPrint('Has token: ${token != null && token.isNotEmpty}');

  if (token == null || token.isEmpty) {
    await _handleUnauthorized(message: 'No auth token. Please login.');
    return [];
  }

  final url = 'https://ds.singledeck.in/api/v1/adviser/client-requests-list/?clnt_id=$clntId';
  debugPrint('📡 Fetching requests: $url');

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        
        'sessiontoken': token,
        'sessiontype': 'CLNT',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 60));

    debugPrint('=== RAW API RESPONSE ===');
    debugPrint('Response instance: $response');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Raw Body: ${response.body}');
    debugPrint('=== END RAW RESPONSE ===');

    if (response.statusCode == 401) {
      // explicit unauthorized from server
      await _handleUnauthorized(message: 'Authentication Error. Please login again.');
      return [];
    }

    if (response.statusCode != 200) {
      debugPrint('Non-200 status: ${response.statusCode}');
      return [];
    }

    final resp = json.decode(response.body);

    if (resp['status'] == 'success' && resp['data'] != null && resp['data'].isNotEmpty) {
      final List<dynamic> allRequests = resp['data'][0]['requests'] ?? [];
      debugPrint('Total requests found: ${allRequests.length}');

      return allRequests.map<Map<String, dynamic>>((request) {
        return {
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
          'questionnaire': List<Map<String, dynamic>>.from((request['questionnaire'] ?? []).map((q) => Map<String, dynamic>.from(q))),
          'goals': List<Map<String, dynamic>>.from((request['goals'] ?? []).map((g) => Map<String, dynamic>.from(g))),
          'additional_needs': List<Map<String, dynamic>>.from((request['additional_needs'] ?? []).map((a) => Map<String, dynamic>.from(a))),
          'solutions': List<Map<String, dynamic>>.from((request['solutions'] ?? []).map((s) => Map<String, dynamic>.from(s))),
        };
      }).toList();
    } else {
      debugPrint('API returned non-success or empty data: ${resp['status']}');
    }
  } on http.ClientException catch (e, st) {
    debugPrint('ClientException: $e');
    debugPrint('Stack: $st');
    // If web, likely CORS issue if server doesn't allow the headers
    if (e.toString().contains('Failed to fetch')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network/CORS error: server must allow cross-origin requests for web builds.'),
            duration: Duration(seconds: 6),
          ),
        );
      }
    }
  } catch (e, st) {
    debugPrint('Fetch requests error: $e');
    debugPrint('Stack: $st');
  }

  return [];
}




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
          baseColor: AppColors.lightGray,
          highlightColor: textWhite,
          child: Container(
            margin: EdgeInsets.only(bottom: scaleHeight(20)),
            padding: EdgeInsets.all(scaleWidth(20)),
            height: scaleHeight(110),
            decoration: BoxDecoration(
              color: textWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
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
      backgroundColor: AppColors.lightGray,
      body: Stack(
        children: [
          // Background Header (33% from top) - Solid color instead of gradient
          Container(
            height: height * 0.33,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
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
              color: AppColors.lightGray,
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
                    color: AppColors.lightGray.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColors.lightGray,
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
              ? AppColors.lightGray.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.lightGray, width: 1.5)
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.lightGray,
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
        color: AppColors.lightGray.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.3), width: 1),
      ),
      child: TextField(
        controller: searchController,
        style: TextStyle(color: AppColors.lightGray, fontSize: scaleFont(16)),
        decoration: InputDecoration(
          hintText: 'Search Requests',
          hintStyle: TextStyle(
            color: AppColors.lightGray.withOpacity(0.7),
            fontSize: scaleFont(16),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.lightGray.withOpacity(0.7),
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
                    color: AppColors.lightGray.withOpacity(0.7),
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
      color: AppColors.primaryDark,
      backgroundColor: textWhite,
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
                        color: textGray,
                      ),
                      SizedBox(height: scaleHeight(16)),
                      Text(
                        'No requests found.',
                        style: TextStyle(
                          fontSize: scaleFont(18),
                          color: textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: scaleHeight(8)),
                      Text(
                        'Pull down to refresh or tap + to add a request.',
                        style: TextStyle(
                          fontSize: scaleFont(14),
                          color: textGray,
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
                        color: textGray,
                      ),
                      SizedBox(height: scaleHeight(16)),
                      Text(
                        searchQuery.isNotEmpty
                            ? 'No requests match your search.'
                            : 'No requests found for this filter.',
                        style: TextStyle(
                          fontSize: scaleFont(18),
                          color: textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (searchQuery.isNotEmpty) ...[
                        SizedBox(height: scaleHeight(8)),
                        Text(
                          'Try adjusting your search terms.',
                          style: TextStyle(
                            fontSize: scaleFont(14),
                            color: textGray,
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
      height: scaleHeight(130),
      decoration: BoxDecoration(
        color: textWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                color: textWhite,
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
                      color: AppColors.primaryDark,
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
                      color: textGray,
                      fontSize: scaleFont(13),
                    ),
                  ),
                  SizedBox(height: scaleHeight(2)),
                  Text(
                    _formatRequestDate(req['avrr_rdate']),
                    style: TextStyle(
                      color: textGray,
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
