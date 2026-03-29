import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/exercise.dart';
import '../router.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, this.exerciseId});
  final String? exerciseId;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with TickerProviderStateMixin {
  // ── Mock session data ──
  static const _score = 84;
  static const _reps = 12;
  static const _durationMinutes = 8;
  static const _avgScore = 81;
  late final String _exerciseName;
  late final String _exerciseId;

  @override
  void initState() {
    super.initState();
    _exerciseId = widget.exerciseId ?? exercises.first.id;
    _exerciseName = exerciseById(_exerciseId).name;
    _initAnimations();
    _startAnimations();
  }

  static const _regionScores = <_RegionScore>[
    _RegionScore(label: 'Spine', score: 90, color: AppColors.success),
    _RegionScore(label: 'Shoulders', score: 78, color: AppColors.primary),
    _RegionScore(label: 'Knees', score: 72, color: AppColors.warning),
  ];

  static const _tips = <_CoachingTip>[
    _CoachingTip(
      icon: Icons.straighten_rounded,
      text: 'Keep your spine neutral at the bottom of the squat — '
          'avoid rounding your lower back.',
    ),
    _CoachingTip(
      icon: Icons.visibility_rounded,
      text: 'Focus your gaze slightly upward to help maintain '
          'chest-up position throughout the rep.',
    ),
    _CoachingTip(
      icon: Icons.timer_rounded,
      text: 'Slow down the descent to 2-3 seconds — controlled '
          'tempo builds strength and protects joints.',
    ),
  ];

  // ── Animation controllers ──

  late final AnimationController _ringController;
  late final Animation<double> _ringProgress;

  late final AnimationController _contentController;
  late final List<Animation<double>> _contentFades;
  late final List<Animation<Offset>> _contentSlides;

  // 5 content slots: metrics row, tips section, breakdown section, buttons, (spare)
  static const _contentSlots = 4;

  void _initAnimations() {
    // Ring fill: 1.2s ease-out
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringProgress = Tween<double>(begin: 0, end: _score / 100)
        .animate(CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeOutCubic,
    ));

    // Staggered content after ring completes
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentFades = List.generate(_contentSlots, (i) {
      final start = i * 0.15;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _contentController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    _contentSlides = List.generate(_contentSlots, (i) {
      final start = i * 0.15;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _contentController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await _ringController.forward();
    if (!mounted) return;
    _contentController.forward();
  }

  @override
  void dispose() {
    _ringController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String get _scoreLabel {
    if (_score >= 90) return 'Excellent';
    if (_score >= 75) return 'Great work';
    if (_score >= 60) return 'Good effort';
    return 'Keep going';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.lg, 0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Session Report', style: AppTextStyles.headingSmall),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ──
            Expanded(
              child: AnimatedBuilder(
                animation:
                    Listenable.merge([_ringController, _contentController]),
                builder: (context, _) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xl + bottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Score ring ──
                        _ScoreRing(
                          progress: _ringProgress.value,
                          score: (_ringProgress.value * 100).round(),
                          label: _scoreLabel,
                          exerciseName: _exerciseName,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // ── Metric cards ──
                        _Stagger(
                          fade: _contentFades[0],
                          slide: _contentSlides[0],
                          child: const _MetricRow(
                            reps: _reps,
                            minutes: _durationMinutes,
                            avgScore: _avgScore,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // ── Coaching tips ──
                        _Stagger(
                          fade: _contentFades[1],
                          slide: _contentSlides[1],
                          child: const _CoachingSection(tips: _tips),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // ── Form breakdown ──
                        _Stagger(
                          fade: _contentFades[2],
                          slide: _contentSlides[2],
                          child: _BreakdownSection(
                            regions: _regionScores,
                            animated: _contentController.isCompleted ||
                                _contentController.isAnimating,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // ── Action buttons ──
                        _Stagger(
                          fade: _contentFades[3],
                          slide: _contentSlides[3],
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => context.go(
                                    AppRoutes.liveSession,
                                    extra: _exerciseId,
                                  ),
                                  icon: const Icon(
                                      Icons.replay_rounded, size: 20),
                                  label: const Text('Try again'),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm + 4),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      context.go(AppRoutes.home),
                                  icon: const Icon(
                                      Icons.grid_view_rounded, size: 20),
                                  label: const Text('New exercise'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Stagger animation wrapper
// ══════════════════════════════════════════════

class _Stagger extends StatelessWidget {
  const _Stagger({
    required this.fade,
    required this.slide,
    required this.child,
  });

  final Animation<double> fade;
  final Animation<Offset> slide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: fade.value,
      child: Transform.translate(offset: slide.value, child: child),
    );
  }
}

// ══════════════════════════════════════════════
//  Score Ring (Apple Activity ring style)
// ══════════════════════════════════════════════

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.progress,
    required this.score,
    required this.label,
    required this.exerciseName,
  });

  final double progress;
  final int score;
  final String label;
  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: _RingPainter(progress: progress),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: AppTextStyles.displayLarge.copyWith(
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'out of 100',
                      style: AppTextStyles.caption.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTextStyles.headingMedium),
          const SizedBox(height: 4),
          Text(
            exerciseName,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;
    const strokeWidth = 14.0;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.borderLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;

    // Gradient ring
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        AppColors.primaryLight,
        AppColors.primary,
        AppColors.primaryDark,
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    final ringPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, ringPaint);

    // End cap glow
    if (progress > 0.05) {
      final endAngle = startAngle + sweepAngle;
      final capX = center.dx + radius * math.cos(endAngle);
      final capY = center.dy + radius * math.sin(endAngle);

      canvas.drawCircle(
        Offset(capX, capY),
        strokeWidth * 0.9,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ══════════════════════════════════════════════
//  Metric Row
// ══════════════════════════════════════════════

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.reps,
    required this.minutes,
    required this.avgScore,
  });

  final int reps;
  final int minutes;
  final int avgScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.repeat_rounded,
            value: '$reps',
            label: 'Reps',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: _MetricCard(
            icon: Icons.timer_outlined,
            value: '${minutes}m',
            label: 'Duration',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: _MetricCard(
            icon: Icons.star_outline_rounded,
            value: '$avgScore',
            label: 'Avg score',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Coaching Tips
// ══════════════════════════════════════════════

class _CoachingTip {
  final IconData icon;
  final String text;
  const _CoachingTip({required this.icon, required this.text});
}

class _CoachingSection extends StatelessWidget {
  const _CoachingSection({required this.tips});
  final List<_CoachingTip> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Text('What to improve', style: AppTextStyles.headingSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md + 4),
          for (int i = 0; i < tips.length; i++) ...[
            _TipItem(tip: tips[i]),
            if (i < tips.length - 1)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                child: Divider(
                  height: 1,
                  color: AppColors.borderLight,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({required this.tip});
  final _CoachingTip tip;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(tip.icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(
          child: Text(
            tip.text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
//  Form Breakdown (horizontal bars)
// ══════════════════════════════════════════════

class _RegionScore {
  final String label;
  final int score;
  final Color color;
  const _RegionScore({
    required this.label,
    required this.score,
    required this.color,
  });
}

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({
    required this.regions,
    required this.animated,
  });

  final List<_RegionScore> regions;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Text('Your form breakdown', style: AppTextStyles.headingSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < regions.length; i++) ...[
            _BarRow(region: regions[i], animate: animated),
            if (i < regions.length - 1)
              const SizedBox(height: AppSpacing.md + 4),
          ],
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.region, required this.animate});
  final _RegionScore region;
  final bool animate;

  String get _label {
    if (region.score >= 85) return 'Great';
    if (region.score >= 70) return 'Good';
    return 'Needs work';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(region.label, style: AppTextStyles.labelLarge),
            Row(
              children: [
                Text(
                  '${region.score}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: region.color,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: region.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    _label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: region.color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                // Track
                Container(
                  decoration: BoxDecoration(
                    color: region.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                // Fill
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  widthFactor: animate ? region.score / 100 : 0,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          region.color.withValues(alpha: 0.7),
                          region.color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve,
    this.widthFactor,
    this.heightFactor,
    this.alignment = Alignment.center,
    required this.child,
  });

  final double? widthFactor;
  final double? heightFactor;
  final AlignmentGeometry alignment;
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;
  Tween<double>? _heightFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor ?? 0,
      (v) => Tween<double>(begin: v as double),
    ) as Tween<double>?;
    _heightFactor = visitor(
      _heightFactor,
      widget.heightFactor ?? 0,
      (v) => Tween<double>(begin: v as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation),
      heightFactor: _heightFactor?.evaluate(animation),
      alignment: widget.alignment,
      child: widget.child,
    );
  }
}
