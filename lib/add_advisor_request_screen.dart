import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'color_constants.dart';

class AddAdvisorRequestScreen extends StatefulWidget {
  const AddAdvisorRequestScreen({super.key});

  @override
  State<AddAdvisorRequestScreen> createState() =>
      _AddAdvisorRequestScreenState();
}

class _AddAdvisorRequestScreenState extends State<AddAdvisorRequestScreen> {
  String requestName = '';
  String description = '';
  bool advisorKnown = true;
  Map<String, dynamic>? selectedAdvisor;
  String searchQuery = '';
  List<Map<String, dynamic>> filteredAdvisors = [];
  bool isLoadingAdvisors = false;
  bool showAdvisorList = false;

  List<Map<String, dynamic>> defaultQuestions = [];
  Map<int, String> defaultAnswers = {};
  Map<int, TextEditingController> textControllers = {};

  bool isLoadingQuestions = false;
  final TextEditingController searchController = TextEditingController();

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

  Future<int?> _getClientIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('client_id');
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAdvisors(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://ds.singledeck.in/api/v1/adviser/advisor-profile-details/',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('=== ADVISORS RAW ===');
        print(const JsonEncoder.withIndent('  ').convert(data));
        if (data['status'] == 'success') {
          List<dynamic> advisors = data['data'];
          if (query.isNotEmpty) {
            advisors = advisors.where((advisor) {
              final firstName = advisor['advr_fname']?.toString().trim() ?? '';
              final lastName = advisor['advr_lname']?.toString().trim() ?? '';
              final fullName = '$firstName $lastName'.trim();
              return fullName.toLowerCase().contains(query.toLowerCase());
            }).toList();
          }
          return advisors.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching advisors: $e');
      return [];
    }
  }

  Future<void> _fetchDefaultQuestions(int advrId) async {
    setState(() {
      isLoadingQuestions = true;
      defaultQuestions.clear();
      defaultAnswers.clear();
      textControllers.clear();
    });
    try {
      final response = await http.get(
        Uri.parse(
          'https://ds.singledeck.in/api/v1/adviser/advisor-profile-details/?advr_id=$advrId',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('=== ADVISOR QUESTIONS RAW ===');
        print(const JsonEncoder.withIndent('  ').convert(data));
        if (data['status'] == 'success' && data['data'].isNotEmpty) {
          final questions = data['data'][0]['default_questions'] ?? [];
          setState(() {
            defaultQuestions = List<Map<String, dynamic>>.from(questions);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching default questions: $e');
    } finally {
      setState(() {
        isLoadingQuestions = false;
      });
    }
  }

  Future<void> _fetchAdminDefaultQuestions() async {
    setState(() {
      isLoadingQuestions = true;
      defaultQuestions.clear();
      defaultAnswers.clear();
      textControllers.clear();
    });
    try {
      final response = await http.get(
        Uri.parse(
          'https://ds.singledeck.in/api/v1/admin/admin-default-questions/',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('=== ADMIN QUESTIONS RAW ===');
        print(const JsonEncoder.withIndent('  ').convert(data));
        if (data['status'] == 'success' && data['data'] != null) {
          setState(() {
            defaultQuestions = List<Map<String, dynamic>>.from(
              data['data'].map(
                (q) => {
                  "avdq_id": q['addq_id'],
                  "default_question": q['addq_dflq'],
                },
              ),
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching admin default questions: $e');
    } finally {
      setState(() {
        isLoadingQuestions = false;
      });
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
      final answersList = defaultAnswers.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => {"dflq_id": e.key, "answer": e.value})
          .toList();

      final payload = {
        'clnt_id': clntId,
        'title': title,
        'advr_id': advrId,
        'desc': desc,
        'assigntype': assignType,
        'default_qust_answers': json.encode(answersList),
      };

      debugPrint("Submitting payload: $payload");

      final response = await http.post(
        Uri.parse('https://ds.singledeck.in/api/v1/adviser/advisor-request/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      debugPrint('Response submitRequest: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting request: $e');
      return false;
    }
  }

  void _submit() async {
    if (requestName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter request name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (advisorKnown && selectedAdvisor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an advisor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final clientId = await _getClientIdFromPrefs();
    if (clientId == null || clientId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Client ID not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _submitRequest(
      clntId: clientId,
      title: requestName,
      desc: description,
      advrId: advisorKnown ? selectedAdvisor!['advr_id'] : null,
      assignType: advisorKnown ? 'DIRCT' : 'ADMIN',
    );

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request submitted successfully!'),
          backgroundColor: primaryColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit request. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient (35% from top)
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
                // Header
                _buildHeader(),

                SizedBox(height: scaleHeight(20)),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(20)),
                    child: _buildFormCard(),
                  ),
                ),
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
              'Add Advisor Request',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: scaleFont(24),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(width: scaleWidth(36)), // Balance layout
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: EdgeInsets.all(scaleWidth(24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Request Name Field
          Text(
            'Request Name',
            style: TextStyle(
              fontSize: scaleFont(16),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: scaleHeight(8)),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter request name',
              hintStyle: TextStyle(
                fontSize: scaleFont(14),
                color: Colors.grey.shade500,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: scaleWidth(16),
                vertical: scaleHeight(16),
              ),
            ),
            style: TextStyle(fontSize: scaleFont(14), color: Colors.black87),
            onChanged: (val) => requestName = val,
          ),

          SizedBox(height: scaleHeight(20)),

          // Description Field
          Text(
            'Description',
            style: TextStyle(
              fontSize: scaleFont(16),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: scaleHeight(8)),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter description',
              hintStyle: TextStyle(
                fontSize: scaleFont(14),
                color: Colors.grey.shade500,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: scaleWidth(16),
                vertical: scaleHeight(16),
              ),
            ),
            style: TextStyle(fontSize: scaleFont(14), color: Colors.black87),
            maxLines: 3,
            onChanged: (val) => description = val,
          ),

          SizedBox(height: scaleHeight(24)),

          // Advisor Known Section
          Text(
            'Do you know the advisor?',
            style: TextStyle(
              fontSize: scaleFont(16),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: scaleHeight(8)),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      advisorKnown = true;
                      selectedAdvisor = null;
                      searchController.clear();
                      defaultQuestions.clear();
                      defaultAnswers.clear();
                      textControllers.clear();
                      showAdvisorList = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleWidth(16),
                      vertical: scaleHeight(12),
                    ),
                    decoration: BoxDecoration(
                      color: advisorKnown
                          ? primaryColor.withOpacity(0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: advisorKnown
                            ? primaryColor
                            : Colors.grey.shade300,
                        width: advisorKnown ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          advisorKnown
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: advisorKnown
                              ? primaryColor
                              : Colors.grey.shade500,
                          size: scaleFont(20),
                        ),
                        SizedBox(width: scaleWidth(8)),
                        Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: scaleFont(14),
                            fontWeight: advisorKnown
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: advisorKnown
                                ? primaryColor
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: scaleWidth(12)),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      advisorKnown = false;
                      selectedAdvisor = null;
                      searchController.clear();
                      searchQuery = '';
                      filteredAdvisors = [];
                      showAdvisorList = false;
                      defaultQuestions.clear();
                      defaultAnswers.clear();
                      textControllers.clear();
                    });
                    _fetchAdminDefaultQuestions();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleWidth(16),
                      vertical: scaleHeight(12),
                    ),
                    decoration: BoxDecoration(
                      color: !advisorKnown
                          ? primaryColor.withOpacity(0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !advisorKnown
                            ? primaryColor
                            : Colors.grey.shade300,
                        width: !advisorKnown ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          !advisorKnown
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: !advisorKnown
                              ? primaryColor
                              : Colors.grey.shade500,
                          size: scaleFont(20),
                        ),
                        SizedBox(width: scaleWidth(8)),
                        Text(
                          'No',
                          style: TextStyle(
                            fontSize: scaleFont(14),
                            fontWeight: !advisorKnown
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: !advisorKnown
                                ? primaryColor
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Advisor Search (if known)
          if (advisorKnown) ...[
            SizedBox(height: scaleHeight(20)),
            Text(
              'Select Advisor',
              style: TextStyle(
                fontSize: scaleFont(16),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: scaleHeight(8)),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: selectedAdvisor != null
                    ? 'Selected: ${selectedAdvisor!['advr_fname']} ${selectedAdvisor!['advr_lname']}'
                          .trim()
                    : 'Search and select advisor',
                hintStyle: TextStyle(
                  fontSize: scaleFont(14),
                  color: selectedAdvisor != null
                      ? primaryColor
                      : Colors.grey.shade500,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Container(
                  margin: EdgeInsets.all(scaleWidth(8)),
                  padding: EdgeInsets.all(scaleWidth(8)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.1),
                        secondaryColor.withOpacity(0.1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.search,
                    color: primaryColor,
                    size: scaleFont(18),
                  ),
                ),
                suffixIcon: selectedAdvisor != null
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAdvisor = null;
                            searchController.clear();
                            defaultQuestions.clear();
                            defaultAnswers.clear();
                            textControllers.clear();
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(scaleWidth(8)),
                          padding: EdgeInsets.all(scaleWidth(8)),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.clear,
                            color: Colors.red,
                            size: scaleFont(18),
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: scaleWidth(16),
                  vertical: scaleHeight(16),
                ),
              ),
              style: TextStyle(fontSize: scaleFont(14), color: Colors.black87),
              onChanged: (val) {
                if (selectedAdvisor != null) {
                  setState(() {
                    selectedAdvisor = null;
                    searchQuery = val;
                    isLoadingAdvisors = true;
                    showAdvisorList = true;
                    defaultQuestions.clear();
                    defaultAnswers.clear();
                    textControllers.clear();
                  });
                } else {
                  setState(() {
                    searchQuery = val;
                    isLoadingAdvisors = true;
                    showAdvisorList = true;
                  });
                }
                _fetchAdvisors(val).then((advisors) {
                  setState(() {
                    filteredAdvisors = advisors;
                    isLoadingAdvisors = false;
                  });
                });
              },
              onTap: () {
                setState(() {
                  showAdvisorList = true;
                });
              },
            ),

            // Advisor List
            if (showAdvisorList &&
                filteredAdvisors.isNotEmpty &&
                !isLoadingAdvisors &&
                selectedAdvisor == null)
              Container(
                margin: EdgeInsets.only(top: scaleHeight(8)),
                height: scaleHeight(150),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: filteredAdvisors.length,
                  itemBuilder: (context, index) {
                    final advisor = filteredAdvisors[index];
                    final firstName = advisor['advr_fname'] ?? '';
                    final lastName = advisor['advr_lname'] ?? '';
                    final fullName = '$firstName $lastName'.trim();

                    return ListTile(
                      title: Text(
                        fullName,
                        style: TextStyle(
                          fontSize: scaleFont(14),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${advisor['advr_uid']} • ${advisor['advr_expertise_area']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: scaleFont(12),
                          color: Colors.grey[600],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedAdvisor = advisor;
                          searchController.text = fullName; // ← Use fullName
                          showAdvisorList = false;
                          defaultQuestions.clear();
                          defaultAnswers.clear();
                          textControllers.clear();
                        });
                        _fetchDefaultQuestions(advisor['advr_id']);
                      },
                    );
                  },
                ),
              ),
          ],

          // Questions Section
          if ((advisorKnown && selectedAdvisor != null) || !advisorKnown) ...[
            SizedBox(height: scaleHeight(24)),
            Row(
              children: [
                Text(
                  'Questions',
                  style: TextStyle(
                    fontSize: scaleFont(18),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: scaleWidth(12)),
                if (isLoadingQuestions)
                  SizedBox(
                    height: scaleWidth(18),
                    width: scaleWidth(18),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  )
                else
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
                      '${defaultQuestions.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: scaleFont(12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: scaleHeight(16)),
            ...defaultQuestions.map((q) {
              final dq = q['default_question'];
              return _buildDefaultQuestionWidget(
                q['avdq_id'] ?? q['addq_id'],
                dq['dflq_type'],
                dq['dflq_question'],
                dq,
              );
            }).toList(),
          ],

          SizedBox(height: scaleHeight(32)),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _submit,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: scaleHeight(16)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      offset: Offset(0, 4),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Text(
                  'Submit Request',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: scaleFont(16),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultQuestionWidget(
    int widgetId,
    String type,
    String questionText,
    Map<String, dynamic> dq,
  ) {
    final int dflqId = dq['dflq_id']!;
    type = type.trim().toUpperCase();

    if (!defaultAnswers.containsKey(dflqId)) {
      defaultAnswers[dflqId] = '';
      if (type == 'BLKQ') {
        textControllers[dflqId] = TextEditingController(text: '');
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: scaleHeight(16)),
      padding: EdgeInsets.all(scaleWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionText,
            style: TextStyle(
              fontSize: scaleFont(16),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: scaleHeight(12)),
          if (type == 'MULQ')
            _buildMultipleChoiceOptions(
              dflqId,
              [
                    dq['dflq_option1'],
                    dq['dflq_option2'],
                    dq['dflq_option3'],
                    dq['dflq_option4'],
                  ]
                  .where((o) => o != null && o.toString().isNotEmpty)
                  .cast<String>()
                  .toList(),
            )
          else if (type == 'TFQS')
            _buildMultipleChoiceOptions(dflqId, ['True', 'False'])
          else if (type == 'BLKQ')
            _buildTextAnswer(dflqId)
          else
            Text('Unsupported question type: $type'),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(int id, List<String> options) {
    return Column(
      children: options.map((opt) {
        final isSelected = defaultAnswers[id] == opt;
        return GestureDetector(
          onTap: () => setState(() => defaultAnswers[id] = opt),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: scaleHeight(4)),
            padding: EdgeInsets.all(scaleWidth(12)),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withOpacity(0.1)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? primaryColor : Colors.grey.shade500,
                  size: scaleFont(20),
                ),
                SizedBox(width: scaleWidth(12)),
                Expanded(
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: scaleFont(14),
                      color: isSelected ? primaryColor : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextAnswer(int id) {
    if (!textControllers.containsKey(id)) {
      textControllers[id] = TextEditingController();
    }
    return TextField(
      controller: textControllers[id],
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Enter your answer...',
        hintStyle: TextStyle(
          fontSize: scaleFont(14),
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.all(scaleWidth(12)),
      ),
      style: TextStyle(fontSize: scaleFont(14), color: Colors.black87),
      onChanged: (val) => defaultAnswers[id] = val,
    );
  }
}
