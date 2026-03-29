import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Exercise {
  final String id;
  final String name;
  final String description;
  final String difficulty;
  final IconData icon;
  final Color accentColor;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.icon,
    required this.accentColor,
  });
}

const exercises = <Exercise>[
  Exercise(
    id: 'squat',
    name: 'Squat',
    description: 'Build lower-body strength with proper form',
    difficulty: 'Beginner',
    icon: Icons.fitness_center_rounded,
    accentColor: AppColors.primary,
  ),
  Exercise(
    id: 'lunge',
    name: 'Lunge',
    description: 'Improve balance and hip flexibility',
    difficulty: 'Beginner',
    icon: Icons.directions_walk_rounded,
    accentColor: Color(0xFF2E8B8B),
  ),
  Exercise(
    id: 'shoulder_roll',
    name: 'Shoulder Roll',
    description: 'Release tension from desk posture',
    difficulty: 'Easy',
    icon: Icons.accessibility_new_rounded,
    accentColor: Color(0xFFD97706),
  ),
  Exercise(
    id: 'cat_cow',
    name: 'Cat-Cow',
    description: 'Gentle spine mobility and core activation',
    difficulty: 'Easy',
    icon: Icons.self_improvement_rounded,
    accentColor: Color(0xFF7C3AED),
  ),
  Exercise(
    id: 'standing_posture',
    name: 'Standing Check',
    description: 'Assess and correct your standing alignment',
    difficulty: 'All levels',
    icon: Icons.person_rounded,
    accentColor: Color(0xFF059669),
  ),
];

/// Look up an exercise by id, falling back to the first exercise.
Exercise exerciseById(String? id) {
  if (id == null) return exercises.first;
  return exercises.firstWhere(
    (e) => e.id == id,
    orElse: () => exercises.first,
  );
}
