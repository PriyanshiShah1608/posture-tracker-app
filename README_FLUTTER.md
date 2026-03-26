# Posturely - Flutter/Dart Version

A complete Flutter conversion of the Posturely AI-Powered Posture Care app with modern medical-tech aesthetic.

## 🎨 Design Features

- **Solid Color Palette**: Indigo primary (#4F46E5), Blue, Purple, Green, Orange accents
- **No Gradients**: Clean, flat design throughout (except minimal use in onboarding)
- **Floating Navigation**: Rounded bottom navigation bar with 16px margin
- **Medical-Grade UI**: Professional, trustworthy interface for healthcare applications
- **Responsive Design**: Built for mobile devices with Flutter's adaptive layouts

## 📱 Screens Included

1. **Splash Screen** - Animated logo with medical cross icon
2. **Onboarding** - 4-step introduction with effects, features, and case studies
3. **Home Screen** - Daily goals, device selection, quick start
4. **Exercises Library** - Patient-safe exercises with difficulty badges
5. **Stats/Progress** - Weekly charts, time tracking, streaks
6. **Body Scan** - AI-powered posture analysis setup
7. **Profile** - User settings and account management
8. **Live Analysis** - Real-time posture tracking with AI skeleton overlay
9. **Feedback** - Exercise form comparison and improvement tips
10. **Report** - Comprehensive posture assessment with recommendations

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio or Xcode (for iOS)
- VS Code or Android Studio with Flutter plugins

### Installation

1. **Navigate to the Flutter project directory**:
   ```bash
   cd /path/to/your/flutter/project
   ```

2. **Copy all the Dart files to your Flutter project**:
   - `/lib/main.dart`
   - `/lib/screens/*.dart`
   - `/lib/widgets/*.dart`
   - `/pubspec.yaml`

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── main.dart                      # App entry point with routes
├── widgets/
│   └── bottom_nav.dart           # Floating bottom navigation bar
└── screens/
    ├── splash_screen.dart        # Initial splash with logo
    ├── onboarding_screen.dart    # 4-step onboarding flow
    ├── home_screen.dart          # Main dashboard
    ├── exercises_screen.dart     # Exercise library
    ├── stats_screen.dart         # Progress tracking
    ├── scan_screen.dart          # Body scan setup
    ├── profile_screen.dart       # User profile
    ├── live_analysis_screen.dart # Real-time posture tracking
    ├── feedback_screen.dart      # Exercise feedback
    └── report_screen.dart        # Comprehensive report
```

## 🎯 Key Features

### Navigation
- Named route-based navigation
- Floating bottom nav with 5 sections
- Back button support on all screens
- Smooth transitions

### UI Components
- Custom painted medical cross logo
- Circular progress indicators
- Bar charts for progress tracking
- Skeleton overlay for posture analysis
- Material Design 3 components

### Color Scheme
```dart
Primary: Color(0xFF4F46E5)     // Indigo
Blue:    Color(0xFF3B82F6)     // Blue
Purple:  Color(0xFF9333EA)     // Purple
Green:   Color(0xFF10B981)     // Green
Orange:  Color(0xFFF97316)     // Orange
Red:     Color(0xFFDC2626)     // Red
Gray:    Color(0xFFF9FAFB)     // Background
```

## 🔧 Customization

### Modify Colors
Edit the color values in each screen's decoration widgets to match your brand.

### Add Camera Integration
Replace the placeholder camera view in `live_analysis_screen.dart` with:
- `camera` package for camera access
- `tflite_flutter` for AI model inference
- `pose_detection` for skeleton tracking

### Connect to Backend
Add API calls using:
- `http` package for REST APIs
- `dio` package for advanced networking
- `firebase_core` for Firebase integration

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ⚠️ Web (needs responsive adjustments)
- ⚠️ Desktop (needs layout optimization)

## 🐛 Known Limitations

1. **Camera Integration**: Placeholder UI only - needs camera package integration
2. **AI Model**: No actual AI inference - requires TFLite model integration
3. **Data Persistence**: No local storage - add `shared_preferences` or `sqflite`
4. **Authentication**: No user auth - integrate Firebase Auth or custom solution
5. **Charts**: Basic bar charts - consider `fl_chart` package for advanced visualizations

## 📦 Recommended Packages

Add these to `pubspec.yaml` for full functionality:

```yaml
dependencies:
  # Camera & AI
  camera: ^0.10.5
  tflite_flutter: ^0.10.4
  
  # Charts
  fl_chart: ^0.66.0
  
  # State Management
  provider: ^6.1.1
  # or riverpod: ^2.4.9
  
  # Storage
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
  
  # Networking
  dio: ^5.4.0
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
```

## 🎨 Design System

- **Border Radius**: 8-24px for cards and buttons
- **Spacing**: 4, 8, 12, 16, 24, 32px increments
- **Typography**: Default system font (or add Inter font)
- **Shadows**: Subtle elevation with gray colors
- **Icons**: Material Icons with 20-24px sizes

## 📄 License

This is a conversion of the Posturely design. Use according to your project's license.

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📞 Support

For Flutter-specific questions:
- Flutter Documentation: https://docs.flutter.dev
- Flutter Community: https://flutter.dev/community

---

**Made with Flutter 💙**
