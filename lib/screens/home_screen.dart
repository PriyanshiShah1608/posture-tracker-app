import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/exercise.dart';
import '../router.dart';
import '../widgets/bottom_nav.dart';

// ─── Motivational lines (Headspace tone) ─────

const _motivationalLines = <String>[
  'Small corrections today, lasting comfort tomorrow.',
  'Your body remembers the care you give it.',
  'A few mindful minutes go a long way.',
  'Progress isn\'t always visible — but your body feels it.',
  'Showing up is the hardest part. You\'re already here.',
];

// ══════════════════════════════════════════════
//  Home Screen
// ══════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedExerciseId;

  late final AnimationController _staggerController;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  // 5 stagger slots: greeting, hero card, section title, exercise row, stats
  static const _slotCount = 5;

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnims = List.generate(_slotCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_slotCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 24),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _startSession() {
    context.push(AppRoutes.liveSession, extra: _selectedExerciseId);
  }

  String get _motivationalLine {
    final dayIndex = DateTime.now().day % _motivationalLines.length;
    return _motivationalLines[dayIndex];
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _staggerController,
          builder: (context, _) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Top padding ──
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),

                // ── Greeting ──
                SliverToBoxAdapter(
                  child: _StaggerSlot(
                    fade: _fadeAnims[0],
                    slide: _slideAnims[0],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting,
                            style: AppTextStyles.headingLarge.copyWith(
                              fontSize: 30,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _motivationalLine,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),

                // ── Hero card: Start a Session ──
                SliverToBoxAdapter(
                  child: _StaggerSlot(
                    fade: _fadeAnims[1],
                    slide: _slideAnims[1],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _HeroCard(
                        selectedExercise: _selectedExerciseId,
                        onTap: _startSession,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),

                // ── Section title: Exercises ──
                SliverToBoxAdapter(
                  child: _StaggerSlot(
                    fade: _fadeAnims[2],
                    slide: _slideAnims[2],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        'Choose an exercise',
                        style: AppTextStyles.headingSmall,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.md),
                ),

                // ── Exercise cards row ──
                SliverToBoxAdapter(
                  child: _StaggerSlot(
                    fade: _fadeAnims[3],
                    slide: _slideAnims[3],
                    child: SizedBox(
                      height: 176,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        itemCount: exercises.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.sm + 4),
                        itemBuilder: (context, i) {
                          final ex = exercises[i];
                          return ExerciseCard(
                            exercise: ex,
                            isSelected: _selectedExerciseId == ex.id,
                            onTap: () {
                              setState(() {
                                _selectedExerciseId =
                                    _selectedExerciseId == ex.id
                                        ? null
                                        : ex.id;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),

                // ── Stats strip ──
                SliverToBoxAdapter(
                  child: _StaggerSlot(
                    fade: _fadeAnims[4],
                    slide: _slideAnims[4],
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _QuickStats(),
                    ),
                  ),
                ),

                // Bottom spacing for nav bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNav(
        currentIndex: 0,
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Stagger animation wrapper
// ══════════════════════════════════════════════

class _StaggerSlot extends StatelessWidget {
  const _StaggerSlot({
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
      child: Transform.translate(
        offset: slide.value,
        child: child,
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Hero Card – Start a Session
// ══════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.selectedExercise,
    required this.onTap,
  });

  final String? selectedExercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exerciseName = selectedExercise != null
        ? exercises.firstWhere((e) => e.id == selectedExercise).name
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7B4FD3), // slightly lighter top-left
              AppColors.primary,
              AppColors.primaryDark,
            ],
            stops: [0.0, 0.4, 1.0],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (exerciseName != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        exerciseName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  Text(
                    'Start a session',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    exerciseName != null
                        ? 'Tap to begin your $exerciseName session'
                        : 'Select an exercise below, or jump right in',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Begin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Right illustration
            SizedBox(
              width: 80,
              height: 100,
              child: CustomPaint(
                painter: _HeroIllustrationPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Abstract body silhouette in a strong, upright pose
class _HeroIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;

    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(Offset(cx, 14), 10, strokePaint);
    canvas.drawCircle(Offset(cx, 14), 10, dotPaint..color = Colors.white.withValues(alpha: 0.15));

    // Torso
    canvas.drawLine(Offset(cx, 24), Offset(cx, 60), strokePaint);

    // Arms – slightly angled outward (confident stance)
    canvas.drawLine(Offset(cx, 32), Offset(cx - 22, 50), strokePaint);
    canvas.drawLine(Offset(cx, 32), Offset(cx + 22, 50), strokePaint);

    // Legs
    canvas.drawLine(Offset(cx, 60), Offset(cx - 14, 92), strokePaint);
    canvas.drawLine(Offset(cx, 60), Offset(cx + 14, 92), strokePaint);

    // Joint dots
    dotPaint.color = Colors.white.withValues(alpha: 0.8);
    final joints = [
      Offset(cx, 24),       // neck
      Offset(cx, 32),       // shoulders
      Offset(cx - 22, 50),  // left hand
      Offset(cx + 22, 50),  // right hand
      Offset(cx, 60),       // hips
      Offset(cx - 14, 92),  // left foot
      Offset(cx + 14, 92),  // right foot
    ];
    for (final j in joints) {
      canvas.drawCircle(j, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════
//  Exercise Card
// ══════════════════════════════════════════════

class ExerciseCard extends StatefulWidget {
  const ExerciseCard({
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<ExerciseCard> createState() => ExerciseCardState();
}

class ExerciseCardState extends State<ExerciseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.04)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.04, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_pulseController);
  }

  @override
  void didUpdateWidget(ExerciseCard old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final selected = widget.isSelected;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: selected ? _scaleAnim.value : 1.0,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: 148,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderLight,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected ? AppShadows.md : AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : ex.accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  ex.icon,
                  color: selected ? AppColors.primary : ex.accentColor,
                  size: 20,
                ),
              ),

              const SizedBox(height: AppSpacing.sm + 2),

              // Name
              Text(
                ex.name,
                style: AppTextStyles.labelLarge.copyWith(
                  color: selected
                      ? AppColors.primaryDark
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 3),

              // Description
              Text(
                ex.description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Difficulty pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  ex.difficulty,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    letterSpacing: 0.1,
                  ),
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
//  Quick Stats Strip
// ══════════════════════════════════════════════

class _QuickStats extends StatelessWidget {
  const _QuickStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md + 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.play_circle_outline_rounded,
              value: '3',
              label: 'This week',
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.borderLight,
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.star_outline_rounded,
              value: '87',
              label: 'Avg score',
              color: AppColors.warning,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.borderLight,
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.local_fire_department_outlined,
              value: '5d',
              label: 'Streak',
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
