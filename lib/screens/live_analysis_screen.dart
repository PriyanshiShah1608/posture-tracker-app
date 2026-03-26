import 'package:flutter/material.dart';

class LiveAnalysisScreen extends StatelessWidget {
  const LiveAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera View Placeholder
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade900,
                  Colors.grey.shade800,
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person_outline_rounded,
                size: 200,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),

          // AI Skeleton Overlay
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: SkeletonPainter(),
          ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.black87,
                            size: 24,
                          ),
                        ),
                      ),
                      // Confidence Score
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Confidence',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '94%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                value: 0.94,
                                strokeWidth: 3,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Metrics Panel
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Squat',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF16A34A)),
                              ),
                              child: const Text(
                                'Good Form',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'Reps',
                                '8',
                                '/ 12',
                                const Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                'Sets',
                                '2',
                                '/ 3',
                                const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                'Form',
                                '92',
                                '%',
                                const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bottom Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/feedback'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Complete Set',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Pause',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String suffix, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                suffix,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    
    // Head
    canvas.drawCircle(Offset(center.dx, center.dy - 80), 20, paint);
    
    // Spine
    canvas.drawLine(
      Offset(center.dx, center.dy - 60),
      Offset(center.dx, center.dy + 60),
      paint,
    );
    
    // Shoulders
    canvas.drawLine(
      Offset(center.dx - 50, center.dy - 40),
      Offset(center.dx + 50, center.dy - 40),
      paint,
    );
    
    // Left arm
    canvas.drawLine(
      Offset(center.dx - 50, center.dy - 40),
      Offset(center.dx - 70, center.dy + 10),
      paint,
    );
    
    // Right arm
    canvas.drawLine(
      Offset(center.dx + 50, center.dy - 40),
      Offset(center.dx + 70, center.dy + 10),
      paint,
    );
    
    // Hips
    canvas.drawLine(
      Offset(center.dx - 30, center.dy + 60),
      Offset(center.dx + 30, center.dy + 60),
      paint,
    );
    
    // Left leg
    canvas.drawLine(
      Offset(center.dx - 30, center.dy + 60),
      Offset(center.dx - 40, center.dy + 130),
      paint,
    );
    
    // Right leg
    canvas.drawLine(
      Offset(center.dx + 30, center.dy + 60),
      Offset(center.dx + 40, center.dy + 130),
      paint,
    );
    
    // Joint circles
    paint.style = PaintingStyle.fill;
    final joints = [
      Offset(center.dx - 50, center.dy - 40),
      Offset(center.dx + 50, center.dy - 40),
      Offset(center.dx - 70, center.dy + 10),
      Offset(center.dx + 70, center.dy + 10),
      Offset(center.dx - 30, center.dy + 60),
      Offset(center.dx + 30, center.dy + 60),
      Offset(center.dx - 40, center.dy + 130),
      Offset(center.dx + 40, center.dy + 130),
    ];
    
    for (final joint in joints) {
      canvas.drawCircle(joint, 5, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
