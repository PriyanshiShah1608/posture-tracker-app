# posturely

**AI-powered posture correction for rehabilitation exercises.**

---

Posturely performs real-time posture analysis using MediaPipe pose detection. Users select from five rehabilitation exercises, the camera analyzes their form frame-by-frame, and the app delivers instant correction feedback with a computed posture score. Built with Flutter for cross-platform support on Android and Windows.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41.6 / Dart |
| State Management | Riverpod |
| Pose Detection | Google ML Kit Pose Detection, MediaPipe |
| Camera | camera package |
| Routing | GoRouter |
| Web Frontend | React, Vite, pnpm |

## Architecture

The core analysis pipeline is split into four services with strict one-directional data flow:

```
CameraService -> PoseDetectionService -> PostureEngineService -> FeedbackService
```

**CameraService** captures frames from the device camera. **PoseDetectionService** runs ML Kit pose detection to extract body landmarks. **PostureEngineService** computes joint angles and compares them against exercise-specific thresholds. **FeedbackService** produces the correction text and posture score that the UI consumes. The UI layer only touches `FeedbackService` — it never reaches into the pipeline directly.

## Supported Exercises

- **Shoulder Abduction** — tracks shoulder and elbow angles for correct lateral raise form
- **Bicep Curl** — monitors elbow flexion and upper arm stability throughout the curl
- **Seated Knee Extension** — analyzes knee angle progression and hip stability
- **Standing Hip Flexion** — evaluates hip angle and trunk alignment during the lift
- **Wall Push-Up** — checks elbow angle, shoulder alignment, and body straightness

## Getting Started

### Flutter (Android / Windows)

Requires Flutter **3.41.6** stable. Android SDK should be installed with `ANDROID_HOME` set.

```bash
flutter pub get
flutter run -d <device-id>
```

Use `flutter devices` to list available device IDs.

### Web (React / Vite)

```bash
pnpm install
pnpm dev
```

## Project Structure

```
lib/
  main.dart
  router.dart
  models/
    exercise.dart          # Exercise definitions and metadata
    landmark.dart          # Pose landmark data model
  services/
    camera_service.dart
    pose_detection_service.dart
    posture_engine_service.dart
    feedback_service.dart
  screens/
    home_screen.dart
    exercises_screen.dart
    live_analysis_screen.dart
    feedback_screen.dart
    report_screen.dart
    ...
  widgets/
    bottom_nav.dart
  theme/
    app_theme.dart
```

---

Built for Codecure hackathon — Round 1 submission.
