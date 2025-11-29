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

class _AddAdvisorRequestScreenState extends State<AddAdvisorRequestScreen>
    with TickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int? _minRating;
  int? _minExperience;
  bool _showFilters = false;
  bool _isApplyingFilters = false;
  bool _isSubmitting = false;



  // Step 1 - Category
  String? selectedCategory;
  int? selectedCategoryId;
  String customCategory = '';
  List<Map<String, dynamic>> categories = [];
  bool loadingCategories = true;

  // Step 2 - Details
  late TextEditingController titleController;
  final descController = TextEditingController();

  // Step 3 - Advisor
  bool knowAdvisor = false;
  Map<String, dynamic>? selectedAdvisor;

  // Questions
  List<Map<String, dynamic>> defaultQuestions = [];
  final answers = <int, String>{};
  final textCtrls = <int, TextEditingController>{};
  bool loadingQuestions = false;

  // Search
  final searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;

  @override
void initState() {
  super.initState();
  titleController = TextEditingController();
  
  // Add listeners to update button state
  titleController.addListener(() {
    setState(() {});
  });
  
  descController.addListener(() {
    setState(() {});
  });
  
  _animationController = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  _fadeAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  );
  _animationController.forward();
  _loadCategories();
}


  @override
  void dispose() {
    _animationController.dispose();
    titleController.dispose();
    descController.dispose();
    searchController.dispose();
    textCtrls.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<String?> token() async =>
      (await SharedPreferences.getInstance()).getString('access_token');
  Future<int?> clientId() async =>
      (await SharedPreferences.getInstance()).getInt('client_id');

  Future<void> _loadCategories() async {
    setState(() => loadingCategories = true);

    final t = await token();
    if (t == null) {
      setState(() => loadingCategories = false);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse(
            'https://ds.singledeck.in/api/v1/master-entry/get-request-categories/'),
        headers: {'sessiontype': 'CLNT', 'sessiontoken': t},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          setState(() {
            categories = List<Map<String, dynamic>>.from(data['data'] ?? []);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }

    setState(() => loadingCategories = false);
  }

  Future<void> loadAdvisorQuestions(int advrId) async {
  setState(() {
    loadingQuestions = true;
    defaultQuestions.clear();
    answers.clear();
    textCtrls.clear();
  });

  final t = await token();
  if (t == null) {
    setState(() => loadingQuestions = false);
    return;
  }
  
  try {
    // ✅ Updated API endpoint with advr_id query parameter
    final res = await http.get(
      Uri.parse(
          'https://ds.singledeck.in/api/v1/adviser/get-advr-list/?advr_id=$advrId'),
      headers: {'sessiontype': 'CLNT', 'sessiontoken': t},
    );
    
    debugPrint('📋 Loading advisor questions: advr_id=$advrId');
    debugPrint('Response: ${res.statusCode}');
    
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == 'success' && data['data'] != null && data['data'].isNotEmpty) {
        final advisorData = data['data'][0];
        final List questions = advisorData['default_questions'] ?? [];
        
        setState(() {
          defaultQuestions = List<Map<String, dynamic>>.from(questions);
          // Sort by display_index
          defaultQuestions.sort((a, b) {
            final indexA = a['default_question']['display_index'] ?? 0;
            final indexB = b['default_question']['display_index'] ?? 0;
            return indexA.compareTo(indexB);
          });
        });
        
        debugPrint('✅ Loaded ${defaultQuestions.length} questions');
      }
    }
  } catch (e) {
    debugPrint('❌ Error loading advisor questions: $e');
  }
  
  setState(() => loadingQuestions = false);
}


  Future<void> loadAdminDefaultQuestions() async {
  setState(() {
    loadingQuestions = true;
    defaultQuestions.clear();
    answers.clear();
    textCtrls.clear();
  });

  final t = await token();
  if (t == null) {
    setState(() => loadingQuestions = false);
    return;
  }

  try {
    final res = await http.get(
      Uri.parse(
          'https://ds.singledeck.in/api/v1/admin/admin-default-questions/'),
      headers: {
        'sessiontype': 'CLNT',
        'sessiontoken': t,
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == 'success' && data['data'] != null) {
        // Remove duplicates by dflq_id - keep only unique questions
        final Map<int, Map<String, dynamic>> uniqueQuestions = {};
        
        for (var q in data['data']) {
          final dflqId = q['addq_dflq']['dflq_id'] as int;
          
          // Only add if not already present (keeps first occurrence)
          if (!uniqueQuestions.containsKey(dflqId)) {
            uniqueQuestions[dflqId] = {
              "addq_id": q['addq_id'], // Use addq_id as the unique identifier
              "default_question": q['addq_dflq'],
            };
          }
        }
        
        setState(() {
          defaultQuestions = uniqueQuestions.values.toList();
          // Sort by display_index
          defaultQuestions.sort((a, b) {
            final indexA = a['default_question']['display_index'] ?? 0;
            final indexB = b['default_question']['display_index'] ?? 0;
            return indexA.compareTo(indexB);
          });
        });
      }
    }
  } catch (e) {
    debugPrint('Error loading admin questions: $e');
  }

  setState(() => loadingQuestions = false);
}



  Future<void> searchAdvisors(String q, {bool applyFilters = false}) async {
  if (q.trim().isEmpty && !applyFilters) {
    setState(() => searchResults.clear());
    return;
  }
  final t = await token();
  if (t == null) return;
  setState(() => isSearching = true);
  try {
    final queryParams = <String, String>{};
    
    if (q.trim().isNotEmpty) {
      queryParams['search'] = q;
    }
    
    if (_minRating != null) {
      queryParams['advr_overall_rating'] = _minRating.toString();
    }
    
    if (_minExperience != null) {
      queryParams['advr_experience_years'] = _minExperience.toString();
    }
    
    final uri = Uri.https('ds.singledeck.in', '/api/v1/adviser/get-advr-list/', queryParams);
    
    debugPrint('🔍 Search URL: $uri');
    
    final res = await http.get(
        uri, headers: {'sessiontype': 'CLNT', 'sessiontoken': t});
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success') {
        setState(() => searchResults = List<Map<String, dynamic>>.from(json['data'] ?? []));
      }
    }
  } catch (e) {
    debugPrint('Search error: $e');
  }
  setState(() => isSearching = false);
}

  Future<bool> submit() async {
  // Prevent multiple submissions
  if (_isSubmitting) return false;
  
  setState(() {
    _isSubmitting = true;
  });

  final cid = await clientId();
  final t = await token();
  
  if (cid == null || t == null) {
    setState(() {
      _isSubmitting = false;
    });
    return false;
  }

  // Map answers to dflq_id by looking up in defaultQuestions
  final List<Map<String, dynamic>> answersPayload = [];
  
  answers.forEach((key, value) {
    final question = defaultQuestions.firstWhere(
      (q) => (q['avdq_id'] ?? q['addq_id']) == key,
      orElse: () => {},
    );
    
    if (question.isNotEmpty && question['default_question'] != null) {
      final dflqId = question['default_question']['dflq_id'];
      answersPayload.add({
        'dflq_id': dflqId,
        'answer': value,
      });
    }
  });

  final payload = {
    'clnt_id': cid,
    'title': titleController.text.trim(),
    'desc': descController.text.trim(),
    'advr_id': knowAdvisor && selectedAdvisor != null
        ? selectedAdvisor!['advr_id']
        : null,
    'assigntype': knowAdvisor ? 'DIRCT' : 'ADMIN',
    'default_qust_answers': jsonEncode(answersPayload),
    if (!knowAdvisor) 'profiling_data': jsonEncode({}),
    if (selectedCategoryId != null) 'avrc_id': selectedCategoryId,
  };

  debugPrint('📤 Submitting payload: ${jsonEncode(payload)}');

  try {
    final res = await http.post(
      Uri.parse('https://ds.singledeck.in/api/v1/adviser/advisor-request/'),
      headers: {
        'sessiontype': 'CLNT',
        'sessiontoken': t,
        'Content-Type': 'application/json'
      },
      body: jsonEncode(payload),
    );
    
    debugPrint('📥 Response: ${res.statusCode}');
    debugPrint('📥 Body: ${res.body}');
    
    setState(() {
      _isSubmitting = false;
    });
    
    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    } else {
      try {
        final errorData = jsonDecode(res.body);
        debugPrint('❌ Error: ${errorData['message'] ?? 'Unknown error'}');
      } catch (_) {}
      return false;
    }
  } catch (e) {
    debugPrint('❌ Exception: $e');
    setState(() {
      _isSubmitting = false;
    });
    return false;
  }
}



  void _nextStep() {
    _animationController.reset();
    setState(() => currentStep++);
    _animationController.forward();
  }

  void _prevStep() {
    _animationController.reset();
    setState(() => currentStep--);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text(
          'Raise Request',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: IndexedStack(
                index: currentStep,
                children: [
                  _stepCategory(),
                  _stepDetails(),
                  _stepAdvisorSelection(),
                  _stepQuestions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepCircle(0, 'Category'),
          _buildStepLine(0),
          _buildStepCircle(1, 'Details'),
          _buildStepLine(1),
          _buildStepCircle(2, 'Advisor'),
          _buildStepLine(2),
          _buildStepCircle(3, 'Review'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = currentStep >= step;
    final isCurrent = currentStep == step;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryDark : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.primaryDark : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isActive && !isCurrent
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppColors.primaryDark : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = currentStep > step;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 30),
        color: isActive ? AppColors.primaryDark : Colors.grey[300],
      ),
    );
  }

  Widget _stepCategory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What type of advice do you need?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a category that best describes your financial needs',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          if (loadingCategories)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: categories.map((category) {
                  final isSelected = selectedCategoryId == category['avrc_id'];
                  final isOther = category['avrc_code'] == 'OTHR';

                  return Column(
                    children: [
                      RadioListTile<int>(
                        title: Text(
                          category['avrc_name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primaryDark
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        subtitle: Text(
                          category['avrc_description'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        value: category['avrc_id'],
                        groupValue: selectedCategoryId,
                        activeColor: AppColors.primaryDark,
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = category['avrc_name'];
                            selectedCategoryId = value;
                            if (!isOther) {
                              titleController.text = category['avrc_name'];
                            } else {
                              titleController.clear();
                            }
                          });
                        },
                      ),
                      if (categories.last != category)
                        Divider(height: 1, color: Colors.grey[200]),
                    ],
                  );
                }).toList(),
              ),
            ),
          if (selectedCategory != null && selectedCategory == 'Other') ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (v) {
                  customCategory = v;
                  titleController.text = v;
                },
                decoration: InputDecoration(
                  labelText: 'Enter your custom category',
                  hintText: 'e.g., Estate Planning, Education Fund',
                  filled: true,
                  fillColor: AppColors.lightGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryDark,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.edit,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: selectedCategory != null &&
                      (selectedCategory != 'Other' || customCategory.isNotEmpty)
                  ? _nextStep
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Keep all other methods (_stepDetails, _stepAdvisorSelection, _stepQuestions, etc.) 
  // exactly as they were in the previous code

  Widget _stepDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide more information about your request',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request Title',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Help with retirement planning',
                    filled: true,
                    fillColor: AppColors.lightGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryDark,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.title,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText:
                        'Tell us about your situation and what you\'re looking for...',
                    filled: true,
                    fillColor: AppColors.lightGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryDark,
                        width: 2,
                      ),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: titleController.text.isNotEmpty &&
                          descController.text.isNotEmpty
                      ? _nextStep
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _stepAdvisorSelection() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do you know your advisor?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Let us know if you want to work with a specific advisor',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _buildAdvisorChoiceCard(
                title: 'Yes, I know',
                subtitle: 'Search and select',
                icon: Icons.person_search,
                isSelected: knowAdvisor,
                onTap: () => setState(() => knowAdvisor = true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAdvisorChoiceCard(
                title: 'No, assign one',
                subtitle: 'We\'ll match you',
                icon: Icons.auto_awesome,
                isSelected: !knowAdvisor,
                onTap: () {
                  setState(() {
                    knowAdvisor = false;
                    selectedAdvisor = null;
                    searchController.clear();
                    searchResults.clear();
                  });
                  loadAdminDefaultQuestions();
                  _nextStep();
                },
              ),
            ),
          ],
        ),
        if (knowAdvisor) ...[
          const SizedBox(height: 32),
          
          // Show selected advisor card if one is selected
          if (selectedAdvisor != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryDark,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                        'https://ds.singledeck.in${selectedAdvisor!['advr_profile_img'] ?? ''}'),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedAdvisor!['advr_fname']} ${selectedAdvisor!['advr_lname']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${selectedAdvisor!['advr_id']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedAdvisor!['advr_expertise_area'] ?? '',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryDark,
                    size: 28,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  selectedAdvisor = null;
                  searchController.clear();
                  searchResults.clear();
                });
              },
              icon: const Icon(Icons.close),
              label: const Text('Change Advisor'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Show search field only if no advisor is selected
          if (selectedAdvisor == null) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (q) {
                      // Only search by text, don't apply filters automatically
                      if (_minRating == null && _minExperience == null) {
                        searchAdvisors(q);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name or expertise...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.primaryDark,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  searchController.clear();
                                  searchResults.clear();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryDark,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _showFilters || _minRating != null || _minExperience != null
                        ? AppColors.primaryDark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryDark,
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: _showFilters || _minRating != null || _minExperience != null
                          ? Colors.white
                          : AppColors.primaryDark,
                    ),
                    onPressed: () {
                      setState(() => _showFilters = !_showFilters);
                    },
                  ),
                ),
              ],
            ),
            
            // Filter Panel
            if (_showFilters) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (_minRating != null || _minExperience != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _minRating = null;
                                _minExperience = null;
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Rating Filter
                    const Text(
                      'Minimum Rating',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [1, 2, 3, 4, 5].map((rating) {
                        final isSelected = _minRating == rating;
                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$rating'),
                              const SizedBox(width: 4),
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _minRating = selected ? rating : null;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primaryDark.withOpacity(0.2),
                          checkmarkColor: AppColors.primaryDark,
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryDark : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primaryDark : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Experience Filter
                    const Text(
                      'Minimum Experience',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [1, 3, 5, 10, 15].map((exp) {
                        final isSelected = _minExperience == exp;
                        return FilterChip(
                          label: Text('$exp+ years'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _minExperience = selected ? exp : null;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primaryDark.withOpacity(0.2),
                          checkmarkColor: AppColors.primaryDark,
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryDark : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primaryDark : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Apply Filters Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_minRating != null || _minExperience != null || searchController.text.isNotEmpty)
                            ? () async {
                                setState(() => _isApplyingFilters = true);
                                await searchAdvisors(searchController.text, applyFilters: true);
                                setState(() {
              _isApplyingFilters = false;
              _showFilters = false; // ✅ Close filter panel after applying
            });
                                
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isApplyingFilters
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Apply Filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    
                    // Active Filters Display
                    if (_minRating != null || _minExperience != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Active Filters:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_minRating != null)
                            Chip(
                              avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
                              label: Text('$_minRating+ Rating'),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() => _minRating = null);
                              },
                              backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (_minExperience != null)
                            Chip(
                              avatar: Icon(Icons.work_outline, size: 16, color: AppColors.primaryDark),
                              label: Text('$_minExperience+ Years'),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() => _minExperience = null);
                              },
                              backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
          ],
          
          // Show search results only if no advisor is selected
          if (selectedAdvisor == null) ...[
            if (isSearching || _isApplyingFilters)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${searchResults.length} advisor${searchResults.length > 1 ? 's' : ''} found',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_minRating != null || _minExperience != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.filter_list, size: 14, color: AppColors.primaryDark),
                              const SizedBox(width: 4),
                              Text(
                                'Filtered',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchResults.length,
                    itemBuilder: (_, i) => _buildAdvisorCard(searchResults[i]),
                  ),
                ],
              )
            else if (searchController.text.isNotEmpty || _minRating != null || _minExperience != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No advisors found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_minRating != null || _minExperience != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
          
          if (selectedAdvisor != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  loadAdvisorQuestions(selectedAdvisor!['advr_id']);
                  _nextStep();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    ),
  );
}

Widget _buildAdvisorCard(Map<String, dynamic> advisor) {
  final name = '${advisor['advr_fname']} ${advisor['advr_lname']}';
  final rating =
      (advisor['advr_overall_rating'] as num?)?.toDouble() ?? 0.0;
  final exp = advisor['advr_experience_years'] ?? 0;
  final advisorId = advisor['advr_id'];

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedAdvisor = advisor;
        searchResults.clear();
      });
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(
                'https://ds.singledeck.in${advisor['advr_profile_img'] ?? ''}'),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $advisorId',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advisor['advr_expertise_area'] ?? '',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.work_outline,
                        size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$exp years',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: 20,
          ),
        ],
      ),
    ),
  );
}


  Widget _buildAdvisorChoiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDark.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? AppColors.primaryDark : Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isSelected ? AppColors.primaryDark : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  

  Widget _stepQuestions() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedAdvisor != null
              ? 'Questions from ${selectedAdvisor!['advr_fname']}'
              : 'Profile Questions',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          selectedAdvisor != null
              ? 'Answer these questions to help your advisor understand your needs'
              : 'These questions will help us match you with the right advisor',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        if (loadingQuestions)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          )
        else if (defaultQuestions.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No additional questions required',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can proceed to submit your request',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: defaultQuestions.length,
            itemBuilder: (_, i) => QuestionCard(
              q: defaultQuestions[i],
              answers: answers,
              controllers: textCtrls,
              onUpdate: () => setState(() {}),
            ),
          ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _prevStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isSubmitting 
                        ? Colors.grey[300]! 
                        : AppColors.primaryDark,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: _isSubmitting 
                        ? Colors.grey[400] 
                        : AppColors.primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        final success = await submit();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Request submitted successfully!'
                                : 'Failed to submit request'),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        if (success) Navigator.pop(context, true);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Submitting...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

}

class QuestionCard extends StatefulWidget {
  final Map<String, dynamic> q;
  final Map<int, String> answers;
  final Map<int, TextEditingController> controllers;
  final VoidCallback onUpdate;

  const QuestionCard({
    required this.q,
    required this.answers,
    required this.controllers,
    required this.onUpdate,
    super.key,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  List<String> getOptions() {
    final dq = widget.q['default_question'];
    final type = (dq['dflq_type'] ?? '').toString().toUpperCase();
    if (type == 'TFQS') return ['Yes', 'No'];
    final opts = <String>[];
    for (var i = 1; i <= 4; i++) {
      final opt = dq['dflq_option$i'];
      if (opt != null && opt.toString().trim().isNotEmpty) opts.add(opt);
    }
    return opts;
  }

  @override
  Widget build(BuildContext context) {
    final dq = widget.q['default_question'];
    
    // ✅ Handle both addq_id (admin) and avdq_id (advisor) safely
    final int? id = widget.q['addq_id'] ?? widget.q['avdq_id'];
    
    if (id == null) {
      debugPrint('❌ Question ID is null: ${widget.q}');
      return const SizedBox.shrink();
    }
    
    final type = (dq['dflq_type'] ?? 'BLKQ').toString().toUpperCase();

    if (!widget.answers.containsKey(id)) widget.answers[id] = '';
    if (type == 'BLKQ' && !widget.controllers.containsKey(id)) {
      widget.controllers[id] = TextEditingController(text: widget.answers[id]);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dq['dflq_question'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          if (type == 'MULQ' || type == 'TFQS')
            ...getOptions().map((opt) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: widget.answers[id] == opt
                        ? AppColors.primaryDark.withOpacity(0.1)
                        : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.answers[id] == opt
                          ? AppColors.primaryDark
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: RadioListTile<String>(
                    title: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: widget.answers[id] == opt
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: widget.answers[id] == opt
                            ? AppColors.primaryDark
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    value: opt,
                    groupValue: widget.answers[id],
                    activeColor: AppColors.primaryDark,
                    onChanged: (v) {
                      widget.answers[id] = v!;
                      widget.onUpdate();
                    },
                  ),
                ))
          else
            TextField(
              controller: widget.controllers[id],
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                filled: true,
                fillColor: AppColors.lightGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryDark,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (v) {
                widget.answers[id] = v;
                widget.onUpdate();
              },
            ),
        ],
      ),
    );
  }
}
