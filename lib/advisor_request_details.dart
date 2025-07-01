import 'package:flutter/material.dart';

class AdvisorRequestDetailScreen extends StatelessWidget {
  const AdvisorRequestDetailScreen({super.key});

  // The same questions and options as in your HomeScreen
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A5F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Request Details',
          style: TextStyle(
            color: const Color(0xFF1E3A5F),
            fontWeight: FontWeight.bold,
            fontSize: width * 0.055,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: height * 0.03,
        ),
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
                        Icon(
                          Icons.confirmation_number,
                          color: Color(0xFF169060),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ref: ${req['reference']}',
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
                          req['status'],
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
            SizedBox(height: height * 0.03),
            if (req['status'] == 'Pending')
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.045),
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
                            if (req['name'] != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  "Name: ${req['name']}",
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    color: const Color(0xFF242C57),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (req['amount'] != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  "Initial Investment: \$${req['amount']}",
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    color: const Color(0xFF169060),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ...List.generate(_questions.length, (i) {
                              final q = _questions[i];
                              final answerIdx =
                                  (req['answers'] is List &&
                                      req['answers'].length > i)
                                  ? req['answers'][i]
                                  : null;
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        answerIdx != null
                                            ? q['options'][answerIdx]
                                            : "No answer selected",
                                        style: TextStyle(
                                          fontSize: width * 0.038,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
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
            if (req['status'] == 'Completed')
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.045),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Advisor Response',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: width * 0.045,
                                color: const Color(0xFF1E3A5F),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              req['response'] ??
                                  'Your advisor has provided a detailed response and recommendations for your request.',
                              style: TextStyle(
                                color: const Color(0xFF666666),
                                fontSize: width * 0.038,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Risk Profile Questionnaire',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: width * 0.045,
                                color: const Color(0xFF1E3A5F),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              req['questionnaire'] ??
                                  'You have completed the risk profile questionnaire.',
                              style: TextStyle(
                                color: const Color(0xFF666666),
                                fontSize: width * 0.038,
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
      ),
    );
  }
}
