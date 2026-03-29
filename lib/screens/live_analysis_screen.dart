import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/exercise.dart';
import '../models/landmark.dart';
import '../services/camera_service.dart';
import '../services/feedback_service.dart' hide Exercise;
import '../services/posture_engine_service.dart' as engine;
import '../theme/app_theme.dart';
import '../router.dart';

// ─── Skeleton topology ──────────────────────

const _skeletonBones = <(LandmarkType, LandmarkType)>[
  (LandmarkType.nose, LandmarkType.leftShoulder),
  (LandmarkType.nose, LandmarkType.rightShoulder),
  (LandmarkType.leftShoulder, LandmarkType.rightShoulder),
  (LandmarkType.leftShoulder, LandmarkType.leftElbow),
  (LandmarkType.rightShoulder, LandmarkType.rightElbow),
  (LandmarkType.leftElbow, LandmarkType.leftWrist),
  (LandmarkType.rightElbow, LandmarkType.rightWrist),
  (LandmarkType.leftShoulder, LandmarkType.leftHip),
  (LandmarkType.rightShoulder, LandmarkType.rightHip),
  (LandmarkType.leftHip, LandmarkType.rightHip),
  (LandmarkType.leftHip, LandmarkType.leftKnee),
  (LandmarkType.rightHip, LandmarkType.rightKnee),
  (LandmarkType.leftKnee, LandmarkType.leftAnkle),
  (LandmarkType.rightKnee, LandmarkType.rightAnkle),
];

/// Maps rule class names → the landmark types that rule evaluates, so the
/// skeleton painter can color individual joints by the worst rule outcome.
const _ruleToLandmarks = <String, List<LandmarkType>>{
  'SquatKneeAngleRule': [
    LandmarkType.leftHip, LandmarkType.leftKnee, LandmarkType.leftAnkle,
    LandmarkType.rightHip, LandmarkType.rightKnee, LandmarkType.rightAnkle,
  ],
  'SquatBackStraightRule': [
    LandmarkType.leftShoulder, LandmarkType.rightShoulder,
    LandmarkType.leftHip, LandmarkType.rightHip,
  ],
  'LungeKneeAngleRule': [
    LandmarkType.leftHip, LandmarkType.leftKnee, LandmarkType.leftAnkle,
    LandmarkType.rightHip, LandmarkType.rightKnee, LandmarkType.rightAnkle,
  ],
  'LungeTorsoUprightRule': [
    LandmarkType.leftShoulder, LandmarkType.rightShoulder,
    LandmarkType.leftHip, LandmarkType.rightHip,
  ],
  'ShoulderSymmetryRule': [
    LandmarkType.leftShoulder, LandmarkType.rightShoulder,
  ],
  'ShoulderEarDistanceRule': [
    LandmarkType.leftShoulder, LandmarkType.rightShoulder,
    LandmarkType.leftEar, LandmarkType.rightEar,
  ],
  'SpineCurvatureRule': [
    LandmarkType.leftShoulder, LandmarkType.rightShoulder,
    LandmarkType.leftHip, LandmarkType.rightHip,
    LandmarkType.leftKnee, LandmarkType.rightKnee,
  ],
  'CatCowHeadAlignmentRule': [
    LandmarkType.nose,
    LandmarkType.leftShoulder, LandmarkType.rightShoulder,
  ],
  'StandingAlignmentRule': [
    LandmarkType.leftEar, LandmarkType.rightEar,
    LandmarkType.leftShoulder, LandmarkType.rightShoulder,
    LandmarkType.leftHip, LandmarkType.rightHip,
  ],
  'StandingShoulderLevelRule': [
    LandmarkType.leftShoulder, LandmarkType.rightShoulder,
  ],
};

/// Resolves per-joint color from the per-rule [jointStates] map.
/// Each joint gets the worst (highest index) status of all rules that touch it.
Map<LandmarkType, JointStatus> _resolveJointStatuses(
  Map<String, JointStatus> ruleStates,
) {
  final result = <LandmarkType, JointStatus>{};
  for (final entry in ruleStates.entries) {
    final landmarks = _ruleToLandmarks[entry.key];
    if (landmarks == null) continue;
    for (final lm in landmarks) {
      final existing = result[lm];
      if (existing == null || entry.value.index > existing.index) {
        result[lm] = entry.value;
      }
    }
  }
  return result;
}

/// Maps exercise id strings from the router to engine Exercise enum.
engine.Exercise _exerciseFromId(String? id) {
  switch (id) {
    case 'squat':
      return engine.Exercise.squat;
    case 'lunge':
      return engine.Exercise.lunge;
    case 'shoulder_roll':
      return engine.Exercise.shoulderRoll;
    case 'cat_cow':
      return engine.Exercise.catCow;
    case 'standing_posture':
      return engine.Exercise.standingPosture;
    default:
      return engine.Exercise.standingPosture;
  }
}

// ══════════════════════════════════════════════
//  Live Analysis Screen
// ══════════════════════════════════════════════

class LiveAnalysisScreen extends ConsumerStatefulWidget {
  const LiveAnalysisScreen({super.key, this.exerciseId});
  final String? exerciseId;

  @override
  ConsumerState<LiveAnalysisScreen> createState() => _LiveAnalysisScreenState();
}

class _LiveAnalysisScreenState extends ConsumerState<LiveAnalysisScreen>
    with TickerProviderStateMixin {
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  // Animations
  late final AnimationController _scoreAnimController;
  late final AnimationController _goodFormController;
  late final Animation<double> _goodFormOpacity;
  late final Animation<double> _goodFormScale;
  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;

  late final String _exerciseName;
  late final String _exerciseId;

  int _prevScore = 0;
  bool _wasCelebrating = false;

  @override
  void initState() {
    super.initState();

    _exerciseId = widget.exerciseId ?? exercises.first.id;
    _exerciseName = exerciseById(_exerciseId).name;

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

    _entranceController.forward();

    // Elapsed time counter
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });

    // Set the selected exercise for the engine & start camera after frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(engine.selectedExerciseProvider.notifier).state =
          _exerciseFromId(_exerciseId);
      _initCamera();
    });
  }

  Future<void> _initCamera() async {
    try {
      final notifier = ref.read(cameraServiceProvider.notifier);
      await notifier.initialize(facing: CameraFacing.back);
      await notifier.startStream();
    } catch (e) {
      debugPrint('Camera init failed: $e');
    }
  }

  void _endSession() {
    _elapsedTimer?.cancel();
    context.go(AppRoutes.report, extra: _exerciseId);
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
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
    final session = ref.watch(feedbackServiceProvider);
    final cameraAsync = ref.watch(cameraServiceProvider);
    final landmarkAsync = ref.watch(landmarksProvider);

    // React to score changes for the ring animation.
    ref.listen<SessionState>(feedbackServiceProvider, (prev, next) {
      if (next.currentScore != (prev?.currentScore ?? 0)) {
        _prevScore = prev?.currentScore ?? 0;
        _scoreAnimController.forward(from: 0);
      }
      // Trigger celebration animation.
      if (next.isCelebrating && !_wasCelebrating) {
        _goodFormController.forward(from: 0);
      }
      _wasCelebrating = next.isCelebrating;
    });

    // Resolve per-joint statuses for the skeleton painter.
    final jointColors = _resolveJointStatuses(session.jointStates);

    // Collect landmarks.
    final landmarks = landmarkAsync.valueOrNull ?? [];

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

                    final cameraFeed = _CameraFeed(
                      cameraAsync: cameraAsync,
                      landmarks: landmarks,
                      jointColors: jointColors,
                    );

                    final feedbackPanel = _FeedbackPanel(
                      exerciseName: _exerciseName,
                      reps: session.repCount,
                      score: session.currentScore,
                      prevScore: _prevScore,
                      scoreAnim: _scoreAnimController,
                      tips: session.corrections,
                      goodFormController: _goodFormController,
                      goodFormOpacity: _goodFormOpacity,
                      goodFormScale: _goodFormScale,
                      isCelebrating: session.isCelebrating,
                    );

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(flex: 3, child: cameraFeed),
                          Expanded(flex: 2, child: feedbackPanel),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Expanded(flex: 5, child: cameraFeed),
                        Expanded(flex: 4, child: feedbackPanel),
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
  const _CameraFeed({
    required this.cameraAsync,
    required this.landmarks,
    required this.jointColors,
  });

  final AsyncValue<CameraState> cameraAsync;
  final List<Landmark> landmarks;
  final Map<LandmarkType, JointStatus> jointColors;

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
              // Camera preview or placeholder
              cameraAsync.when(
                data: (state) {
                  final controller = state.controller;
                  if (controller == null || !controller.value.isInitialized) {
                    return _cameraPlaceholder('Initializing camera...');
                  }
                  return CameraPreview(controller);
                },
                loading: () => _cameraPlaceholder('Starting camera...'),
                error: (e, _) => _cameraPlaceholder('Camera unavailable'),
              ),

              // Skeleton overlay
              if (landmarks.isNotEmpty)
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Get the image dimensions from the camera to map coordinates.
                    final controller =
                        cameraAsync.valueOrNull?.controller;
                    final previewSize =
                        controller?.value.previewSize; // width × height of image
                    final imageW = previewSize?.height ?? constraints.maxWidth;
                    final imageH = previewSize?.width ?? constraints.maxHeight;

                    return CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _SkeletonPainter(
                        landmarks: landmarks,
                        jointColors: jointColors,
                        imageWidth: imageW,
                        imageHeight: imageH,
                      ),
                    );
                  },
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

  Widget _cameraPlaceholder(String message) {
    return Center(
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
            message,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton painter with per-joint color coding ──

class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter({
    required this.landmarks,
    required this.jointColors,
    required this.imageWidth,
    required this.imageHeight,
  });

  final List<Landmark> landmarks;
  final Map<LandmarkType, JointStatus> jointColors;
  final double imageWidth;
  final double imageHeight;

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
    if (landmarks.isEmpty) return;

    // Build lookup by type.
    final byType = <LandmarkType, Landmark>{};
    for (final lm in landmarks) {
      byType[lm.type] = lm;
    }

    // Compute scale to fit image coordinates into the widget, preserving
    // aspect ratio (cover mode, matching CameraPreview behavior).
    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;
    final scale = math.max(scaleX, scaleY);
    final offsetX = (size.width - imageWidth * scale) / 2;
    final offsetY = (size.height - imageHeight * scale) / 2;

    Offset pt(Landmark lm) {
      return Offset(
        lm.x * scale + offsetX,
        lm.y * scale + offsetY,
      );
    }

    JointStatus statusOf(LandmarkType type) {
      return jointColors[type] ?? JointStatus.correct;
    }

    // Draw bones.
    for (final bone in _skeletonBones) {
      final a = byType[bone.$1];
      final b = byType[bone.$2];
      if (a == null || b == null) continue;
      if (a.likelihood < 0.5 || b.likelihood < 0.5) continue;

      final statusA = statusOf(bone.$1);
      final statusB = statusOf(bone.$2);
      final worstStatus = statusA.index >= statusB.index ? statusA : statusB;

      final bonePaint = Paint()
        ..color = _statusColor(worstStatus).withValues(alpha: 0.6)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(pt(a), pt(b), bonePaint);
    }

    // Draw joints — only the subset used in the skeleton.
    const renderedTypes = <LandmarkType>{
      LandmarkType.nose,
      LandmarkType.leftEar, LandmarkType.rightEar,
      LandmarkType.leftShoulder, LandmarkType.rightShoulder,
      LandmarkType.leftElbow, LandmarkType.rightElbow,
      LandmarkType.leftWrist, LandmarkType.rightWrist,
      LandmarkType.leftHip, LandmarkType.rightHip,
      LandmarkType.leftKnee, LandmarkType.rightKnee,
      LandmarkType.leftAnkle, LandmarkType.rightAnkle,
    };

    for (final type in renderedTypes) {
      final lm = byType[type];
      if (lm == null || lm.likelihood < 0.5) continue;

      final p = pt(lm);
      final color = _statusColor(statusOf(type));
      final isHead = type == LandmarkType.nose;
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
    required this.isCelebrating,
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
  final bool isCelebrating;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        Container(
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
                child: tips.isEmpty
                    ? Center(
                        child: Text(
                          'Looking good! Keep it up.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      )
                    : ListView.separated(
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
        ),

        // ── Green celebration overlay ──
        if (isCelebrating)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: isCelebrating ? 0.12 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.sm + 2, 0, AppSpacing.sm + 2, AppSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                ),
              ),
            ),
          ),
      ],
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
