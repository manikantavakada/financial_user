import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:shimmer/shimmer.dart';

import 'color_constants.dart';

class AdvisorRequestDetailScreen extends StatefulWidget {
  const AdvisorRequestDetailScreen({super.key});

  @override
  State<AdvisorRequestDetailScreen> createState() =>
      _AdvisorRequestDetailScreenState();
}

class _AdvisorRequestDetailScreenState extends State<AdvisorRequestDetailScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? req;
  bool _loading = true;
  bool _error = false;
  late TabController _tabController;

  Map<int, String> _questionnaireAnswers = {};
  Map<int, String> _goalAnswers = {};
  Map<int, String> _additionalNeedAnswers = {};
  Map<int, TextEditingController> _textControllers = {};

  bool _isSubmittingQuestionnaire = false;
  bool _isSubmittingGoals = false;
  bool _isSubmittingAdditionalNeeds = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Listen for tab changes to update the nav items
    _tabController.addListener(() {
      setState(() {
        // This will rebuild the nav items with correct selection
      });
    });

    Future.microtask(() {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final int avrrId = args['avrr_id'];
      _fetchRequestDetails(avrrId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textControllers.values.forEach((controller) => controller.dispose());
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

  Future<void> _fetchRequestDetails(int avrrId) async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final res = await http.get(
        Uri.parse(
          'https://ds.singledeck.in/api/v1/adviser/client-requests/?avrr_id=$avrrId',
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'success' &&
            data['data'] != null &&
            data['data'].isNotEmpty) {
          setState(() {
            req = Map<String, dynamic>.from(data['data'][0]);
            _loading = false;
          });
        } else {
          setState(() {
            _error = true;
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching details: $e");
      setState(() {
        _error = true;
        _loading = false;
      });
    }
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
        return const Color(0xFFFFC107); // Yellow/Amber
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoadingScreen();
    if (_error || req == null) return _buildErrorScreen();

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient (35% from top)
          Container(
            height: height * 0.30,
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

                // Tab Navigation
                _buildTabNavigation(),

                SizedBox(height: scaleHeight(20)),

                // Content Area
                Expanded(child: _buildTabContent()),
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
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(scaleWidth(8)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: scaleFont(20),
              ),
            ),
          ),

          Expanded(
            child: Text(
              'Request Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: scaleFont(24),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Placeholder to balance the layout
          SizedBox(width: scaleWidth(36)),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(20),
        vertical: scaleHeight(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('Details', 0),
          _buildNavItem('Goals', 1),
          _buildNavItem('Risk', 2),
          _buildNavItem('Needs', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, int index) {
    final bool isSelected = _tabController.index == index;

    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
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

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDetailsTab(req!),
        _buildGoalsTab(req!),
        _buildQuestionnaireTab(req!),
        _buildAdditionalNeedsTab(req!),
      ],
    );
  }

  Widget _buildDetailsTab(Map<String, dynamic> req) {
    final List<dynamic> visibleSolutions = (req['solutions'] ?? [])
        .where((s) => s['adrs_userdisplay_status'] == 'Y')
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Details Card
          Container(
            padding: EdgeInsets.all(scaleWidth(20)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        req['avrr_title'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: scaleFont(18),
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: scaleWidth(10)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: scaleWidth(12),
                        vertical: scaleHeight(6),
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(
                          _getStatusText(req['avrr_status']),
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(req['avrr_status']),
                            color: _statusColor(
                              _getStatusText(req['avrr_status']),
                            ),
                            size: scaleFont(16),
                          ),
                          SizedBox(width: scaleWidth(4)),
                          Text(
                            _getStatusText(req['avrr_status']),
                            style: TextStyle(
                              color: _statusColor(
                                _getStatusText(req['avrr_status']),
                              ),
                              fontWeight: FontWeight.w600,
                              fontSize: scaleFont(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: scaleHeight(16)),

                // ID and Date Row
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
                        Icons.confirmation_number,
                        color: Colors.white,
                        size: scaleFont(16),
                      ),
                    ),
                    SizedBox(width: scaleWidth(8)),
                    Text(
                      'ID: ${req['avrr_id'] ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: scaleFont(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(width: scaleWidth(20)),

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
                        Icons.calendar_today,
                        color: Colors.white,
                        size: scaleFont(16),
                      ),
                    ),
                    SizedBox(width: scaleWidth(8)),
                    Text(
                      _formatDate(req['avrr_rdate']),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: scaleFont(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                if (req['avrr_desc'] != null) ...[
                  SizedBox(height: scaleHeight(16)),
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: scaleFont(16),
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: scaleHeight(8)),
                  Text(
                    req['avrr_desc'],
                    style: TextStyle(
                      fontSize: scaleFont(14),
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],

                if (req['avrr_comment'] != null) ...[
                  SizedBox(height: scaleHeight(16)),
                  Text(
                    'Comment:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: scaleFont(16),
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: scaleHeight(8)),
                  Text(
                    req['avrr_comment'],
                    style: TextStyle(
                      fontSize: scaleFont(14),
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: scaleHeight(20)),

          // Status-based content
          if (req['avrr_status'] == 'PEND')
            Container(
              padding: EdgeInsets.all(scaleWidth(20)),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: Colors.orange[600],
                    size: scaleFont(24),
                  ),
                  SizedBox(width: scaleWidth(12)),
                  Expanded(
                    child: Text(
                      'Waiting for advisor response...',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: scaleFont(16),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Solutions for approved requests
          if (req['avrr_status'] == 'APVD' && visibleSolutions.isNotEmpty) ...[
            Text(
              'Advisor Solutions:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: scaleFont(18),
                color: Colors.black87,
              ),
            ),
            SizedBox(height: scaleHeight(12)),

            ...visibleSolutions.map((solution) {
              return Container(
                margin: EdgeInsets.only(bottom: scaleHeight(12)),
                padding: EdgeInsets.all(scaleWidth(16)),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Html(
                  data: solution['adrs_response'] ?? '',
                  style: {
                    "body": Style(
                      fontSize: FontSize(scaleFont(14)),
                      color: Colors.green[800],
                    ),
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionnaireTab(Map<String, dynamic> req) {
    final List<dynamic> questionnaire = req['questionnaire'] ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Profile Questionnaire',
            style: TextStyle(
              fontSize: scaleFont(18),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: scaleHeight(16)),

          if (questionnaire.isEmpty)
            _buildEmptyState('No questionnaire available', Icons.quiz_outlined)
          else ...[
            ...questionnaire
                .map((q) => _buildInteractiveQuestionWidget(q, 'questionnaire'))
                .toList(),
            SizedBox(height: scaleHeight(24)),
            _buildBulkSubmitButton(
              type: 'questionnaire',
              isLoading: _isSubmittingQuestionnaire,
              itemCount: questionnaire.length,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalsTab(Map<String, dynamic> req) {
    final List<dynamic> goals = req['goals'] ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Goals',
            style: TextStyle(
              fontSize: scaleFont(18),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: scaleHeight(16)),

          if (goals.isEmpty)
            _buildEmptyState(
              'No financial goals set',
              Icons.track_changes_outlined,
            )
          else ...[
            ...goals.map((g) => _buildInteractiveGoalWidget(g)).toList(),
            SizedBox(height: scaleHeight(24)),
            _buildBulkSubmitButton(
              type: 'goals',
              isLoading: _isSubmittingGoals,
              itemCount: goals.length,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalNeedsTab(Map<String, dynamic> req) {
    final List<dynamic> additionalNeeds = req['additional_needs'] ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Requirements',
            style: TextStyle(
              fontSize: scaleFont(18),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: scaleHeight(16)),

          if (additionalNeeds.isEmpty)
            _buildEmptyState(
              'No additional needs specified',
              Icons.add_circle_outline,
            )
          else ...[
            ...additionalNeeds
                .map((a) => _buildInteractiveAdditionalNeedWidget(a))
                .toList(),
            SizedBox(height: scaleHeight(24)),
            _buildBulkSubmitButton(
              type: 'additional_needs',
              isLoading: _isSubmittingAdditionalNeeds,
              itemCount: additionalNeeds.length,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: EdgeInsets.all(scaleWidth(40)),
      child: Column(
        children: [
          Icon(icon, size: scaleFont(64), color: Colors.grey[400]),
          SizedBox(height: scaleHeight(16)),
          Text(
            message,
            style: TextStyle(
              fontSize: scaleFont(16),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveQuestionWidget(
    Map<String, dynamic> question,
    String type,
  ) {
    final int questionId = question['avrq_id'] ?? 0;
    final String questionType = question['avrq_type'] ?? 'MULQ';
    final String questionText = question['avrq_question'] ?? '';
    final List<dynamic> responses = question['response'] ?? [];
    final bool hasExistingResponse = _hasExistingResponse(responses);
    final String existingAnswer = hasExistingResponse
        ? _getExistingAnswer(responses, 'questionnaire')
        : '';

    if (hasExistingResponse && !_questionnaireAnswers.containsKey(questionId)) {
      _questionnaireAnswers[questionId] = existingAnswer;
      if (questionType == 'BLKQ') {
        _textControllers[questionId] = TextEditingController(
          text: existingAnswer,
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: scaleHeight(16)),
      padding: EdgeInsets.all(scaleWidth(16)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  questionText,
                  style: TextStyle(
                    fontSize: scaleFont(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (hasExistingResponse)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleWidth(8),
                    vertical: scaleHeight(4),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Answered',
                    style: TextStyle(
                      fontSize: scaleFont(12),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: scaleHeight(12)),
          _buildInteractiveQuestionOptions(question, questionType, questionId),
        ],
      ),
    );
  }

  Widget _buildInteractiveGoalWidget(Map<String, dynamic> goal) {
    final int goalId = goal['avrg_id'] ?? 0;
    final String goalType = goal['avrg_type'] ?? 'TFQS';
    final String questionText = goal['avrg_question'] ?? '';
    final List<dynamic> responses = goal['response'] ?? [];
    final bool hasExistingResponse = _hasExistingResponse(responses);
    final String existingAnswer = hasExistingResponse
        ? _getExistingAnswer(responses, 'goals')
        : '';

    if (hasExistingResponse && !_goalAnswers.containsKey(goalId)) {
      _goalAnswers[goalId] = existingAnswer;
      if (goalType == 'BLKQ') {
        _textControllers[goalId] = TextEditingController(text: existingAnswer);
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: scaleHeight(16)),
      padding: EdgeInsets.all(scaleWidth(16)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  questionText,
                  style: TextStyle(
                    fontSize: scaleFont(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (hasExistingResponse)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleWidth(8),
                    vertical: scaleHeight(4),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Answered',
                    style: TextStyle(
                      fontSize: scaleFont(12),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: scaleHeight(12)),
          _buildInteractiveGoalOptions(goal, goalType, goalId),
        ],
      ),
    );
  }

  Widget _buildInteractiveAdditionalNeedWidget(Map<String, dynamic> need) {
    final int needId = need['avra_id'] ?? 0;
    final String needType = need['avra_type'] ?? 'BLKQ';
    final String questionText = need['avra_question'] ?? '';
    final List<dynamic> responses = need['response'] ?? [];
    final bool hasExistingResponse = _hasExistingResponse(responses);
    final String existingAnswer = hasExistingResponse
        ? _getExistingAnswer(responses, 'additional_needs')
        : '';

    if (hasExistingResponse && !_additionalNeedAnswers.containsKey(needId)) {
      _additionalNeedAnswers[needId] = existingAnswer;
      if (needType == 'BLKQ') {
        _textControllers[needId] = TextEditingController(text: existingAnswer);
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: scaleHeight(16)),
      padding: EdgeInsets.all(scaleWidth(16)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  questionText,
                  style: TextStyle(
                    fontSize: scaleFont(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (hasExistingResponse)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleWidth(8),
                    vertical: scaleHeight(4),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Answered',
                    style: TextStyle(
                      fontSize: scaleFont(12),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: scaleHeight(12)),
          _buildInteractiveAdditionalNeedOptions(need, needType, needId),
        ],
      ),
    );
  }

  Widget _buildBulkSubmitButton({
    required String type,
    required bool isLoading,
    required int itemCount,
  }) {
    final int answeredCount = _getAnsweredCount(type);
    final bool hasAnswers = answeredCount > 0;

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: (hasAnswers && !isLoading)
            ? () => _submitBulkAnswers(type)
            : null,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: scaleHeight(16)),
          decoration: BoxDecoration(
            gradient: (hasAnswers && !isLoading)
                ? LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: (hasAnswers && !isLoading) ? null : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      hasAnswers ? Colors.white : Colors.grey[600]!,
                    ),
                  ),
                ),
                SizedBox(width: scaleWidth(12)),
              ],
              Text(
                isLoading
                    ? 'Submitting...'
                    : 'Submit ${_getTypeDisplayName(type)} ($answeredCount/$itemCount)',
                style: TextStyle(
                  color: (hasAnswers && !isLoading)
                      ? Colors.white
                      : Colors.grey[600],
                  fontSize: scaleFont(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveQuestionOptions(
    Map<String, dynamic> question,
    String type,
    int questionId,
  ) {
    switch (type) {
      case 'MULQ':
        return _buildInteractiveMultipleChoice(
          question,
          questionId,
          'questionnaire',
        );
      case 'TFQS':
        return _buildInteractiveTrueFalse(questionId, 'questionnaire');
      case 'BLKQ':
        return _buildInteractiveTextInput(questionId, 'questionnaire');
      default:
        return _buildInteractiveMultipleChoice(
          question,
          questionId,
          'questionnaire',
        );
    }
  }

  Widget _buildInteractiveGoalOptions(
    Map<String, dynamic> goal,
    String type,
    int goalId,
  ) {
    switch (type) {
      case 'MULQ':
        return _buildInteractiveMultipleChoice(goal, goalId, 'goals');
      case 'TFQS':
        return _buildInteractiveTrueFalse(goalId, 'goals');
      case 'BLKQ':
        return _buildInteractiveTextInput(goalId, 'goals');
      default:
        return _buildInteractiveTrueFalse(goalId, 'goals');
    }
  }

  Widget _buildInteractiveAdditionalNeedOptions(
    Map<String, dynamic> need,
    String type,
    int needId,
  ) {
    switch (type) {
      case 'MULQ':
        return _buildInteractiveMultipleChoice(
          need,
          needId,
          'additional_needs',
        );
      case 'TFQS':
        return _buildInteractiveTrueFalse(needId, 'additional_needs');
      case 'BLKQ':
        return _buildInteractiveTextInput(needId, 'additional_needs');
      default:
        return _buildInteractiveTextInput(needId, 'additional_needs');
    }
  }

  Widget _buildInteractiveMultipleChoice(
    Map<String, dynamic> item,
    int itemId,
    String type,
  ) {
    final List<String> options = [];

    if (type == 'questionnaire') {
      if (item['avrq_option1'] != null) options.add(item['avrq_option1']);
      if (item['avrq_option2'] != null) options.add(item['avrq_option2']);
      if (item['avrq_option3'] != null) options.add(item['avrq_option3']);
      if (item['avrq_option4'] != null) options.add(item['avrq_option4']);
    } else if (type == 'goals') {
      if (item['avrg_option1'] != null) options.add(item['avrg_option1']);
      if (item['avrg_option2'] != null) options.add(item['avrg_option2']);
      if (item['avrg_option3'] != null) options.add(item['avrg_option3']);
      if (item['avrg_option4'] != null) options.add(item['avrg_option4']);
    } else {
      if (item['avra_option1'] != null) options.add(item['avra_option1']);
      if (item['avra_option2'] != null) options.add(item['avra_option2']);
      if (item['avra_option3'] != null) options.add(item['avra_option3']);
      if (item['avra_option4'] != null) options.add(item['avra_option4']);
    }

    return Column(
      children: options.map((option) {
        final bool isSelected = _getSelectedAnswer(itemId, type) == option;
        return GestureDetector(
          onTap: () {
            setState(() {
              _setSelectedAnswer(itemId, type, option);
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: scaleHeight(4)),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: primaryColor, width: 1.5)
                  : null,
            ),
            child: ListTile(
              dense: true,
              leading: isSelected
                  ? Icon(Icons.check_circle, color: primaryColor)
                  : Icon(Icons.radio_button_unchecked, color: Colors.grey),
              title: Text(
                option,
                style: TextStyle(
                  fontSize: scaleFont(14),
                  color: isSelected ? primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInteractiveTrueFalse(int itemId, String type) {
    final List<String> options = ['True', 'False'];

    return Column(
      children: options.map((option) {
        final bool isSelected = _getSelectedAnswer(itemId, type) == option;
        return GestureDetector(
          onTap: () {
            setState(() {
              _setSelectedAnswer(itemId, type, option);
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: scaleHeight(4)),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: primaryColor, width: 1.5)
                  : null,
            ),
            child: ListTile(
              dense: true,
              leading: isSelected
                  ? Icon(Icons.check_circle, color: primaryColor)
                  : Icon(Icons.radio_button_unchecked, color: Colors.grey),
              title: Text(
                option,
                style: TextStyle(
                  fontSize: scaleFont(14),
                  color: isSelected ? primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInteractiveTextInput(int itemId, String type) {
    if (!_textControllers.containsKey(itemId)) {
      _textControllers[itemId] = TextEditingController();
    }

    return Container(
      padding: EdgeInsets.all(scaleWidth(16)),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _textControllers[itemId],
        decoration: InputDecoration(
          hintText: 'Enter your response...',
          hintStyle: TextStyle(fontSize: scaleFont(14)),
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: scaleFont(14)),
        maxLines: 3,
        onChanged: (value) {
          _setSelectedAnswer(itemId, type, value);
        },
      ),
    );
  }

  // Loading screen with new theme
  Widget _buildLoadingScreen() {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
                _buildHeader(),
                SizedBox(height: scaleHeight(40)),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(scaleWidth(20)),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: ListView.builder(
                        itemCount: 6,
                        itemBuilder: (_, __) => Container(
                          margin: EdgeInsets.only(bottom: scaleHeight(16)),
                          height: scaleHeight(80),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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

  // Error screen with new theme
  Widget _buildErrorScreen() {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
                _buildHeader(),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: scaleFont(64),
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: scaleHeight(16)),
                        Text(
                          'Failed to load request details',
                          style: TextStyle(
                            fontSize: scaleFont(16),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
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

  // Utility methods
  String _getSelectedAnswer(int itemId, String type) {
    switch (type) {
      case 'questionnaire':
        return _questionnaireAnswers[itemId] ?? '';
      case 'goals':
        return _goalAnswers[itemId] ?? '';
      case 'additional_needs':
        return _additionalNeedAnswers[itemId] ?? '';
      default:
        return '';
    }
  }

  void _setSelectedAnswer(int itemId, String type, String answer) {
    switch (type) {
      case 'questionnaire':
        _questionnaireAnswers[itemId] = answer;
        break;
      case 'goals':
        _goalAnswers[itemId] = answer;
        break;
      case 'additional_needs':
        _additionalNeedAnswers[itemId] = answer;
        break;
    }
  }

  int _getAnsweredCount(String type) {
    switch (type) {
      case 'questionnaire':
        return _questionnaireAnswers.values
            .where((answer) => answer.isNotEmpty)
            .length;
      case 'goals':
        return _goalAnswers.values.where((answer) => answer.isNotEmpty).length;
      case 'additional_needs':
        return _additionalNeedAnswers.values
            .where((answer) => answer.isNotEmpty)
            .length;
      default:
        return 0;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'questionnaire':
        return 'Answers';
      case 'goals':
        return 'Goals';
      case 'additional_needs':
        return 'Needs';
      default:
        return 'Responses';
    }
  }

  bool _hasExistingResponse(List<dynamic> responses) {
    return responses.isNotEmpty;
  }

  String _getExistingAnswer(List<dynamic> responses, String type) {
    if (responses.isNotEmpty && responses.last is Map) {
      final response = responses.last as Map<String, dynamic>;
      switch (type) {
        case 'questionnaire':
          return response['adqr_answer']?.toString() ?? '';
        case 'goals':
          return response['adgr_answer']?.toString() ?? '';
        case 'additional_needs':
          return response['adar_answer']?.toString() ?? '';
        default:
          return '';
      }
    }
    return '';
  }

  // API methods
  Future<bool> _submitQuestionnaireResponses(
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://ds.singledeck.in/api/v1/adviser/add-requests-questionnaire-responses/',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"questions_answers": answers}),
      );
      debugPrint('Questionnaire response: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting questionnaire: $e');
      return false;
    }
  }

  Future<bool> _submitGoalResponses(List<Map<String, dynamic>> answers) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://ds.singledeck.in/api/v1/adviser/add-requests-goals-responses/',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"goal_answers": answers}),
      );
      debugPrint('Goals response: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting goals: $e');
      return false;
    }
  }

  Future<bool> _submitAdditionalNeedResponses(
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://ds.singledeck.in/api/v1/adviser/add-requests-additional-responses/',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"additional_answers": answers}),
      );
      debugPrint('Additional needs response: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting additional needs: $e');
      return false;
    }
  }

  Future<void> _submitBulkAnswers(String type) async {
    List<Map<String, dynamic>> answers = [];
    bool success = false;

    switch (type) {
      case 'questionnaire':
        setState(() => _isSubmittingQuestionnaire = true);
        _questionnaireAnswers.forEach((id, answer) {
          if (answer.isNotEmpty) {
            answers.add({"avrq_id": id, "answer": answer});
          }
        });
        if (answers.isNotEmpty) {
          success = await _submitQuestionnaireResponses(answers);
        }
        setState(() => _isSubmittingQuestionnaire = false);
        break;

      case 'goals':
        setState(() => _isSubmittingGoals = true);
        _goalAnswers.forEach((id, answer) {
          if (answer.isNotEmpty) {
            answers.add({"avrg_id": id, "answer": answer});
          }
        });
        if (answers.isNotEmpty) {
          success = await _submitGoalResponses(answers);
        }
        setState(() => _isSubmittingGoals = false);
        break;

      case 'additional_needs':
        setState(() => _isSubmittingAdditionalNeeds = true);
        _additionalNeedAnswers.forEach((id, answer) {
          if (answer.isNotEmpty) {
            answers.add({"avra_id": id, "answer": answer});
          }
        });
        if (answers.isNotEmpty) {
          success = await _submitAdditionalNeedResponses(answers);
        }
        setState(() => _isSubmittingAdditionalNeeds = false);
        break;
    }

    if (answers.isNotEmpty) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_getTypeDisplayName(type)} submitted successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit ${_getTypeDisplayName(type).toLowerCase()}. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
