import 'package:flutter/material.dart';

class AdvisorRequestDetailScreen extends StatefulWidget {
  const AdvisorRequestDetailScreen({super.key});

  @override
  State<AdvisorRequestDetailScreen> createState() => _AdvisorRequestDetailScreenState();
}

class _AdvisorRequestDetailScreenState extends State<AdvisorRequestDetailScreen> {
  final List<Map<String, dynamic>> _extraQuestions = const [
    {
      'question': "What is your primary financial goal?",
      'options': [
        'Wealth Accumulation',
        'Retirement Planning',
        'Children’s Education',
        'Other',
      ]
    },
    {
      'question': "What is your investment time horizon?",
      'options': [
        'Less than 3 years',
        '3-5 years',
        '5-10 years',
        'More than 10 years',
      ]
    },
  ];

  final List<Map<String, dynamic>> _questions = const [
    {
      'question':
          "Imagine you're on a TV game show, and you can choose one of the following, which would you choose?",
      'options': [
        r'$500 in cash',
        r'25% chance of winning $5,000',
        r'50% chance of winning $2,000',
        r'5% chance of winning $30,000',
      ],
    },
    {
      'question': "What is your age?",
      'options': ['60, and above', '21 To 40', '41 to 60', 'Under 20'],
    },
    {
      'question':
          "How secure do you see your income is in the coming 3-5 years?",
      'options': [
        'Really insecure',
        'Somewhat secure',
        'Somewhat insecure',
        'Really secure',
      ],
    },
    {
      'question':
          "How much of your take home pay do you think you would be able to save in the coming year?",
      'options': [
        'Approximately 10 to 15%',
        'Approximately 20 to 25%',
        'Approximately 15 to 20%',
        'Over 25%',
      ],
    },
    {
      'question': "What is your after tax annual income?",
      'options': [
        r'$70,000 or less',
        r'$180,001 - $300,000',
        r'$70,001 - $180,000',
        r'Over $300,000',
      ],
    },
    {
      'question':
          "If you had to predict when you think you would need to redeem more than 40% of your investment?",
      'options': [
        'Within 2 - 3 years',
        'Within 5-7 years',
        'Within 3 - 5 years',
        'Greater than 7 years',
      ],
    },
    {
      'question':
          "Please tell us about your level of market and investment knowledge",
      'options': [
        'I have very little interest or experience in investments of any markets',
        'I have held various investments at different times, both in Super and outside of Super',
        'I have some experience in investments, but particularly via my Superfund',
        'I consider myself fairly astute, as it pertains to investment and understand risk',
      ],
    },
    {
      'question':
          "How prepared are you to accept volatility to increase the likelihood of higher returns?",
      'options': [
        'Not very prepared or accepting of volatility',
        'Willing to take on volatility for a majority of my portfolio',
        'Willing to take on volatility for up to 50% of my portfolio',
        'Fully understand and accept the volatility and return tradeoff for my portfolio',
      ],
    },
  ];

  late List<int?> _answers;

  @override
  void initState() {
    super.initState();
    // Initialize answers from arguments or as empty
    _answers = List<int?>.filled(_questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> req =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {
          'name': 'Retirement Planning',
          'status': 'Pending',
          'date': '2025-07-01',
          'reference': 'AR-001',
          'advisorKnown': false,
          'advisorRef': '',
          'response': null,
          'questionnaire': null,
          'answers': null,
          'amount': null,
        };

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 3,
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
              fontSize: width * 0.038,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: width * 0.038,
              fontWeight: FontWeight.normal,
            ),
            isScrollable: true,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Financial Goals'),
              Tab(text: 'Risk Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- Tab 1: Details ---
            SingleChildScrollView(
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
                            req['name'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.05,
                              color: const Color(0xFF1E3A5F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.confirmation_number, color: Color(0xFF169060), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Ref: ${req['reference'] ?? ''}',
                                style: TextStyle(
                                  color: const Color(0xFF666666),
                                  fontSize: width * 0.035,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Icon(Icons.calendar_today, color: Color(0xFF169060), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                req['date'] ?? '',
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
                                req['status'] == 'Completed'
                                    ? Icons.check_circle
                                    : Icons.hourglass_top,
                                color: req['status'] == 'Completed'
                                    ? const Color(0xFF169060)
                                    : const Color(0xFF164454),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                req['status'] ?? '',
                                style: TextStyle(
                                  color: req['status'] == 'Completed'
                                      ? const Color(0xFF169060)
                                      : const Color(0xFF164454),
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.04,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
            ),
            // --- Tab 2: Financial Goals ---
            SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
                    child: Text(
                      'Financial Goals',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ),
                  ),
                  ...List.generate(_extraQuestions.length, (i) {
                    final q = _extraQuestions[i];
                    final answerIdx = (req['extraAnswers'] is List && req['extraAnswers'].length > i)
                        ? req['extraAnswers'][i]
                        : null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['question'],
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A5F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...List.generate(q['options'].length, (optIdx) {
                            final isSelected = answerIdx == optIdx;
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
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
                                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                                title: Text(
                                  q['options'][optIdx],
                                  style: TextStyle(
                                    fontSize: width * 0.038,
                                    color: isSelected ? const Color(0xFF169060) : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            // --- Tab 3: Risk Profile Questionnaire ---
            SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risk Profile Questionnaire',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.045,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(_questions.length, (i) {
                    final q = _questions[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Q${i + 1}: ${q['question']}",
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A5F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...List.generate(q['options'].length, (optIdx) {
                            final isSelected = _answers[i] == optIdx;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _answers[i] = optIdx;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 3),
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
                                      : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                                  title: Text(
                                    q['options'][optIdx],
                                    style: TextStyle(
                                      fontSize: width * 0.038,
                                      color: isSelected ? const Color(0xFF169060) : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Add your submit logic here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Risk Profile Submitted!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF169060), Color(0xFF1E3A5F)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Submit Risk Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
