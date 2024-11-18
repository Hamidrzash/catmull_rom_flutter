import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: DrawPointsScreen(),
      ),
    );
  }
}

class DrawPointsScreen extends StatefulWidget {
  const DrawPointsScreen({super.key});

  @override
  _DrawPointsScreenState createState() => _DrawPointsScreenState();
}

class _DrawPointsScreenState extends State<DrawPointsScreen> {
  List<Offset> points = [];
  Timer? _timer;
  double radius = 0.0;
  double angle = 0.0;
  final double angleStep = pi / 36; // Step in radians (10 degrees)

  @override
  void initState() {
    super.initState();
    _startAddingCirclePoints();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAddingCirclePoints() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        radius += 0.5;
        // Calculate the x and y position for the current angle
        final centerX = MediaQuery.of(context).size.width / 2;
        final centerY = MediaQuery.of(context).size.height / 2;
        final x = centerX + radius * cos(angle);
        final y = centerY + radius * sin(angle);

        // Add the calculated point to the points list
        points.add(Offset(x, y));

        // Increment the angle
        angle += 11;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          points.add(details.localPosition);
        });
      },
      child: Container(
        color: Colors.black,
        child: CustomPaint(
          painter: PointsPainter(points),
          child: Container(),
        ),
      ),
    );
  }
}

class PointsPainter extends CustomPainter {
  final List<Offset> points;

  PointsPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final elapsedTime = points.length * 20;
    int r = (155 + 100 * sin(0.0005 * elapsedTime)).toInt();
    int g = (155 + 100 * sin(0.0003 * elapsedTime + 2)).toInt();
    int b = (155 + 100 * sin(0.0007 * elapsedTime + 4)).toInt();

    final paint = Paint()
      ..color = Color.fromARGB(255, r, g, b)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    // Draw circles at each point
    // for (final point in points) {
    //   canvas.drawCircle(point, 2.0, paint);
    // }

    // Draw lines between consecutive points
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
