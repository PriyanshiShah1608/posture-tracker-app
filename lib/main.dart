import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/live_analysis_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/report_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const PosturelyApp());
}

class PosturelyApp extends StatelessWidget {
  const PosturelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posturely',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        fontFamily: 'Inter',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/exercises': (context) => const ExercisesScreen(),
        '/stats': (context) => const StatsScreen(),
        '/scan': (context) => const ScanScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/live-analysis': (context) => const LiveAnalysisScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/report': (context) => const ReportScreen(),
      },
    );
  }
}
