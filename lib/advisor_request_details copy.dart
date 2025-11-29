import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF1A0A2A);
  static const Color lightGray = Color(0xFFF5F5F5);
}

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
  Map<int, TextEditingController> _defaultQuestionControllers = {};
  Map<int, String> _defaultQuestionAnswers = {};

  bool _isSubmittingQuestionnaire = false;
  bool _isSubmittingGoals = false;
  bool _isSubmittingAdditionalNeeds = false;
  bool _isSubmittingDefaultQuestions = false;

  String? _pdfPath;
  bool _isDownloadingPdf = false;

  // Review variables
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      setState(() {});
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
    _defaultQuestionControllers.values.forEach((controller) => controller.dispose());
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequestDetails(int avrrId) async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final url =
          'https://ds.singledeck.in/api/v1/adviser/client-requests/?avrr_id=$avrrId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'sessiontype': 'CLNT',
          'sessiontoken': token.trim(),
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('📡 Fetching requests: $url');
      debugPrint('Request Details API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' &&
            data['data'] != null &&
            data['data'] is List &&
            data['data'].isNotEmpty) {
          setState(() {
            req = Map<String, dynamic>.from(data['data'][0]);
            _loading = false;
          });

          // Initialize default question controllers and answers
          _initializeDefaultQuestionAnswers();

          _checkExistingPdf(avrrId);
        } else {
          setState(() {
            _error = true;
            _loading = false;
          });
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Logging you out...'),
              backgroundColor: Colors.orange,
            ),
          );
          await prefs.clear();
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Request timed out. Please check your connection.')),
        );
      }
      setState(() {
        _error = true;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching request details: $e');
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  void _initializeDefaultQuestionAnswers() {
    final List<dynamic> defaultQuestions = req!['advr_default_questions'] ?? [];
    
    for (var question in defaultQuestions) {
      final int questionId = question['addq_id'] ?? 0;
      final String answer = question['addq_answer'] ?? '';
      
      _defaultQuestionAnswers[questionId] = answer;
      _defaultQuestionControllers[questionId] = TextEditingController(text: answer);
    }
  }

  Future<void> _submitDefaultQuestionAnswers() async {
    setState(() {
      _isSubmittingDefaultQuestions = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Prepare answers payload
      List<Map<String, dynamic>> answersPayload = [];
      
      _defaultQuestionAnswers.forEach((questionId, answer) {
        if (answer.isNotEmpty) {
          answersPayload.add({
            'addq_id': questionId,
            'answer': answer,
          });
        }
      });

      final url = 'https://ds.singledeck.in/api/v1/adviser/update-default-questions/';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'sessiontype': 'CLNT',
          'sessiontoken': token.trim(),
        },
        body: json.encode({
          'avrr_id': req!['avrr_id'],
          'answers': answersPayload,
        }),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Update Default Questions Response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Answers updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          
          // Refresh data
          _fetchRequestDetails(req!['avrr_id']);
        } else {
          throw Exception(data['message'] ?? 'Failed to update answers');
        }
      } else {
        throw Exception('Failed to update answers');
      }
    } catch (e) {
      debugPrint('Error submitting default question answers: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmittingDefaultQuestions = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a review'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = 'https://ds.singledeck.in/api/v1/adviser/submit-request-review/';

      final payload = {
        'avrr_id': req!['avrr_id'],
        'rating': _rating,
        'review': _reviewController.text.trim(),
      };

      debugPrint('Submitting review: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'sessiontype': 'CLNT',
          'sessiontoken': token.trim(),
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Submit Review Response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Review submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          
          // Clear review form
          setState(() {
            _rating = 0;
            _reviewController.clear();
          });
          
          // Refresh data
          _fetchRequestDetails(req!['avrr_id']);
        } else {
          throw Exception(data['message'] ?? 'Failed to submit review');
        }
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      debugPrint('Error submitting review: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmittingReview = false;
      });
    }
  }

  Future<String> _getDownloadPath() async {
    Directory? directory;

    try {
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');

        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      return directory!.path;
    } catch (e) {
      debugPrint('Error getting download path: $e');
      final tempDir = await getTemporaryDirectory();
      return tempDir.path;
    }
  }

  Future<void> _checkExistingPdf(int avrrId) async {
    try {
      final downloadPath = await _getDownloadPath();
      final file = File('$downloadPath/Solution_Report_$avrrId.pdf');

      if (await file.exists()) {
        setState(() {
          _pdfPath = file.path;
        });
        debugPrint('✅ PDF already exists: ${file.path}');
      }
    } catch (e) {
      debugPrint('Error checking existing PDF: $e');
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt <= 32) {
        final status = await Permission.storage.request();
        return status.isGranted;
      } else {
        return true;
      }
    }
    return true;
  }

  Future<void> _downloadPdf(int avrrId) async {
    final hasPermission = await _requestStoragePermission();

    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to download PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isDownloadingPdf = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        setState(() {
          _isDownloadingPdf = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication required'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final url =
          'https://ds.singledeck.in/api/v1/adviser/genarate-advr-request-details-pdf/?avrr_id=$avrrId&download=pdf';

      debugPrint('📄 Downloading PDF: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'sessiontype': 'CLNT',
          'sessiontoken': token.trim(),
        },
      ).timeout(const Duration(seconds: 60));

      debugPrint('PDF Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final downloadPath = await _getDownloadPath();
        final fileName = 'Solution_Report_$avrrId.pdf';
        final filePath = '$downloadPath/$fileName';
        final file = File(filePath);

        await file.parent.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes, flush: true);

        if (await file.exists()) {
          final fileSize = await file.length();
          debugPrint('✅ PDF saved to Downloads: ${file.path}');
          debugPrint('✅ File size: $fileSize bytes');

          setState(() {
            _pdfPath = file.path;
            _isDownloadingPdf = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF saved to Downloads/$fileName'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Share',
                  textColor: Colors.white,
                  onPressed: () => _sharePdf(),
                ),
              ),
            );
          }
        } else {
          throw Exception('File was not created');
        }
      } else {
        setState(() {
          _isDownloadingPdf = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to download PDF: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error downloading PDF: $e');

      setState(() {
        _isDownloadingPdf = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfPath == null || _pdfPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please download the PDF first')),
      );
      return;
    }

    final file = File(_pdfPath!);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('PDF file not found. Please download again.')),
      );
      setState(() {
        _pdfPath = null;
      });
      return;
    }

    try {
      await Share.shareXFiles(
        [XFile(_pdfPath!)],
        subject: 'Solution Report #${req!['avrr_id']}',
        text: 'Financial Solution Report',
      );
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing PDF: $e')),
      );
    }
  }

  void _viewPdfFullScreen() {
    if (_pdfPath == null || _pdfPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please download the PDF first')),
      );
      return;
    }

    final file = File(_pdfPath!);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('PDF file not found. Please download again.')),
      );
      setState(() {
        _pdfPath = null;
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(
          pdfPath: _pdfPath!,
          requestId: req!['avrr_id']?.toString() ?? '',
          onShare: _sharePdf,
        ),
      ),
    );
  }

  int _getCurrentProgressStep() {
    if (req == null) return 0;

    final String status = req!['avrr_status'] ?? '';
    final String completionStatus = req!['avrr_completion_status'] ?? '';

    if (completionStatus == 'CMPL') {
      return 3;
    } else if (status == 'APVD') {
      return 2;
    } else if (status == 'PEND') {
      return 1;
    }

    return 0;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoadingScreen();
    if (_error || req == null) return _buildErrorScreen();

    final bool isCompleted = req!['avrr_completion_status'] == 'CMPL';
    final bool hasReview = req!['request_review'] != null;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressStepper(),
            const SizedBox(height: 24),
            _buildRequestDetailsCard(),
            const SizedBox(height: 24),
            _buildAssignedAdvisor(),
            const SizedBox(height: 24),
            _buildPdfViewSection(),
            const SizedBox(height: 24),
            _buildAdditionalNeedsSection(),
            const SizedBox(height: 24),
            _buildDefaultQuestionsSection(),
            
            // Show review section only if completed and no review submitted yet
            if (isCompleted && !hasReview) ...[
              const SizedBox(height: 24),
              _buildReviewSection(),
            ],
            
            // Show submitted review if exists
            if (hasReview) ...[
              const SizedBox(height: 24),
              _buildSubmittedReview(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rate_review,
                color: AppColors.primaryDark,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Rate Your Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'How would you rate this advisor?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: index < _rating
                        ? Colors.amber
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          const Text(
            'Write your review',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience with this advisor...',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.lightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primaryDark,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmittingReview ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isSubmittingReview
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedReview() {
    final review = req!['request_review'];
    final int rating = review['avrq_rating'] ?? 0;
    final String reviewText = review['avrq_review'] ?? '';
    final String reviewDate = review['avrq_cdate'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Review',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 24,
                color: index < rating ? Colors.amber : const Color(0xFFCBD5E1),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            reviewText,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF334155),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Submitted on ${_formatDate(reviewDate)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStepper() {
    final currentStep = _getCurrentProgressStep();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepItem(
            icon: Icons.check,
            label: 'Submitted',
            isCompleted: currentStep >= 0,
            isActive: currentStep == 0,
          ),
          _buildStepConnector(isCompleted: currentStep >= 1),
          _buildStepItem(
            icon: Icons.person,
            label: 'Advisor\nAssigned',
            isCompleted: currentStep >= 1,
            isActive: currentStep == 1,
          ),
          _buildStepConnector(isCompleted: currentStep >= 2),
          _buildStepItem(
            icon: Icons.hourglass_top,
            label: 'Under\nReview',
            isCompleted: currentStep >= 3,
            isActive: currentStep == 2,
          ),
          _buildStepConnector(isCompleted: currentStep >= 3),
          _buildStepItem(
            icon: Icons.description_outlined,
            label: 'Report\nDelivered',
            isCompleted: currentStep >= 3,
            isActive: currentStep == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String label,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color iconColor;
    Color iconBgColor;
    Color labelColor;
    FontWeight labelWeight;

    if (isCompleted && !isActive) {
      iconColor = Colors.white;
      iconBgColor = AppColors.primaryDark;
      labelColor = const Color(0xFF334155);
      labelWeight = FontWeight.w500;
    } else if (isActive) {
      iconColor = AppColors.primaryDark;
      iconBgColor = AppColors.primaryDark.withOpacity(0.2);
      labelColor = AppColors.primaryDark;
      labelWeight = FontWeight.bold;
    } else {
      iconColor = const Color(0xFF94A3B8);
      iconBgColor = Colors.transparent;
      labelColor = const Color(0xFF64748B);
      labelWeight = FontWeight.w500;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              border: !isCompleted || isActive
                  ? Border.all(
                      color: isActive
                          ? AppColors.primaryDark
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: labelWeight,
              color: labelColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 40),
        color: isCompleted ? AppColors.primaryDark : const Color(0xFFCBD5E1),
      ),
    );
  }

  Widget _buildRequestDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Request ID', 'FA-2024-${req!['avrr_id']}',
              showBorder: true),
          _buildDetailRow(
              'Request Type', req!['avrr_title'] ?? 'Financial Audit',
              showBorder: true),
          _buildDetailRow('Date Submitted', _formatDate(req!['avrr_rdate']),
              showBorder: false),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {required bool showBorder}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedAdvisor() {
    final advisor = req!['advisor'];
    if (advisor == null) return const SizedBox.shrink();

    final String advisorName =
        '${advisor['advr_fname'] ?? ''} ${advisor['advr_lname'] ?? ''}'.trim();
    final String advisorImage = advisor['advr_profile_img'] ?? '';
    final String advisorRole =
        advisor['advr_expertise_area'] ?? 'Financial Advisor';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Assigned Advisor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                backgroundImage: advisorImage.isNotEmpty
                    ? NetworkImage('https://ds.singledeck.in$advisorImage')
                    : null,
                child: advisorImage.isEmpty
                    ? Text(
                        advisorName.isNotEmpty
                            ? advisorName[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advisorName.isNotEmpty ? advisorName : 'Advisor',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      advisorRole,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPdfViewSection() {
    final List<dynamic> solutions = req!['solutions'] ?? [];
    final List<dynamic> advSolutions =
        solutions.where((s) => s['adrs_solution_source'] == 'ADV').toList();

    if (advSolutions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Solution Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.primaryDark,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solution_Report_${req!['avrr_id']}.pdf',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isDownloadingPdf
                          ? 'Downloading...'
                          : _pdfPath != null
                              ? 'Saved to Downloads'
                              : 'Tap to download',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isDownloadingPdf
                            ? const Color(0xFFFFA500)
                            : _pdfPath != null
                                ? const Color(0xFF10B981)
                                : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (_pdfPath != null) ...[
                IconButton(
                  onPressed: _sharePdf,
                  icon: const Icon(
                    Icons.share,
                    color: AppColors.primaryDark,
                    size: 22,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              _isDownloadingPdf
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        if (_pdfPath != null) {
                          _viewPdfFullScreen();
                        } else {
                          _downloadPdf(req!['avrr_id'] ?? 0);
                        }
                      },
                      icon: Icon(
                        _pdfPath != null ? Icons.visibility : Icons.download,
                        color: AppColors.primaryDark,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalNeedsSection() {
    final List<dynamic> additionalNeeds = req!['additional_needs'] ?? [];
    if (additionalNeeds.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Additional Requirements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        ...additionalNeeds.map((need) => _buildQuestionCard(need, isEditable: false)).toList(),
      ],
    );
  }

  Widget _buildDefaultQuestionsSection() {
    final List<dynamic> defaultQuestions = req!['advr_default_questions'] ?? [];
    if (defaultQuestions.isEmpty) return const SizedBox.shrink();
    
    final bool isCompleted = req!['avrr_completion_status'] == 'CMPL';
    final bool isEditable = !isCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Financial Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            if (isEditable && _hasChangesInDefaultQuestions())
              ElevatedButton(
                onPressed: _isSubmittingDefaultQuestions 
                    ? null 
                    : _submitDefaultQuestionAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: _isSubmittingDefaultQuestions
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
          ],
        ),
        ...defaultQuestions
            .map((question) => _buildDefaultQuestionCard(question, isEditable: isEditable))
            .toList(),
      ],
    );
  }

  bool _hasChangesInDefaultQuestions() {
    final List<dynamic> defaultQuestions = req!['advr_default_questions'] ?? [];
    
    for (var question in defaultQuestions) {
      final int questionId = question['addq_id'] ?? 0;
      final String originalAnswer = question['addq_answer'] ?? '';
      final String currentAnswer = _defaultQuestionAnswers[questionId] ?? '';
      
      if (originalAnswer != currentAnswer) {
        return true;
      }
    }
    
    return false;
  }

  Widget _buildQuestionCard(Map<String, dynamic> need, {required bool isEditable}) {
    final String questionText = need['avra_question'] ?? '';
    final String questionType = need['avra_type'] ?? '';
    final List<dynamic> responses = need['response'] ?? [];
    final bool hasResponse = responses.isNotEmpty;
    final String answer = hasResponse ? responses[0]['adar_answer'] ?? '' : '';

    List<String> options = [];
    if (questionType == 'MULQ') {
      if (need['avra_option1'] != null) options.add(need['avra_option1']);
      if (need['avra_option2'] != null) options.add(need['avra_option2']);
      if (need['avra_option3'] != null) options.add(need['avra_option3']);
      if (need['avra_option4'] != null) options.add(need['avra_option4']);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (hasResponse)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Answered',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (hasResponse) ...[
            const SizedBox(height: 12),
            if (questionType == 'MULQ' && options.isNotEmpty) ...[
              ...options.map((option) {
                final bool isSelected = option == answer;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryDark.withOpacity(0.1)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: AppColors.primaryDark,
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? AppColors.primaryDark
                            : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? AppColors.primaryDark
                                : const Color(0xFF334155),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  answer,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultQuestionCard(Map<String, dynamic> question, {required bool isEditable}) {
    final Map<String, dynamic> dflq = question['addq_dflq'] ?? {};
    final int questionId = question['addq_id'] ?? 0;
    final String questionText = dflq['dflq_question'] ?? '';
    final String questionType = dflq['dflq_type'] ?? '';
    final String originalAnswer = question['addq_answer'] ?? '';
    
    // Get current answer from state
    final String currentAnswer = _defaultQuestionAnswers[questionId] ?? originalAnswer;

    List<String> options = [];
    if (questionType == 'MULQ') {
      if (dflq['dflq_option1'] != null) options.add(dflq['dflq_option1']);
      if (dflq['dflq_option2'] != null) options.add(dflq['dflq_option2']);
      if (dflq['dflq_option3'] != null) options.add(dflq['dflq_option3']);
      if (dflq['dflq_option4'] != null) options.add(dflq['dflq_option4']);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isEditable && currentAnswer != originalAnswer
            ? Border.all(color: AppColors.primaryDark.withOpacity(0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (currentAnswer.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isEditable && currentAnswer != originalAnswer
                        ? Colors.orange
                        : AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isEditable && currentAnswer != originalAnswer ? 'Modified' : 'Answered',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (currentAnswer.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (questionType == 'MULQ' && options.isNotEmpty) ...[
              ...options.map((option) {
                final bool isSelected = option == currentAnswer;
                return GestureDetector(
                  onTap: isEditable
                      ? () {
                          setState(() {
                            _defaultQuestionAnswers[questionId] = option;
                          });
                        }
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryDark.withOpacity(0.1)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.primaryDark,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.primaryDark
                              : const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : const Color(0xFF334155),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isEditable)
                          Icon(
                            Icons.edit,
                            size: 16,
                            color: const Color(0xFF94A3B8),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ] else if (questionType == 'TFQS') ...[
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: isEditable
                          ? () {
                              setState(() {
                                _defaultQuestionAnswers[questionId] = 'True';
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: currentAnswer == 'True'
                              ? AppColors.primaryDark.withOpacity(0.1)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: currentAnswer == 'True'
                              ? Border.all(
                                  color: AppColors.primaryDark,
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              currentAnswer == 'True'
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: currentAnswer == 'True'
                                  ? AppColors.primaryDark
                                  : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Yes',
                              style: TextStyle(
                                fontSize: 14,
                                color: currentAnswer == 'True'
                                    ? AppColors.primaryDark
                                    : const Color(0xFF334155),
                                fontWeight: currentAnswer == 'True'
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: isEditable
                          ? () {
                              setState(() {
                                _defaultQuestionAnswers[questionId] = 'False';
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: currentAnswer == 'False'
                              ? AppColors.primaryDark.withOpacity(0.1)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: currentAnswer == 'False'
                              ? Border.all(
                                  color: AppColors.primaryDark,
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              currentAnswer == 'False'
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: currentAnswer == 'False'
                                  ? AppColors.primaryDark
                                  : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'No',
                              style: TextStyle(
                                fontSize: 14,
                                color: currentAnswer == 'False'
                                    ? AppColors.primaryDark
                                    : const Color(0xFF334155),
                                fontWeight: currentAnswer == 'False'
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // BLKQ - Text input
              TextField(
                controller: _defaultQuestionControllers[questionId],
                enabled: isEditable,
                onChanged: (value) {
                  setState(() {
                    _defaultQuestionAnswers[questionId] = value;
                  });
                },
                maxLines: null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isEditable 
                      ? AppColors.lightGray 
                      : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primaryDark,
                      width: 2,
                    ),
                  ),
                  suffixIcon: isEditable
                      ? Icon(
                          Icons.edit,
                          size: 16,
                          color: const Color(0xFF94A3B8),
                        )
                      : null,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE53935),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load request details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please try again later',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
                final int avrrId = args['avrr_id'];
                _fetchRequestDetails(avrrId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;
  final String requestId;
  final VoidCallback onShare;

  const PDFViewerScreen({
    Key? key,
    required this.pdfPath,
    required this.requestId,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Solution Report #$requestId',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: onShare,
          ),
        ],
      ),
      body: SfPdfViewer.file(
        File(pdfPath),
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
      ),
    );
  }
}
