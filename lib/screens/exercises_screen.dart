import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav.dart';
import '../router.dart';

class ExerciseItem {
  final String name;
  final String category;
  final String duration;
  final String difficulty;
  final String badge;
  final Color color;
  final Color iconColor;
  final Color borderColor;

  ExerciseItem({
    required this.name,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.badge,
    required this.color,
    required this.iconColor,
    required this.borderColor,
  });
}

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  int _currentIndex = 1;

  final List<Exercise> exercises = [
    Exercise(
      name: 'Squat',
      category: 'Lower Body',
      duration: '3 sets × 12 reps',
      difficulty: 'Beginner',
      badge: 'Patient-Safe',
      color: const Color(0xFFDEEBFF),
      iconColor: const Color(0xFF3B82F6),
      borderColor: const Color(0xFFBFDBFE),
    ),
    Exercise(
      name: 'Plank',
      category: 'Core Stability',
      duration: '3 sets × 30 sec',
      difficulty: 'Beginner',
      badge: 'Patient-Safe',
      color: const Color(0xFFF3E8FF),
      iconColor: const Color(0xFF9333EA),
      borderColor: const Color(0xFFE9D5FF),
    ),
    Exercise(
      name: 'Deadlift',
      category: 'Full Body',
      duration: '3 sets × 10 reps',
      difficulty: 'Intermediate',
      badge: 'Patient-Safe',
      color: const Color(0xFFCFFAFE),
      iconColor: const Color(0xFF06B6D4),
      borderColor: const Color(0xFFA5F3FC),
    ),
    Exercise(
      name: 'Shoulder Press',
      category: 'Upper Body',
      duration: '3 sets × 12 reps',
      difficulty: 'Beginner',
      badge: 'Patient-Safe',
      color: const Color(0xFFD1FAE5),
      iconColor: const Color(0xFF10B981),
      borderColor: const Color(0xFFA7F3D0),
    ),
    Exercise(
      name: 'Bridge',
      category: 'Lower Back',
      duration: '3 sets × 15 reps',
      difficulty: 'Beginner',
      badge: 'Rehab Focus',
      color: const Color(0xFFDCFCE7),
      iconColor: const Color(0xFF16A34A),
      borderColor: const Color(0xFFBBF7D0),
    ),
  ];

  // Navigation handled by BottomNav widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '11:39',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exercise Library',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Patient-safe movements with real-time AI guidance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Exercise List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildExerciseCard(exercise),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(
        currentIndex: 1,
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.liveSession),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: exercise.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: exercise.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: exercise.iconColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: exercise.iconColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: exercise.difficulty == 'Beginner'
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: exercise.difficulty == 'Beginner'
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                        child: Text(
                          exercise.difficulty,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: exercise.difficulty == 'Beginner'
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.category,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.track_changes_rounded,
                              size: 14,
                              color: Color(0xFF4F46E5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              exercise.duration,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Text(
                          exercise.badge,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
