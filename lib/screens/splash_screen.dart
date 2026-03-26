import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: MedicalCrossPainter(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Posturely',
              style: TextStyle(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.w300,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'AI-Powered Posture Care',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalCrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.fill;

    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, size.height * 0.2, size.width * 0.3, size.height * 0.6),
        const Radius.circular(4),
      ),
      paint,
    );

    // Horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.35, size.width * 0.6, size.height * 0.3),
        const Radius.circular(4),
      ),
      paint,
    );

    // Center circle
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.08,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
