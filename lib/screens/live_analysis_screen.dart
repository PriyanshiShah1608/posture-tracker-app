import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/exercise.dart';
import '../router.dart';

// ─── Landmark / Joint model ──────────────────

enum JointStatus { correct, warning, incorrect }

class Landmark {
  final double x; // 0-1 normalized
  final double y;
  final JointStatus status;
  const Landmark(this.x, this.y, this.status);
}

/// Indices into the landmarks list
class _J {
  static const head = 0;
  static const neck = 1;
  static const lShoulder = 2;
  static const rShoulder = 3;
  static const lElbow = 4;
  static const rElbow = 5;
  static const lWrist = 6;
  static const rWrist = 7;
  static const lHip = 8;
  static const rHip = 9;
  static const lKnee = 10;
  static const rKnee = 11;
  static const lAnkle = 12;
  static const rAnkle = 13;
}

/// Bone connections as pairs of landmark indices
const _bones = <List<int>>[
  [_J.head, _J.neck],
  [_J.neck, _J.lShoulder],
  [_J.neck, _J.rShoulder],
  [_J.lShoulder, _J.lElbow],
  [_J.rShoulder, _J.rElbow],
  [_J.lElbow, _J.lWrist],
  [_J.rElbow, _J.rWrist],
  [_J.neck, _J.lHip],
  [_J.neck, _J.rHip],
  [_J.lHip, _J.rHip],
  [_J.lHip, _J.lKnee],
  [_J.rHip, _J.rKnee],
  [_J.lKnee, _J.lAnkle],
  [_J.rKnee, _J.rAnkle],
];

// ─── Mock data generator ─────────────────────

class _MockPoseEngine {
  int _tick = 0;

  // Simulate a squat cycle — landmarks shift subtly per tick
  List<Landmark> get landmarks {
    _tick++;
    final phase = math.sin(_tick * 0.08) * 0.5 + 0.5; // 0→1 oscillation
    final squat = phase * 0.08; // knee bend amount

    return [
      const Landmark(0.50, 0.12, JointStatus.correct),                         // head
      const Landmark(0.50, 0.22, JointStatus.correct),                         // neck
      const Landmark(0.38, 0.26, JointStatus.correct),                         // l shoulder
      const Landmark(0.62, 0.26, JointStatus.correct),                         // r shoulder
      const Landmark(0.32, 0.38, JointStatus.correct),                         // l elbow
      const Landmark(0.68, 0.38, JointStatus.correct),                         // r elbow
      const Landmark(0.30, 0.48, JointStatus.correct),                         // l wrist
      const Landmark(0.70, 0.48, JointStatus.correct),                         // r wrist
      Landmark(0.42, 0.52 + squat, JointStatus.correct),                 // l hip
      Landmark(0.58, 0.52 + squat, JointStatus.correct),                 // r hip
      Landmark(0.40, 0.70 + squat, _kneeStatus(phase)),                  // l knee
      Landmark(0.60, 0.70 + squat, _kneeStatus(phase)),                  // r knee
      const Landmark(0.40, 0.88, JointStatus.correct),                         // l ankle
      const Landmark(0.60, 0.88, JointStatus.correct),                         // r ankle
    ];
  }

  JointStatus _kneeStatus(double phase) {
    if (phase > 0.7) return JointStatus.warning;
    return JointStatus.correct;
  }

  int score(int baseTick) {
    // Oscillate score around 78-92
    return 78 + (math.sin(baseTick * 0.1) * 7).round().abs();
  }

  List<String> tips(int scoreval) {
    if (scoreval >= 88) {
      return [
        'Great depth — keep your chest lifted.',
        'Weight distribution looks even.',
      ];
    }
    if (scoreval >= 80) {
      return [
        'Push your knees out over your toes.',
        'Brace your core before each rep.',
        'Slow down the descent for control.',
      ];
    }
    return [
      'Avoid letting your knees cave inward.',
      'Hinge at the hips before bending knees.',
      'Keep your heels planted on the ground.',
    ];
  }
}

// ══════════════════════════════════════════════
//  Live Analysis Screen
// ══════════════════════════════════════════════

class LiveAnalysisScreen extends StatefulWidget {
  const LiveAnalysisScreen({super.key, this.exerciseId});
  final String? exerciseId;

  @override
  State<LiveAnalysisScreen> createState() => _LiveAnalysisScreenState();
}

class _LiveAnalysisScreenState extends State<LiveAnalysisScreen>
    with TickerProviderStateMixin {
  final _engine = _MockPoseEngine();
  Timer? _ticker;
  int _tick = 0;

  // Session state
  List<Landmark> _landmarks = [];
  int _score = 85;
  int _prevScore = 85;
  int _reps = 0;
  int _elapsedSeconds = 0;
  List<String> _tips = [];
  bool _showGoodForm = false;

  // Animations
  late final AnimationController _scoreAnimController;
  late final AnimationController _goodFormController;
  late final Animation<double> _goodFormOpacity;
  late final Animation<double> _goodFormScale;
  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;

  late final String _exerciseName;
  late final String _exerciseId;

  @override
  void initState() {
    _exerciseId = widget.exerciseId ?? exercises.first.id;
    _exerciseName = exerciseById(_exerciseId).name;
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Score ring animation
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Good form flash
    _goodFormController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _goodFormOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _goodFormController,
      curve: Curves.easeOut,
    ));
    _goodFormScale = Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(
      parent: _goodFormController,
      curve: Curves.easeOutBack,
    ));

    // Entrance
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    // Init first frame
    _landmarks = _engine.landmarks;
    _tips = _engine.tips(_score);

    _entranceController.forward();

    // Simulate real-time updates at ~15fps
    _ticker = Timer.periodic(const Duration(milliseconds: 66), _onTick);
  }

  void _onTick(Timer _) {
    if (!mounted) return;
    _tick++;

    final newLandmarks = _engine.landmarks;
    final newScore = _engine.score(_tick);
    final newTips = _engine.tips(newScore);

    // Count reps on phase crossings (roughly every 80 ticks)
    if (_tick > 0 && _tick % 80 == 0) {
      _reps++;
    }

    // Elapsed time
    if (_tick % 15 == 0) {
      _elapsedSeconds++;
    }

    // Detect "good form" moment
    final wasGood = _showGoodForm;
    final isGood = newScore >= 88;
    if (isGood && !wasGood) {
      _goodFormController.forward(from: 0);
    }

    // Animate score changes
    if (newScore != _score) {
      _prevScore = _score;
      _scoreAnimController.forward(from: 0);
    }

    setState(() {
      _landmarks = newLandmarks;
      _score = newScore;
      _tips = newTips;
      _showGoodForm = isGood;
    });
  }

  void _endSession() {
    _ticker?.cancel();
    context.go(AppRoutes.report, extra: _exerciseId);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _scoreAnimController.dispose();
    _goodFormController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entranceFade,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F14),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top bar ──
              _TopBar(
                exerciseName: _exerciseName,
                time: _formattedTime,
                onEnd: _endSession,
              ),

              // ── Main content: responsive layout ──
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;

                    if (isWide) {
                      // Side by side
                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _CameraFeed(landmarks: _landmarks),
                          ),
                          Expanded(
                            flex: 2,
                            child: _FeedbackPanel(
                              exerciseName: _exerciseName,
                              reps: _reps,
                              score: _score,
                              prevScore: _prevScore,
                              scoreAnim: _scoreAnimController,
                              tips: _tips,
                              goodFormController: _goodFormController,
                              goodFormOpacity: _goodFormOpacity,
                              goodFormScale: _goodFormScale,
                            ),
                          ),
                        ],
                      );
                    }

                    // Stacked — camera on top, panel below
                    return Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _CameraFeed(landmarks: _landmarks),
                        ),
                        Expanded(
                          flex: 4,
                          child: _FeedbackPanel(
                            exerciseName: _exerciseName,
                            reps: _reps,
                            score: _score,
                            prevScore: _prevScore,
                            scoreAnim: _scoreAnimController,
                            tips: _tips,
                            goodFormController: _goodFormController,
                            goodFormOpacity: _goodFormOpacity,
                            goodFormScale: _goodFormScale,
                          ),
                        ),
                      ],
                    );
                  },
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
//  Top Bar
// ══════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.exerciseName,
    required this.time,
    required this.onEnd,
  });

  final String exerciseName;
  final String time;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Exercise name + live dot
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                exerciseName,
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // End session button
          GestureDetector(
            onTap: onEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stop_rounded, size: 16, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text(
                    'End',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Camera Feed + Skeleton Overlay
// ══════════════════════════════════════════════

class _CameraFeed extends StatelessWidget {
  const _CameraFeed({required this.landmarks});
  final List<Landmark> landmarks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A24),
                Color(0xFF12121A),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Placeholder text
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam_rounded,
                      size: 40,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Camera feed',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),

              // Skeleton overlay
              CustomPaint(
                painter: _SkeletonPainter(landmarks: landmarks),
              ),

              // Viewfinder corners
              CustomPaint(
                painter: _ViewfinderPainter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton painter with color-coded joints ──

class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter({required this.landmarks});
  final List<Landmark> landmarks;

  static const _correctColor = AppColors.primary;
  static const _warningColor = Color(0xFFFFB020);
  static const _incorrectColor = AppColors.error;

  Color _statusColor(JointStatus s) {
    switch (s) {
      case JointStatus.correct:
        return _correctColor;
      case JointStatus.warning:
        return _warningColor;
      case JointStatus.incorrect:
        return _incorrectColor;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.length < 14) return;

    // Map normalized coords to canvas
    Offset pt(int i) =>
        Offset(landmarks[i].x * size.width, landmarks[i].y * size.height);

    // Draw bones
    for (final bone in _bones) {
      final a = bone[0];
      final b = bone[1];

      // Bone color = worst status of its two joints
      final statusA = landmarks[a].status;
      final statusB = landmarks[b].status;
      final worstStatus = statusA.index >= statusB.index ? statusA : statusB;

      final bonePaint = Paint()
        ..color = _statusColor(worstStatus).withValues(alpha: 0.6)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(pt(a), pt(b), bonePaint);
    }

    // Draw joints
    for (int i = 0; i < landmarks.length; i++) {
      final p = pt(i);
      final color = _statusColor(landmarks[i].status);
      final isHead = i == _J.head;
      final radius = isHead ? 12.0 : 6.0;

      // Glow
      canvas.drawCircle(
        p,
        radius + 4,
        Paint()
          ..color = color.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Outer ring
      canvas.drawCircle(
        p,
        radius,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Inner dot
      canvas.drawCircle(
        p,
        radius * 0.5,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_SkeletonPainter old) => true; // real-time updates
}

// ─── Viewfinder corner brackets ──

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const m = 16.0;
    const c = 24.0;

    // Top-left
    canvas.drawLine(const Offset(m, m), const Offset(m + c, m), paint);
    canvas.drawLine(const Offset(m, m), const Offset(m, m + c), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - m, m), Offset(size.width - m - c, m), paint);
    canvas.drawLine(Offset(size.width - m, m), Offset(size.width - m, m + c), paint);
    // Bottom-left
    canvas.drawLine(Offset(m, size.height - m), Offset(m + c, size.height - m), paint);
    canvas.drawLine(Offset(m, size.height - m), Offset(m, size.height - m - c), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - m, size.height - m), Offset(size.width - m - c, size.height - m), paint);
    canvas.drawLine(Offset(size.width - m, size.height - m), Offset(size.width - m, size.height - m - c), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════
//  Feedback Panel
// ══════════════════════════════════════════════

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.exerciseName,
    required this.reps,
    required this.score,
    required this.prevScore,
    required this.scoreAnim,
    required this.tips,
    required this.goodFormController,
    required this.goodFormOpacity,
    required this.goodFormScale,
  });

  final String exerciseName;
  final int reps;
  final int score;
  final int prevScore;
  final AnimationController scoreAnim;
  final List<String> tips;
  final AnimationController goodFormController;
  final Animation<double> goodFormOpacity;
  final Animation<double> goodFormScale;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.sm + 2, 0, AppSpacing.sm + 2, AppSpacing.sm + 2,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg,
        AppSpacing.lg, AppSpacing.md + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Exercise + reps row ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exerciseName, style: AppTextStyles.headingMedium),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$reps',
                            style: AppTextStyles.headingLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const TextSpan(
                            text: ' reps',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Circular score
              _AnimatedScoreRing(
                score: score,
                prevScore: prevScore,
                animation: scoreAnim,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md + 4),

          // ── Good form flash ──
          AnimatedBuilder(
            animation: goodFormController,
            builder: (context, _) {
              if (goodFormOpacity.value <= 0) {
                return const SizedBox(height: 0);
              }
              return Opacity(
                opacity: goodFormOpacity.value,
                child: Transform.scale(
                  scale: goodFormScale.value,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Good form — keep it up!',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Correction tips ──
          Text(
            'Live feedback',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),

          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: tips.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm + 2),
              itemBuilder: (_, i) => _TipRow(text: tips[i], index: i),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated score ring ──

class _AnimatedScoreRing extends StatelessWidget {
  const _AnimatedScoreRing({
    required this.score,
    required this.prevScore,
    required this.animation,
  });

  final int score;
  final int prevScore;
  final AnimationController animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(animation.value);
        final displayScore =
            (prevScore + (score - prevScore) * t).round();
        final progress = displayScore / 100;

        return SizedBox(
          width: 72,
          height: 72,
          child: CustomPaint(
            painter: _MiniRingPainter(progress: progress, score: displayScore),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$displayScore',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 22,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'score',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  _MiniRingPainter({required this.progress, required this.score});
  final double progress;
  final int score;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const strokeWidth = 6.0;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0, 1);

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.borderLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Color based on score
    Color ringColor;
    if (score >= 85) {
      ringColor = AppColors.success;
    } else if (score >= 70) {
      ringColor = AppColors.primary;
    } else {
      ringColor = AppColors.warning;
    }

    // Fill
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) =>
      old.progress != progress || old.score != score;
}

// ─── Tip row ──

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text, required this.index});
  final String text;
  final int index;

  static const _icons = [
    Icons.adjust_rounded,
    Icons.straighten_rounded,
    Icons.speed_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Icon(
            _icons[index % _icons.length],
            size: 14,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
