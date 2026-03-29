import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

// ─── Route paths ─────────────────────────────

class AppRoutes {
  AppRoutes._();
  static const splash      = '/';
  static const onboarding  = '/onboarding';
  static const home        = '/home';
  static const exercises   = '/exercises';
  static const scan        = '/scan';
  static const stats       = '/stats';
  static const profile     = '/profile';
  static const liveSession = '/live-session';
  static const feedback    = '/feedback';
  static const report      = '/report';
}

// ─── Custom page transitions ─────────────────

CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
  Duration duration = const Duration(milliseconds: 350),
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _slideUpPage({
  required GoRouterState state,
  required Widget child,
  Duration duration = const Duration(milliseconds: 450),
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: Tween(begin: 0.3, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _slideRightPage({
  required GoRouterState state,
  required Widget child,
  Duration duration = const Duration(milliseconds: 400),
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: Tween(begin: 0.5, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// No transition — instant swap (used for tab switches)
CustomTransitionPage<void> _noTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (_, __, ___, child) => child,
  );
}

// ─── Router configuration ────────────────────

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Splash → fade to onboarding
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const SplashScreen(),
        duration: const Duration(milliseconds: 200),
      ),
    ),

    // Onboarding → slide up to home
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const OnboardingScreen(),
      ),
    ),

    // ── Tab screens (no transition between tabs) ──
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.exercises,
      pageBuilder: (context, state) => _noTransitionPage(
        state: state,
        child: const ExercisesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.scan,
      pageBuilder: (context, state) => _noTransitionPage(
        state: state,
        child: const ScanScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.stats,
      pageBuilder: (context, state) => _noTransitionPage(
        state: state,
        child: const StatsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.profile,
      pageBuilder: (context, state) => _noTransitionPage(
        state: state,
        child: const ProfileScreen(),
      ),
    ),

    // Live session — slide right, exercise id passed via extra
    GoRoute(
      path: AppRoutes.liveSession,
      pageBuilder: (context, state) {
        final exerciseId = state.extra as String?;
        return _slideRightPage(
          state: state,
          child: LiveAnalysisScreen(exerciseId: exerciseId),
        );
      },
    ),

    // Feedback
    GoRoute(
      path: AppRoutes.feedback,
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: const FeedbackScreen(),
      ),
    ),

    // Report — slide up from bottom
    GoRoute(
      path: AppRoutes.report,
      pageBuilder: (context, state) {
        final exerciseId = state.extra as String?;
        return _slideUpPage(
          state: state,
          child: ReportScreen(exerciseId: exerciseId),
        );
      },
    ),
  ],
);
