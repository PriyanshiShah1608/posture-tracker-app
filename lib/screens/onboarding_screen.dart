import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _onboardingSteps = [
    {
      'title': 'Why Posture Matters',
      'subtitle': 'You don\'t notice your posture... until it starts hurting.',
      'type': 'effects',
    },
    {
      'title': 'Real-Time Monitoring',
      'subtitle':
          'Posturely keeps an eye on you while you work, study, or scroll. The app gives instant feedback the moment you start slouching, so you can correct your posture before discomfort builds up.',
      'icon': Icons.monitor_rounded,
      'type': 'feature',
    },
    {
      'title': 'Valuable Insights',
      'subtitle':
          'The app compiles your posture history into clear daily, weekly, and monthly insights. You\'ll see trends, progress scores, and actionable tips, helping you stay consistent and motivated.',
      'icon': Icons.trending_up_rounded,
      'type': 'feature',
    },
    {
      'title': 'Digital Device Usage',
      'subtitle':
          '"Text neck" has become a clinical term. A biomechanics case study revealed that tilting the head forward 60° while looking at a phone increases cervical spine stress from 10–12 lbs to 60 lbs—equivalent to carrying a child on your neck.',
      'type': 'case_study',
    },
  ];

  void _nextStep() {
    if (_currentStep < _onboardingSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            if (_currentStep < _onboardingSteps.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ),

            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(40, 40),
                        painter: MedicalCrossLogoPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Posturely',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        'AI-Powered Posture Care',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _onboardingSteps[_currentStep]['type'] == 'case_study'
                      ? 'Success Stories'
                      : 'Welcome to Better Health',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentStep = index),
                itemCount: _onboardingSteps.length,
                itemBuilder: (context, index) {
                  final step = _onboardingSteps[index];
                  return _buildOnboardingPage(step);
                },
              ),
            ),

            // Pagination Dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingSteps.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentStep ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentStep
                          ? const Color(0xFF4F46E5)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Next/Continue Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _currentStep == _onboardingSteps.length - 1
                        ? 'Get Started'
                        : _onboardingSteps[_currentStep]['type'] == 'case_study'
                            ? 'Next (${_currentStep + 1}/${_onboardingSteps.length})'
                            : 'Continue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> step) {
    final type = step['type'];

    if (type == 'effects') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFEF2F2),
                  Color(0xFFFFF7ED),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFCA5A5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Effects of Poor Posture',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 24),
                _buildEffectItem(
                  Icons.bolt_rounded,
                  'Neck and Back Pain',
                  const Color(0xFFDC2626),
                ),
                const SizedBox(height: 12),
                _buildEffectItem(
                  Icons.air_rounded,
                  'Shallow Breathing',
                  const Color(0xFFEA580C),
                ),
                const SizedBox(height: 12),
                _buildEffectItem(
                  Icons.battery_2_bar_rounded,
                  'Low Energy',
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 12),
                _buildEffectItem(
                  Icons.sentiment_dissatisfied_rounded,
                  'Reduced Confidence',
                  const Color(0xFFDC2626),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (type == 'case_study') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF5EEAD4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF14B8A6),
                        Color(0xFF06B6D4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF14B8A6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Clinical Evidence',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  step['subtitle'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Feature type
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFDEF3FF),
                      Color(0xFFD0F0FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF5EEAD4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  step['icon'],
                  size: 48,
                  color: const Color(0xFF14B8A6),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                step['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                step['subtitle'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEffectItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class MedicalCrossLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, size.height * 0.2, size.width * 0.3, size.height * 0.6),
        const Radius.circular(4),
      ),
      paint,
    );

    // Horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.35, size.width * 0.6, size.height * 0.3),
        const Radius.circular(4),
      ),
      paint,
    );

    // Center circle
    paint.color = Colors.white.withOpacity(0.4);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.08,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
