import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return FadeTransition(
      opacity: _fadeIn,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top bar: skip button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.sm, AppSpacing.md, 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentPage < 2)
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'Skip',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 48), // maintain spacing
                  ],
                ),
              ),

              // ── Page content ──
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    _PageOne(),
                    _PageTwo(),
                    _PageThree(),
                  ],
                ),
              ),

              // ── Bottom: dots + CTA ──
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md,
                  AppSpacing.lg, AppSpacing.lg + bottomPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicator dots
                    _PageDots(current: _currentPage, total: 3),

                    const SizedBox(height: AppSpacing.lg),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        child: Text(
                          _currentPage == 2 ? 'Get Started' : 'Continue',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Page Indicator Dots
// ══════════════════════════════════════════════

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════
//  Page 1 – What the app does
// ══════════════════════════════════════════════

class _PageOne extends StatelessWidget {
  const _PageOne();

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageLayout(
      illustration: const _PostureIllustration(),
      title: 'Your posture,\ngently corrected',
      body:
          'Posturely watches your form in real time and nudges you back into alignment — so you feel better, stand taller, and move with confidence.',
    );
  }
}

// ══════════════════════════════════════════════
//  Page 2 – How it works
// ══════════════════════════════════════════════

class _PageTwo extends StatelessWidget {
  const _PageTwo();

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageLayout(
      illustration: const _HowItWorksIllustration(),
      title: 'Pick an exercise.\nWe handle the rest.',
      body:
          'Choose from guided routines, point your camera, and get instant AI feedback on your form. No wearables, no guessing.',
    );
  }
}

// ══════════════════════════════════════════════
//  Page 3 – Camera permission
// ══════════════════════════════════════════════

class _PageThree extends StatelessWidget {
  const _PageThree();

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageLayout(
      illustration: const _CameraIllustration(),
      title: 'Allow camera\nfor live coaching',
      body:
          'Posturely uses your camera to analyze posture on-device. Nothing is recorded or uploaded — your data stays private, always.',
    );
  }
}

// ══════════════════════════════════════════════
//  Shared page layout
// ══════════════════════════════════════════════

class _OnboardingPageLayout extends StatelessWidget {
  const _OnboardingPageLayout({
    required this.illustration,
    required this.title,
    required this.body,
  });

  final Widget illustration;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Illustration area
          SizedBox(
            height: 260,
            child: illustration,
          ),

          const Spacer(flex: 1),

          // Text content
          Text(
            title,
            style: AppTextStyles.headingLarge.copyWith(
              fontSize: 28,
              height: 1.2,
              letterSpacing: -0.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            body,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Illustration 1 – Abstract posture silhouette
//  Upright spine with alignment guides
// ══════════════════════════════════════════════

class _PostureIllustration extends StatelessWidget {
  const _PostureIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          shape: BoxShape.circle,
        ),
        child: CustomPaint(
          painter: _PostureSilhouettePainter(),
        ),
      ),
    );
  }
}

class _PostureSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // Alignment guide lines (dashed vertical)
    final guidePaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas,
      Offset(cx, cy - 80),
      Offset(cx, cy + 80),
      guidePaint,
    );

    // Body silhouette
    final bodyPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    // Torso – rounded rectangle
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + 12),
        width: 48,
        height: 80,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(torsoRect, bodyPaint);

    // Head
    final headPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - 52), 18, headPaint);

    // Spine dots – good posture (aligned)
    final spinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final spinePositions = [
      Offset(cx, cy - 24),
      Offset(cx, cy - 8),
      Offset(cx, cy + 8),
      Offset(cx, cy + 24),
      Offset(cx, cy + 40),
    ];

    for (final pos in spinePositions) {
      canvas.drawCircle(pos, 3.0, spinePaint);
    }

    // Checkmark accent – top right
    final checkPaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final checkCenter = Offset(cx + 52, cy - 50);
    // Draw circle bg
    canvas.drawCircle(
      checkCenter,
      14,
      Paint()..color = AppColors.successLight,
    );
    // Draw check
    final checkPath = Path()
      ..moveTo(checkCenter.dx - 5, checkCenter.dy)
      ..lineTo(checkCenter.dx - 1, checkCenter.dy + 4)
      ..lineTo(checkCenter.dx + 6, checkCenter.dy - 4);
    canvas.drawPath(checkPath, checkPaint);

    // Horizontal alignment markers
    final markerPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Shoulders
    canvas.drawLine(
      Offset(cx - 36, cy - 24),
      Offset(cx + 36, cy - 24),
      markerPaint,
    );
    // Hips
    canvas.drawLine(
      Offset(cx - 28, cy + 44),
      Offset(cx + 28, cy + 44),
      markerPaint,
    );
  }

  void _drawDashedLine(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 6.0;
    const gapLen = 4.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final ux = dx / dist;
    final uy = dy / dist;

    var d = 0.0;
    while (d < dist) {
      final s = Offset(start.dx + ux * d, start.dy + uy * d);
      final e = Offset(
        start.dx + ux * math.min(d + dashLen, dist),
        start.dy + uy * math.min(d + dashLen, dist),
      );
      canvas.drawLine(s, e, paint);
      d += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════
//  Illustration 2 – How it works
//  Phone frame with camera viewfinder + body outline
// ══════════════════════════════════════════════

class _HowItWorksIllustration extends StatelessWidget {
  const _HowItWorksIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Positioned(
              top: 20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Phone frame
            Positioned(
              top: 10,
              child: Container(
                width: 120,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.border,
                    width: 2,
                  ),
                  boxShadow: AppShadows.md,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg - 2),
                  child: CustomPaint(
                    painter: _PhoneContentPainter(),
                  ),
                ),
              ),
            ),

            // Step badges around the phone
            Positioned(
              left: 0,
              top: 40,
              child: _StepBadge(number: 1, label: 'Select'),
            ),
            Positioned(
              right: 0,
              top: 100,
              child: _StepBadge(number: 2, label: 'Record'),
            ),
            Positioned(
              left: 8,
              bottom: 20,
              child: _StepBadge(number: 3, label: 'Improve'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.number, required this.label});
  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneContentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF8F5FF),
    );

    final cx = size.width / 2;

    // Simplified body outline inside "camera view"
    final bodyPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Head
    canvas.drawCircle(Offset(cx, 50), 12, bodyPaint);

    // Torso line
    canvas.drawLine(Offset(cx, 62), Offset(cx, 120), bodyPaint);

    // Arms
    canvas.drawLine(Offset(cx, 75), Offset(cx - 24, 95), bodyPaint);
    canvas.drawLine(Offset(cx, 75), Offset(cx + 24, 95), bodyPaint);

    // Legs
    canvas.drawLine(Offset(cx, 120), Offset(cx - 16, 160), bodyPaint);
    canvas.drawLine(Offset(cx, 120), Offset(cx + 16, 160), bodyPaint);

    // Joint dots (pose estimation style)
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final joints = [
      Offset(cx, 50),    // head
      Offset(cx, 75),    // shoulders
      Offset(cx - 24, 95), // left hand
      Offset(cx + 24, 95), // right hand
      Offset(cx, 120),   // hips
      Offset(cx - 16, 160), // left foot
      Offset(cx + 16, 160), // right foot
    ];

    for (final j in joints) {
      canvas.drawCircle(j, 3.5, dotPaint);
    }

    // Viewfinder corners
    final cornerPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const m = 14.0; // margin
    const c = 16.0; // corner length

    // Top-left
    canvas.drawLine(Offset(m, m), Offset(m + c, m), cornerPaint);
    canvas.drawLine(Offset(m, m), Offset(m, m + c), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(size.width - m, m), Offset(size.width - m - c, m), cornerPaint);
    canvas.drawLine(Offset(size.width - m, m), Offset(size.width - m, m + c), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(m, size.height - m), Offset(m + c, size.height - m), cornerPaint);
    canvas.drawLine(Offset(m, size.height - m), Offset(m, size.height - m - c), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - m, size.height - m), Offset(size.width - m - c, size.height - m), cornerPaint);
    canvas.drawLine(Offset(size.width - m, size.height - m), Offset(size.width - m, size.height - m - c), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════
//  Illustration 3 – Camera permission
//  Friendly camera icon with shield / lock accent
// ══════════════════════════════════════════════

class _CameraIllustration extends StatelessWidget {
  const _CameraIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),

            // Inner filled circle
            Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
            ),

            // Camera icon (custom painted)
            CustomPaint(
              size: const Size(80, 80),
              painter: _CameraIconPainter(),
            ),

            // Shield badge – bottom right
            Positioned(
              right: 26,
              bottom: 26,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.sm,
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield_rounded,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Camera body
    final bodyPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 56, height: 40),
      const Radius.circular(10),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Camera top bump (flash area)
    final topPath = Path()
      ..moveTo(cx - 12, cy - 16)
      ..lineTo(cx - 8, cy - 24)
      ..lineTo(cx + 8, cy - 24)
      ..lineTo(cx + 12, cy - 16)
      ..close();
    canvas.drawPath(topPath, bodyPaint);

    // Lens – outer ring
    canvas.drawCircle(
      Offset(cx, cy + 4),
      14,
      Paint()
        ..color = AppColors.primaryDark
        ..style = PaintingStyle.fill,
    );

    // Lens – inner
    canvas.drawCircle(
      Offset(cx, cy + 4),
      9,
      Paint()
        ..color = AppColors.primaryLight
        ..style = PaintingStyle.fill,
    );

    // Lens – highlight
    canvas.drawCircle(
      Offset(cx - 3, cy + 1),
      3,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );

    // Small indicator light
    canvas.drawCircle(
      Offset(cx + 20, cy - 8),
      3,
      Paint()..color = AppColors.success,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
