import 'package:flutter/material.dart';
import 'color_constants.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;

  late final AnimationController _animationController;

  final List<Map<String, String>> _slides = [
    {
      'quote': 'Smart plans, not just big dreams.',
      'subtext':
          'Some journeys aren’t about rushing. They’re about keep going no matter what.\n\nWe help you move toward wealth creation — not by rushing, but with timing, accuracy, and trailblazing energy that turns a path into a purpose.',
    },
    {
      'quote': 'Driven by your goals, powered by our expertise.',
      'subtext':
          'Expert guidance that’s prompt, personalised, and grounded in real data.',
    },
    {
      'quote': 'We ask the right questions, so you get the right answers.',
      'subtext':
          'Let our smart assistant understand your needs and connect you to the right advisor.',
    },
  ];

  double scaleFont(double size, BuildContext context) {
    return size * MediaQuery.of(context).size.width / 375;
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onGetStarted() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // White background as requested
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: height),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: height * 0.05,
                              bottom: height * 0.06,
                            ),
                            child: Image.asset(
                              'assets/Polar_FavIcon.png',
                              width: height * 0.16,
                              height: height * 0.16,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Header / Quote
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                            child: Text(
                              slide['quote'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: scaleFont(26, context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark, // #1A0A2A
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Subtext
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.12),
                            child: Text(
                              slide['subtext'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: scaleFont(16, context),
                                color: AppColors.primaryDark, // #F5F5F5
                                height: 1.6,
                              ),
                            ),
                          ),
                          const Spacer(),

                          // Page Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_slides.length, (i) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: _currentPage == i ? 28 : 12,
                                height: 12,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: _currentPage == i
                                      ? AppColors.primaryDark
                                      : AppColors.primaryDark.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 30),

                          // Buttons
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                            child: _currentPage < _slides.length - 1
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: _onSkip,
                                        child: Text(
                                          'Skip',
                                          style: TextStyle(
                                            fontSize: scaleFont(18, context),
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: _onNext,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryDark, // Solid #1A0A2A
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: Text(
                                          'Next',
                                          style: TextStyle(
                                            fontSize: scaleFont(18, context),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: ElevatedButton(
                                      onPressed: _onGetStarted,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryDark, // Solid #1A0A2A
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 60,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        'Get Started',
                                        style: TextStyle(
                                          fontSize: scaleFont(20, context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: height * 0.10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}