/// Pure-Dart landmark representation decoupled from MLKit types.
/// Both the pose detection bridge and posture engine import this.

enum LandmarkType {
  nose,
  leftEyeInner, leftEye, leftEyeOuter,
  rightEyeInner, rightEye, rightEyeOuter,
  leftEar, rightEar,
  leftMouth, rightMouth,
  leftShoulder, rightShoulder,
  leftElbow, rightElbow,
  leftWrist, rightWrist,
  leftPinky, rightPinky,
  leftIndex, rightIndex,
  leftThumb, rightThumb,
  leftHip, rightHip,
  leftKnee, rightKnee,
  leftAnkle, rightAnkle,
  leftHeel, rightHeel,
  leftFootIndex, rightFootIndex,
}

class Landmark {
  final LandmarkType type;
  final double x;
  final double y;
  final double z;
  final double likelihood;

  const Landmark({
    required this.type,
    required this.x,
    required this.y,
    required this.z,
    required this.likelihood,
  });
}
