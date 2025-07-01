import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'emoji': '🚀',
      'quote': 'Big dreams need smart plans.',
      'subtext': 'Connect with expert financial advisors to start building your future today.',
    },
    {
      'emoji': '🤝',
      'quote': 'Your goals. Our guidance.',
      'subtext': 'Get personalized advice from certified professionals who care about your success.',
    },
    {
      'emoji': '💡',
      'quote': 'We ask the right questions, so you get the right answers.',
      'subtext': 'Let our smart assistant understand your needs and connect you to the right advisor.',
    },
  ];

  double scaleFont(double size, BuildContext context) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onGetStarted() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo at the top for all slides
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.05, bottom: height * 0.03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color(0xFF242C57),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    'Financial',
                                    style: TextStyle(
                                      fontSize: scaleFont(20, context),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: height * 0.03,
                                    vertical: height * 0.01,
                                  ),
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF169060), Color(0xFF175B58), Color(0xFF19214F)],
                                      stops: [0.30, 0.70, 1],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: Text(
                                    'Advisor',
                                    style: TextStyle(
                                      fontSize: scaleFont(20, context),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      slide['emoji'] ?? '',
                      style: TextStyle(fontSize: scaleFont(48, context)),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      child: Text(
                        slide['quote'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: scaleFont(26, context),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A5F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.12),
                      child: Text(
                        slide['subtext'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: scaleFont(16, context),
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentPage == i ? 25 : 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _currentPage == i ? const Color(0xFF00A962) : const Color(0xFFD3D3D3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 30),
                    // Buttons
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentPage < _slides.length - 1)
                            TextButton(
                              onPressed: _onSkip,
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: scaleFont(18, context),
                                  color: const Color(0xFF1E3A5F),
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 60),
                          if (_currentPage < _slides.length - 1)
                            ElevatedButton(
                              onPressed: _onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF169060),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: scaleFont(18, context),
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: _onGetStarted,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF169060),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: scaleFont(18, context),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}