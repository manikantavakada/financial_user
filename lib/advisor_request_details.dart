import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdvisorRequestDetailScreen extends StatefulWidget {
  const AdvisorRequestDetailScreen({super.key});

  @override
  State<AdvisorRequestDetailScreen> createState() =>
      _AdvisorRequestDetailScreenState();
}

class _AdvisorRequestDetailScreenState
    extends State<AdvisorRequestDetailScreen> {
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
  }

  @override
  void dispose() {
    _textControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<bool> _submitQuestionnaireResponses(
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://ss.singledeck.in/api/v1/adviser/add-requests-questionnaire-responses/',
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
          'https://ss.singledeck.in/api/v1/adviser/add-requests-goals-responses/',
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
          'https://ss.singledeck.in/api/v1/adviser/add-requests-additional-responses/',
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

  String _getExistingAnswer(List<dynamic> responses, String type) {
    if (responses.isNotEmpty && responses.last is Map) {
      final response =
          responses.last
              as Map<
                String,
                dynamic
              >; // Changed from responses[0] to responses.last

      // Handle different field names based on type
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

  bool _hasExistingResponse(List<dynamic> responses) {
    return responses.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> req =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {
          'avrr_title': 'Retirement Planning',
          'avrr_status': 'PEND',
          'avrr_rdate': '2025-07-01',
          'avrr_id': 'AR-001',
          'avrr_desc': 'Sample description',
          'avrr_comment': null,
          'questionnaire': [],
          'goals': [],
          'additional_needs': [],
        };

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A5F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Request Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: width * 0.055,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: const Color(0xFF169060),
            unselectedLabelColor: Colors.white,
            indicatorColor: const Color(0xFF169060),
            labelStyle: TextStyle(
              fontSize: width * 0.032,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: width * 0.032,
              fontWeight: FontWeight.normal,
            ),
            isScrollable: true,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Goals'),
              Tab(text: 'Risk Profile'),
              Tab(text: 'Additional Needs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDetailsTab(req, width, height),
            _buildGoalsTab(req, width),
            _buildQuestionnaireTab(req, width),
            _buildAdditionalNeedsTab(req, width),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab(
    Map<String, dynamic> req,
    double width,
    double height,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req['avrr_title'] ?? 'No Title',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.05,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number,
                        color: Color(0xFF169060),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ID: ${req['avrr_id'] ?? 'N/A'}',
                        style: TextStyle(
                          color: const Color(0xFF666666),
                          fontSize: width * 0.035,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Icon(
                        Icons.calendar_today,
                        color: Color(0xFF169060),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(req['avrr_rdate']),
                        style: TextStyle(
                          color: const Color(0xFF666666),
                          fontSize: width * 0.035,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(req['avrr_status']),
                        color: _statusColor(req['avrr_status']),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(req['avrr_status']),
                        style: TextStyle(
                          color: _statusColor(req['avrr_status']),
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.04,
                        ),
                      ),
                    ],
                  ),
                  if (req['avrr_desc'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.04,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      req['avrr_desc'],
                      style: TextStyle(
                        fontSize: width * 0.038,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                  if (req['avrr_comment'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Comment:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.04,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      req['avrr_comment'],
                      style: TextStyle(
                        fontSize: width * 0.038,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (req['avrr_status'] == 'PEND')
            Center(
              child: Text(
                'Waiting for advisor response...',
                style: TextStyle(
                  color: const Color(0xFF164454),
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionnaireTab(Map<String, dynamic> req, double width) {
    final List<dynamic> questionnaire = req['questionnaire'] ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questionnaire',
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 16),
          if (questionnaire.isEmpty)
            Center(
              child: Text(
                'No questionnaire available',
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: const Color(0xFF666666),
                ),
              ),
            )
          else ...[
            ...questionnaire
                .map(
                  (q) => _buildInteractiveQuestionWidget(
                    q,
                    width,
                    'questionnaire',
                  ),
                )
                .toList(),
            const SizedBox(height: 24),
            _buildBulkSubmitButton(
              type: 'questionnaire',
              isLoading: _isSubmittingQuestionnaire,
              width: width,
              itemCount: questionnaire.length,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalsTab(Map<String, dynamic> req, double width) {
    final List<dynamic> goals = req['goals'] ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Goals',
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 16),
          if (goals.isEmpty)
            Center(
              child: Text(
                'No financial goals set',
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: const Color(0xFF666666),
                ),
              ),
            )
          else ...[
            ...goals.map((g) => _buildInteractiveGoalWidget(g, width)).toList(),
            const SizedBox(height: 24),
            _buildBulkSubmitButton(
              type: 'goals',
              isLoading: _isSubmittingGoals,
              width: width,
              itemCount: goals.length,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalNeedsTab(Map<String, dynamic> req, double width) {
    final List<dynamic> additionalNeeds = req['additional_needs'] ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Needs',
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 16),
          if (additionalNeeds.isEmpty)
            Center(
              child: Text(
                'No additional needs specified',
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: const Color(0xFF666666),
                ),
              ),
            )
          else ...[
            ...additionalNeeds
                .map((a) => _buildInteractiveAdditionalNeedWidget(a, width))
                .toList(),
            const SizedBox(height: 24),
            _buildBulkSubmitButton(
              type: 'additional_needs',
              isLoading: _isSubmittingAdditionalNeeds,
              width: width,
              itemCount: additionalNeeds.length,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInteractiveQuestionWidget(
    Map<String, dynamic> question,
    double width,
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

    // Initialize answer if existing response
    if (hasExistingResponse && !_questionnaireAnswers.containsKey(questionId)) {
      _questionnaireAnswers[questionId] = existingAnswer;
      if (questionType == 'BLKQ') {
        _textControllers[questionId] = TextEditingController(
          text: existingAnswer,
        );
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    questionText,
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                if (hasExistingResponse)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF169060).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Answered',
                      style: TextStyle(
                        fontSize: width * 0.03,
                        color: const Color(0xFF169060),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInteractiveQuestionOptions(
              question,
              questionType,
              questionId,
              width,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveGoalWidget(Map<String, dynamic> goal, double width) {
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

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    questionText,
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                if (hasExistingResponse)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF169060).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Answered',
                      style: TextStyle(
                        fontSize: width * 0.03,
                        color: const Color(0xFF169060),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInteractiveGoalOptions(goal, goalType, goalId, width),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveAdditionalNeedWidget(
    Map<String, dynamic> need,
    double width,
  ) {
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

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    questionText,
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                if (hasExistingResponse)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF169060).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Answered',
                      style: TextStyle(
                        fontSize: width * 0.03,
                        color: const Color(0xFF169060),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInteractiveAdditionalNeedOptions(
              need,
              needType,
              needId,
              width,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkSubmitButton({
    required String type,
    required bool isLoading,
    required double width,
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: (hasAnswers && !isLoading)
                ? const LinearGradient(
                    colors: [Color(0xFF169060), Color(0xFF1E3A5F)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: (hasAnswers && !isLoading) ? null : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
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
                const SizedBox(width: 12),
              ],
              Text(
                isLoading
                    ? 'Submitting...'
                    : 'Submit ${_getTypeDisplayName(type)} ($answeredCount/$itemCount)',
                style: TextStyle(
                  color: (hasAnswers && !isLoading)
                      ? Colors.white
                      : Colors.grey[600],
                  fontSize: width * 0.045,
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
    double width,
  ) {
    switch (type) {
      case 'MULQ':
        return _buildInteractiveMultipleChoice(
          question,
          questionId,
          'questionnaire',
          width,
        );
      case 'TFQS':
        return _buildInteractiveTrueFalse(questionId, 'questionnaire', width);
      case 'BLKQ':
        return _buildInteractiveTextInput(questionId, 'questionnaire', width);
      default:
        return _buildInteractiveMultipleChoice(
          question,
          questionId,
          'questionnaire',
          width,
        );
    }
  }

  Widget _buildInteractiveGoalOptions(
    Map<String, dynamic> goal,
    String type,
    int goalId,
    double width,
  ) {
    switch (type) {
      case 'MULQ':
        return _buildInteractiveMultipleChoice(goal, goalId, 'goals', width);
      case 'TFQS':
        return _buildInteractiveTrueFalse(goalId, 'goals', width);
      case 'BLKQ':
        return _buildInteractiveTextInput(goalId, 'goals', width);
      default:
        return _buildInteractiveTrueFalse(goalId, 'goals', width);
    }
  }

  Widget _buildInteractiveAdditionalNeedOptions(
    Map<String, dynamic> need,
    String type,
    int needId,
    double width,
  ) {
    switch (type) {
      case 'MULQ':
        return _buildInteractiveMultipleChoice(
          need,
          needId,
          'additional_needs',
          width,
        );
      case 'TFQS':
        return _buildInteractiveTrueFalse(needId, 'additional_needs', width);
      case 'BLKQ':
        return _buildInteractiveTextInput(needId, 'additional_needs', width);
      default:
        return _buildInteractiveTextInput(needId, 'additional_needs', width);
    }
  }

  Widget _buildInteractiveMultipleChoice(
    Map<String, dynamic> item,
    int itemId,
    String type,
    double width,
  ) {
    final List<String> options = [];

    // Handle different field naming for different types
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
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE6F4EA) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: const Color(0xFF169060), width: 1.5)
                  : null,
            ),
            child: ListTile(
              dense: true,
              leading: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF169060))
                  : const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey,
                    ),
              title: Text(
                option,
                style: TextStyle(
                  fontSize: width * 0.038,
                  color: isSelected ? const Color(0xFF169060) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInteractiveTrueFalse(int itemId, String type, double width) {
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
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE6F4EA) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: const Color(0xFF169060), width: 1.5)
                  : null,
            ),
            child: ListTile(
              dense: true,
              leading: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF169060))
                  : const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey,
                    ),
              title: Text(
                option,
                style: TextStyle(
                  fontSize: width * 0.038,
                  color: isSelected ? const Color(0xFF169060) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInteractiveTextInput(int itemId, String type, double width) {
    if (!_textControllers.containsKey(itemId)) {
      _textControllers[itemId] = TextEditingController();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _textControllers[itemId],
        decoration: const InputDecoration(
          hintText: 'Enter your response...',
          border: InputBorder.none,
        ),
        maxLines: 3,
        onChanged: (value) {
          _setSelectedAnswer(itemId, type, value);
        },
      ),
    );
  }

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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
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
}
