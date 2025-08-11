import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  double scaleFont(double size, BuildContext context) {
    return size * MediaQuery.of(context).size.width / 375;
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
          'https://ss.singledeck.in/api/v1/adviser/advisor-profile-details/',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> advisors = data['data'];
          if (query.isNotEmpty) {
            advisors = advisors
                .where((advisor) => advisor['advr_full_name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
                .toList();
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
          'https://ss.singledeck.in/api/v1/adviser/advisor-profile-details/?advr_id=$advrId',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
        Uri.parse('https://ss.singledeck.in/api/v1/admin/admin-default-questions/'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          setState(() {
            defaultQuestions = List<Map<String, dynamic>>.from(
              data['data'].map((q) => {
                "avdq_id": q['addq_id'], // We use this as a unique key for the widget tree
                "default_question": q['addq_dflq']
              }),
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
    // Build answers list
    final answersList = defaultAnswers.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => {
              "dflq_id": e.key,
              "answer": e.value,
            })
        .toList();

    // Prepare payload
    final payload = {
      'clnt_id': clntId,
      'title': title,
      'advr_id': advrId,
      'desc': desc,
      'assigntype': assignType,
      // encode the list to a JSON string
      'default_qust_answers': json.encode(answersList),
    };

    debugPrint("Submitting payload: $payload");

    final response = await http.post(
      Uri.parse('https://ss.singledeck.in/api/v1/adviser/advisor-request/'),
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
        const SnackBar(
            content: Text('Please enter request name'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (advisorKnown && selectedAdvisor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select an advisor'),
            backgroundColor: Colors.red),
      );
      return;
    }
    final clientId = await _getClientIdFromPrefs();
    if (clientId == null || clientId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Client ID not found. Please login again.'),
            backgroundColor: Colors.red),
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
        const SnackBar(
            content: Text('Request submitted successfully!'),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to submit request. Please try again.'),
            backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildDefaultQuestionWidget(
    int widgetId, // avdq_id or addq_id for key
    String type,
    String questionText,
    Map<String, dynamic> dq,
    double width,
  ) {
    final int dflqId = dq['dflq_id']!;
    type = type.trim().toUpperCase();

    if (!defaultAnswers.containsKey(dflqId)) {
      defaultAnswers[dflqId] = '';
      if (type == 'BLKQ') {
        textControllers[dflqId] = TextEditingController(text: '');
      }
    }
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(questionText,
                style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A5F))),
            const SizedBox(height: 12),
            if (type == 'MULQ')
              _buildMultipleChoiceOptions(
                dflqId,
                width,
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
              _buildMultipleChoiceOptions(dflqId, width, ['True', 'False'])
            else if (type == 'BLKQ')
              _buildTextAnswer(dflqId, width)
            else
              Text('Unsupported question type: $type'),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(int id, double width, List<String> options) {
    return Column(
      children: options.map((opt) {
        final isSelected = defaultAnswers[id] == opt;
        return GestureDetector(
          onTap: () => setState(() => defaultAnswers[id] = opt),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE6F4EA) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border:
                  isSelected ? Border.all(color: const Color(0xFF169060), width: 1.5) : null,
            ),
            child: ListTile(
              dense: true,
              leading: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF169060))
                  : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
              title: Text(opt,
                  style: TextStyle(
                      fontSize: width * 0.038,
                      color: isSelected ? const Color(0xFF169060) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextAnswer(int id, double width) {
    if (!textControllers.containsKey(id)) {
      textControllers[id] = TextEditingController();
    }
    return TextField(
      controller: textControllers[id],
      maxLines: 3,
      decoration: const InputDecoration(
        hintText: 'Enter your answer...',
        border: OutlineInputBorder(),
      ),
      onChanged: (val) => defaultAnswers[id] = val,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: Column(
        children: [
          // Top bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
                stops: [0.30, 0.70, 1],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text('Add Advisor Request',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: scaleFont(22, context))),
                ),
                Positioned(
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Request Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (val) => requestName = val,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      maxLines: 3,
                      onChanged: (val) => description = val,
                    ),
                    const SizedBox(height: 20),
                    const Text('Do you know the advisor?', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Radio<bool>(
                            value: true,
                            groupValue: advisorKnown,
                            onChanged: (val) {
                              setState(() {
                                advisorKnown = true;
                                selectedAdvisor = null;
                                searchController.clear();
                                defaultQuestions.clear();
                                defaultAnswers.clear();
                                textControllers.clear();
                                showAdvisorList = false;
                              });
                            }),
                        const Text('Yes'),
                        Radio<bool>(
                            value: false,
                            groupValue: advisorKnown,
                            onChanged: (val) {
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
                            }),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: selectedAdvisor != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      selectedAdvisor = null;
                                      searchController.clear();
                                      defaultQuestions.clear();
                                      defaultAnswers.clear();
                                      textControllers.clear();
                                    });
                                  },
                                )
                              : null,
                        ),
                        readOnly: selectedAdvisor != null ? false : false, // always editable now
                        // The search box will always be editable now
                        onChanged: selectedAdvisor != null
                            ? (val) {
                                // If editing, clear the selection and trigger search
                                setState(() {
                                  selectedAdvisor = null;
                                  searchQuery = val;
                                  isLoadingAdvisors = true;
                                  showAdvisorList = true;
                                  defaultQuestions.clear();
                                  defaultAnswers.clear();
                                  textControllers.clear();
                                });
                                _fetchAdvisors(val).then((advisors) {
                                  setState(() {
                                    filteredAdvisors = advisors;
                                    isLoadingAdvisors = false;
                                  });
                                });
                              }
                            : (val) {
                                setState(() {
                                  searchQuery = val;
                                  isLoadingAdvisors = true;
                                  showAdvisorList = true;
                                });
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
                      const SizedBox(height: 8),
                      if (showAdvisorList &&
                          filteredAdvisors.isNotEmpty &&
                          !isLoadingAdvisors &&
                          selectedAdvisor == null)
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8)),
                          child: ListView.builder(
                            itemCount: filteredAdvisors.length,
                            itemBuilder: (context, index) {
                              final advisor = filteredAdvisors[index];
                              return ListTile(
                                title: Text(advisor['advr_full_name']),
                                subtitle: Text(
                                  'ID: ${advisor['advr_uid']} • ${advisor['advr_expertise_area']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedAdvisor = advisor;
                                    searchController.text = advisor['advr_full_name'];
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
                      if (advisorKnown && selectedAdvisor != null) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text('Advisor Questions',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                            const SizedBox(width: 10),
                            if (isLoadingQuestions)
                              const SizedBox(
                                  height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            else
                              Text('(${defaultQuestions.length})',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...defaultQuestions.map((q) {
                          final dq = q['default_question'];
                          return _buildDefaultQuestionWidget(
                              q['avdq_id'] ?? q['addq_id'],
                              dq['dflq_type'],
                              dq['dflq_question'],
                              dq,
                              width);
                        }).toList(),
                      ]
                    ],
                    if (!advisorKnown ) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text("Advisor Questions",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                          const SizedBox(width: 10),
                          if (isLoadingQuestions)
                            const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          else
                            Text('(${defaultQuestions.length})',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...defaultQuestions.map((q) {
                        final dq = q['default_question'];
                        return _buildDefaultQuestionWidget(
                            q['avdq_id'] ?? q['addq_id'],
                            dq['dflq_type'],
                            dq['dflq_question'],
                            dq,
                            width);
                      }).toList(),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _submit,
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
                          child: const Text('Submit',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
