import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/landmark.dart';
import 'pose_detection_service.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum Exercise { squat, lunge, shoulderRoll, catCow, standingPosture }

enum JointStatus { correct, warning, incorrect }

class PostureResult {
  final int score;
  final int repCount;
  final Map<String, JointStatus> jointStates;
  final List<String> activeCorrections;

  const PostureResult({
    required this.score,
    required this.repCount,
    required this.jointStates,
    required this.activeCorrections,
  });

  static const empty = PostureResult(
    score: 0,
    repCount: 0,
    jointStates: {},
    activeCorrections: [],
  );
}

class RuleResult {
  final bool passed;
  final JointStatus severity;
  final String message;

  const RuleResult({
    required this.passed,
    required this.severity,
    required this.message,
  });
}

// ---------------------------------------------------------------------------
// Angle utilities
// ---------------------------------------------------------------------------

/// Returns the angle in degrees at point [b] formed by segments ba and bc.
double calculateAngle(Landmark a, Landmark b, Landmark c) {
  final baX = a.x - b.x;
  final baY = a.y - b.y;
  final bcX = c.x - b.x;
  final bcY = c.y - b.y;

  final dot = baX * bcX + baY * bcY;
  final magBA = math.sqrt(baX * baX + baY * baY);
  final magBC = math.sqrt(bcX * bcX + bcY * bcY);

  if (magBA == 0 || magBC == 0) return 0;

  final cosAngle = (dot / (magBA * magBC)).clamp(-1.0, 1.0);
  return math.acos(cosAngle) * (180.0 / math.pi);
}

// ---------------------------------------------------------------------------
// PostureRule interface
// ---------------------------------------------------------------------------

abstract class PostureRule {
  /// Evaluate the rule against the current [landmarks].
  /// [byType] is a pre-built lookup for convenience.
  RuleResult evaluate(
    Map<LandmarkType, Landmark> byType,
    double confidenceThreshold,
  );
}

// ---------------------------------------------------------------------------
// Helpers shared by rules
// ---------------------------------------------------------------------------

const _defaultConfidence = 0.5;

Landmark? _get(
  Map<LandmarkType, Landmark> m,
  LandmarkType t,
  double threshold,
) {
  final lm = m[t];
  if (lm == null || lm.likelihood < threshold) return null;
  return lm;
}

bool _allPresent(List<Landmark?> lms) => lms.every((l) => l != null);

JointStatus _statusFromAngle(
  double angle, {
  required double correct,
  required double warningDelta,
  required double incorrectDelta,
}) {
  final diff = (angle - correct).abs();
  if (diff <= warningDelta) return JointStatus.correct;
  if (diff <= incorrectDelta) return JointStatus.warning;
  return JointStatus.incorrect;
}

// ---------------------------------------------------------------------------
// Squat rules
// ---------------------------------------------------------------------------

class SquatKneeAngleRule extends PostureRule {
  @override
  RuleResult evaluate(Map<LandmarkType, Landmark> byType, double ct) {
    final lHip = _get(byType, LandmarkType.leftHip, ct);
    final lKnee = _get(byType, LandmarkType.leftKnee, ct);
    final lAnkle = _get(byType, LandmarkType.leftAnkle, ct);
    final rHip = _get(byType, LandmarkType.rightHip, ct);
    final rKnee = _get(byType, LandmarkType.rightKnee, ct);
    final rAnkle = _get(byType, LandmarkType.rightAnkle, ct);

    // Prefer whichever side has all landmarks visible.
    double? angle;
    if (_allPresent([lHip, lKnee, lAnkle])) {
      angle = calculateAngle(lHip!, lKnee!, lAnkle!);
    } else if (_allPresent([rHip, rKnee, rAnkle])) {
      angle = calculateAngle(rHip!, rKnee!, rAnkle!);
    }

    if (angle == null) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    // Good squat depth: knee angle ~90°. Warning 70-110°, incorrect outside.
    final status = _statusFromAngle(
      angle,
      correct: 90,
      warningDelta: 20,
      incorrectDelta: 40,
    );

    if (status == JointStatus.correct) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final msg = angle > 110
        ? 'Go deeper — bend your knees more'
        : 'Don\'t go too low — keep knees at ~90°';

    return RuleResult(passed: false, severity: status, message: msg);
  }
}

class SquatBackStraightRule extends PostureRule {
  @override
  RuleResult evaluate(Map<LandmarkType, Landmark> byType, double ct) {
    final shoulder = _get(byType, LandmarkType.leftShoulder, ct) ??
        _get(byType, LandmarkType.rightShoulder, ct);
    final hip = _get(byType, LandmarkType.leftHip, ct) ??
        _get(byType, LandmarkType.rightHip, ct);
    final knee = _get(byType, LandmarkType.leftKnee, ct) ??
        _get(byType, LandmarkType.rightKnee, ct);

    if (!_allPresent([shoulder, hip, knee])) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final angle = calculateAngle(shoulder!, hip!, knee!);
    // Torso should stay relatively upright: ~90° at the hip is ideal during
    // a squat. Large forward lean (<60°) is problematic.
    if (angle >= 60) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final status = angle >= 45 ? JointStatus.warning : JointStatus.incorrect;
    return RuleResult(
      passed: false,
      severity: status,
      message: 'Keep your back straighter — avoid leaning forward',
    );
  }
}

// ---------------------------------------------------------------------------
// Lunge rules
// ---------------------------------------------------------------------------

class LungeKneeAngleRule extends PostureRule {
  @override
  RuleResult evaluate(Map<LandmarkType, Landmark> byType, double ct) {
    // Check front knee: the lower knee (larger y) is typically the front leg.
    final lKnee = _get(byType, LandmarkType.leftKnee, ct);
    final rKnee = _get(byType, LandmarkType.rightKnee, ct);

    LandmarkType hipType, kneeType, ankleType;
    if (lKnee != null && rKnee != null) {
      final leftIsFront = lKnee.y > rKnee.y;
      hipType = leftIsFront ? LandmarkType.leftHip : LandmarkType.rightHip;
      kneeType =
          leftIsFront ? LandmarkType.leftKnee : LandmarkType.rightKnee;
      ankleType =
          leftIsFront ? LandmarkType.leftAnkle : LandmarkType.rightAnkle;
    } else {
      hipType = LandmarkType.leftHip;
      kneeType = LandmarkType.leftKnee;
      ankleType = LandmarkType.leftAnkle;
    }

    final hip = _get(byType, hipType, ct);
    final knee = _get(byType, kneeType, ct);
    final ankle = _get(byType, ankleType, ct);

    if (!_allPresent([hip, knee, ankle])) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final angle = calculateAngle(hip!, knee!, ankle!);
    final status = _statusFromAngle(
      angle,
      correct: 90,
      warningDelta: 15,
      incorrectDelta: 35,
    );

    if (status == JointStatus.correct) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    return RuleResult(
      passed: false,
      severity: status,
      message: angle > 105
          ? 'Bend your front knee deeper'
          : 'Front knee is bending too far forward',
    );
  }
}

class LungeTorsoUprightRule extends PostureRule {
  @override
  RuleResult evaluate(Map<LandmarkType, Landmark> byType, double ct) {
    final shoulder = _get(byType, LandmarkType.leftShoulder, ct) ??
        _get(byType, LandmarkType.rightShoulder, ct);
    final hip = _get(byType, LandmarkType.leftHip, ct) ??
        _get(byType, LandmarkType.rightHip, ct);

    if (!_allPresent([shoulder, hip])) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    // Vertical alignment: dx between shoulder and hip should be small
    // relative to dy.
    final dx = (shoulder!.x - hip!.x).abs();
    final dy = (shoulder.y - hip.y).abs();
    final ratio = dy > 0 ? dx / dy : double.infinity;

    if (ratio < 0.25) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final status = ratio < 0.5 ? JointStatus.warning : JointStatus.incorrect;
    return RuleResult(
      passed: false,
      severity: status,
      message: 'Keep your torso upright — don\'t lean forward',
    );
  }
}

// ---------------------------------------------------------------------------
// Shoulder roll rules
// ---------------------------------------------------------------------------

class ShoulderSymmetryRule extends PostureRule {
  @override
  RuleResult evaluate(Map<LandmarkType, Landmark> byType, double ct) {
    final lShoulder = _get(byType, LandmarkType.leftShoulder, ct);
    final rShoulder = _get(byType, LandmarkType.rightShoulder, ct);

    if (!_allPresent([lShoulder, rShoulder])) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final yDiff = (lShoulder!.y - rShoulder!.y).abs();
    // Shoulder width as reference scale.
    final shoulderWidth = (lShoulder.x - rShoulder.x).abs();
    final ratio = shoulderWidth > 0 ? yDiff / shoulderWidth : 0.0;

    if (ratio < 0.08) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final status = ratio < 0.15 ? JointStatus.warning : JointStatus.incorrect;
    final side = lShoulder.y < rShoulder.y ? 'left' : 'right';
    return RuleResult(
      passed: false,
      severity: status,
      message: 'Your $side shoulder is higher — try to keep them level',
    );
  }
}

class ShoulderEarDistanceRule extends PostureRule {
  @override
  RuleResult evaluate(Map<LandmarkType, Landmark> byType, double ct) {
    final lShoulder = _get(byType, LandmarkType.leftShoulder, ct);
    final rShoulder = _get(byType, LandmarkType.rightShoulder, ct);
    final lEar = _get(byType, LandmarkType.leftEar, ct);
    final rEar = _get(byType, LandmarkType.rightEar, ct);

    if (!_allPresent([lShoulder, rShoulder, lEar, rEar])) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final leftDist = (lShoulder!.y - lEar!.y).abs();
    final rightDist = (rShoulder!.y - rEar!.y).abs();
    final diff = (leftDist - rightDist).abs();
    final avg = (leftDist + rightDist) / 2;
    final ratio = avg > 0 ? diff / avg : 0.0;

    if (ratio < 0.15) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final status = ratio < 0.30 ? JointStatus.warning : JointStatus.incorrect;
    return RuleResult(
      passed: false,
      severity: status,
      message: 'Relax your shoulders down — they\'re rising unevenly',
    );
  }
}

// ---------------------------------------------------------------------------
// Cat-Cow rules
// ---------------------------------------------------------------------------

class SpineCurvatureRule extends PostureRule {
  @override
  RuleResult evaluate(Map<LandmarkType, Landmark> byType, double ct) {
    final shoulder = _get(byType, LandmarkType.leftShoulder, ct) ??
        _get(byType, LandmarkType.rightShoulder, ct);
    final hip = _get(byType, LandmarkType.leftHip, ct) ??
        _get(byType, LandmarkType.rightHip, ct);
    final knee = _get(byType, LandmarkType.leftKnee, ct) ??
        _get(byType, LandmarkType.rightKnee, ct);

    if (!_allPresent([shoulder, hip, knee])) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final angle = calculateAngle(shoulder!, hip!, knee!);
    // During cat-cow the spine should flex/extend — angles between 70-170° are
    // expected movement range. Extremes outside that range indicate over-strain.
    if (angle >= 70 && angle <= 170) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    return const RuleResult(
      passed: false,
      severity: JointStatus.warning,
      message: 'Control your spinal movement — don\'t overextend',
    );
  }
}

class CatCowHeadAlignmentRule extends PostureRule {
  @override
  RuleResult evaluate(Map<LandmarkType, Landmark> byType, double ct) {
    final nose = _get(byType, LandmarkType.nose, ct);
    final shoulder = _get(byType, LandmarkType.leftShoulder, ct) ??
        _get(byType, LandmarkType.rightShoulder, ct);

    if (!_allPresent([nose, shoulder])) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    // In cat-cow, the head should follow the spine — not drop excessively
    // below or jut far above the shoulders.
    final yDiff = nose!.y - shoulder!.y;
    final shoulderWidth = ((byType[LandmarkType.leftShoulder]?.x ?? 0) -
            (byType[LandmarkType.rightShoulder]?.x ?? 0))
        .abs();
    final refScale = shoulderWidth > 0 ? shoulderWidth : 100.0;

    if ((yDiff / refScale).abs() < 0.8) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    return const RuleResult(
      passed: false,
      severity: JointStatus.warning,
      message: 'Let your head follow your spine naturally',
    );
  }
}

// ---------------------------------------------------------------------------
// Standing posture rules
// ---------------------------------------------------------------------------

class StandingAlignmentRule extends PostureRule {
  @override
  RuleResult evaluate(Map<LandmarkType, Landmark> byType, double ct) {
    final ear = _get(byType, LandmarkType.leftEar, ct) ??
        _get(byType, LandmarkType.rightEar, ct);
    final shoulder = _get(byType, LandmarkType.leftShoulder, ct) ??
        _get(byType, LandmarkType.rightShoulder, ct);
    final hip = _get(byType, LandmarkType.leftHip, ct) ??
        _get(byType, LandmarkType.rightHip, ct);

    if (!_allPresent([ear, shoulder, hip])) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    // Ear-shoulder-hip should be roughly collinear (~180°).
    final angle = calculateAngle(ear!, shoulder!, hip!);
    final status = _statusFromAngle(
      angle,
      correct: 170,
      warningDelta: 15,
      incorrectDelta: 30,
    );

    if (status == JointStatus.correct) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    return RuleResult(
      passed: false,
      severity: status,
      message: angle < 155
          ? 'Stand taller — align ear over shoulder over hip'
          : 'Slight forward lean detected — pull shoulders back',
    );
  }
}

class StandingShoulderLevelRule extends PostureRule {
  @override
  RuleResult evaluate(Map<LandmarkType, Landmark> byType, double ct) {
    final lShoulder = _get(byType, LandmarkType.leftShoulder, ct);
    final rShoulder = _get(byType, LandmarkType.rightShoulder, ct);

    if (!_allPresent([lShoulder, rShoulder])) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final yDiff = (lShoulder!.y - rShoulder!.y).abs();
    final shoulderWidth = (lShoulder.x - rShoulder.x).abs();
    final ratio = shoulderWidth > 0 ? yDiff / shoulderWidth : 0.0;

    if (ratio < 0.06) {
      return const RuleResult(
        passed: true,
        severity: JointStatus.correct,
        message: '',
      );
    }

    final status = ratio < 0.12 ? JointStatus.warning : JointStatus.incorrect;
    return RuleResult(
      passed: false,
      severity: status,
      message: 'Level your shoulders — one side is dropping',
    );
  }
}

// ---------------------------------------------------------------------------
// Rule registry
// ---------------------------------------------------------------------------

final Map<Exercise, List<PostureRule>> _exerciseRules = {
  Exercise.squat: [SquatKneeAngleRule(), SquatBackStraightRule()],
  Exercise.lunge: [LungeKneeAngleRule(), LungeTorsoUprightRule()],
  Exercise.shoulderRoll: [ShoulderSymmetryRule(), ShoulderEarDistanceRule()],
  Exercise.catCow: [SpineCurvatureRule(), CatCowHeadAlignmentRule()],
  Exercise.standingPosture: [
    StandingAlignmentRule(),
    StandingShoulderLevelRule(),
  ],
};

// ---------------------------------------------------------------------------
// Rep counting
// ---------------------------------------------------------------------------

class _RepCounter {
  bool _wasDown = false;
  int count = 0;

  /// Feed an angle (e.g. knee angle for squats). A rep is counted when the
  /// angle crosses below [downThreshold] then back above [upThreshold].
  void update(double angle, {double downThreshold = 110, double upThreshold = 150}) {
    if (!_wasDown && angle < downThreshold) {
      _wasDown = true;
    } else if (_wasDown && angle > upThreshold) {
      _wasDown = false;
      count++;
    }
  }
}

// ---------------------------------------------------------------------------
// Engine
// ---------------------------------------------------------------------------

class PostureEngine {
  final Map<Exercise, _RepCounter> _repCounters = {
    for (final e in Exercise.values) e: _RepCounter(),
  };

  double confidenceThreshold;

  PostureEngine({this.confidenceThreshold = _defaultConfidence});

  PostureResult evaluate(List<Landmark> landmarks, Exercise exercise) {
    if (landmarks.isEmpty) return PostureResult.empty;

    final byType = <LandmarkType, Landmark>{};
    for (final lm in landmarks) {
      byType[lm.type] = lm;
    }

    final rules = _exerciseRules[exercise] ?? [];
    final jointStates = <String, JointStatus>{};
    final corrections = <_ScoredCorrection>[];

    for (final rule in rules) {
      final result = rule.evaluate(byType, confidenceThreshold);
      final ruleName = rule.runtimeType.toString();
      jointStates[ruleName] = result.severity;

      if (!result.passed && result.message.isNotEmpty) {
        corrections.add(_ScoredCorrection(result.severity, result.message));
      }
    }

    // Rep counting for applicable exercises.
    _updateRepCount(byType, exercise);

    // Score: start at 100, deduct per failed rule.
    var score = 100;
    for (final state in jointStates.values) {
      if (state == JointStatus.warning) score -= 15;
      if (state == JointStatus.incorrect) score -= 30;
    }
    score = score.clamp(0, 100);

    // Sort corrections by severity (incorrect first), cap at 3.
    corrections.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    final topCorrections =
        corrections.take(3).map((c) => c.message).toList();

    return PostureResult(
      score: score,
      repCount: _repCounters[exercise]!.count,
      jointStates: jointStates,
      activeCorrections: topCorrections,
    );
  }

  void _updateRepCount(Map<LandmarkType, Landmark> byType, Exercise exercise) {
    final counter = _repCounters[exercise]!;

    switch (exercise) {
      case Exercise.squat:
        final hip = byType[LandmarkType.leftHip] ?? byType[LandmarkType.rightHip];
        final knee = byType[LandmarkType.leftKnee] ?? byType[LandmarkType.rightKnee];
        final ankle = byType[LandmarkType.leftAnkle] ?? byType[LandmarkType.rightAnkle];
        if (_allPresent([hip, knee, ankle])) {
          counter.update(calculateAngle(hip!, knee!, ankle!));
        }
        break;
      case Exercise.lunge:
        final hip = byType[LandmarkType.leftHip] ?? byType[LandmarkType.rightHip];
        final knee = byType[LandmarkType.leftKnee] ?? byType[LandmarkType.rightKnee];
        final ankle = byType[LandmarkType.leftAnkle] ?? byType[LandmarkType.rightAnkle];
        if (_allPresent([hip, knee, ankle])) {
          counter.update(calculateAngle(hip!, knee!, ankle!));
        }
        break;
      case Exercise.shoulderRoll:
      case Exercise.catCow:
      case Exercise.standingPosture:
        // These exercises don't have a clear rep cycle.
        break;
    }
  }

  void resetReps(Exercise exercise) {
    _repCounters[exercise] = _RepCounter();
  }

  void resetAll() {
    for (final e in Exercise.values) {
      _repCounters[e] = _RepCounter();
    }
  }
}

class _ScoredCorrection {
  final JointStatus severity;
  final String message;
  const _ScoredCorrection(this.severity, this.message);
}

// ---------------------------------------------------------------------------
// Riverpod providers
// ---------------------------------------------------------------------------

/// Currently selected exercise. UI sets this via the notifier.
final selectedExerciseProvider =
    StateProvider<Exercise>((ref) => Exercise.standingPosture);

final postureEngineProvider = Provider.autoDispose<PostureEngine>((ref) {
  return PostureEngine();
});

/// Stream of [PostureResult] produced by feeding each landmark frame through
/// the engine with the currently selected exercise.
final postureResultStreamProvider =
    Provider.autoDispose<AsyncValue<PostureResult>>((ref) {
  final engine = ref.watch(postureEngineProvider);
  final exercise = ref.watch(selectedExerciseProvider);
  final landmarkAsync = ref.watch(landmarksProvider);

  return landmarkAsync.whenData(
    (landmarks) => engine.evaluate(landmarks, exercise),
  );
});
