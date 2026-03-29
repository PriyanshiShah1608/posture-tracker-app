import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'posture_engine_service.dart';

export 'posture_engine_service.dart' show Exercise, JointStatus, selectedExerciseProvider;
export 'pose_detection_service.dart' show landmarksProvider;

// ---------------------------------------------------------------------------
// Session state — the single model the UI binds to
// ---------------------------------------------------------------------------

class SessionState {
  final int currentScore;
  final double averageScore;
  final int repCount;
  final List<String> corrections;
  final bool isCelebrating;
  final Map<String, JointStatus> jointStates;

  const SessionState({
    this.currentScore = 0,
    this.averageScore = 0,
    this.repCount = 0,
    this.corrections = const [],
    this.isCelebrating = false,
    this.jointStates = const {},
  });

  SessionState copyWith({
    int? currentScore,
    double? averageScore,
    int? repCount,
    List<String>? corrections,
    bool? isCelebrating,
    Map<String, JointStatus>? jointStates,
  }) {
    return SessionState(
      currentScore: currentScore ?? this.currentScore,
      averageScore: averageScore ?? this.averageScore,
      repCount: repCount ?? this.repCount,
      corrections: corrections ?? this.corrections,
      isCelebrating: isCelebrating ?? this.isCelebrating,
      jointStates: jointStates ?? this.jointStates,
    );
  }
}

// ---------------------------------------------------------------------------
// Feedback service
// ---------------------------------------------------------------------------

class FeedbackService extends StateNotifier<SessionState> {
  FeedbackService() : super(const SessionState());

  static const _historySize = 30;
  static const _celebrationDuration = Duration(milliseconds: 1500);
  static const _celebrationThreshold = 80;

  final Queue<int> _scoreHistory = Queue<int>();
  bool _wasBelowThreshold = true;
  Timer? _celebrationTimer;

  void onPostureResult(PostureResult result) {
    // Update rolling score history.
    _scoreHistory.addLast(result.score);
    if (_scoreHistory.length > _historySize) {
      _scoreHistory.removeFirst();
    }

    final avg = _scoreHistory.isEmpty
        ? 0.0
        : _scoreHistory.reduce((a, b) => a + b) / _scoreHistory.length;

    // Celebration: pulse when score crosses above threshold from below.
    var celebrating = state.isCelebrating;
    if (result.score >= _celebrationThreshold && _wasBelowThreshold) {
      celebrating = true;
      _startCelebrationTimer();
    }
    _wasBelowThreshold = result.score < _celebrationThreshold;

    // Prioritize corrections by severity — PostureEngine already sorts by
    // severity and caps at 3, so we pass them through directly.
    final corrections = result.activeCorrections;

    state = state.copyWith(
      currentScore: result.score,
      averageScore: avg,
      repCount: result.repCount,
      corrections: corrections,
      isCelebrating: celebrating,
      jointStates: result.jointStates,
    );
  }

  void _startCelebrationTimer() {
    _celebrationTimer?.cancel();
    _celebrationTimer = Timer(_celebrationDuration, () {
      if (mounted) {
        state = state.copyWith(isCelebrating: false);
      }
    });
  }

  void resetSession() {
    _scoreHistory.clear();
    _wasBelowThreshold = true;
    _celebrationTimer?.cancel();
    state = const SessionState();
  }

  @override
  void dispose() {
    _celebrationTimer?.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Riverpod providers
// ---------------------------------------------------------------------------

final feedbackServiceProvider =
    StateNotifierProvider.autoDispose<FeedbackService, SessionState>((ref) {
  final service = FeedbackService();

  // Feed posture results into the feedback service.
  ref.listen<AsyncValue<PostureResult>>(
    postureResultStreamProvider,
    (previous, next) {
      next.whenData(service.onPostureResult);
    },
  );

  return service;
});
