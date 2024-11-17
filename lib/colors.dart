import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: DrawPointsScreen(),
      ),
    );
  }
}

class DrawPointsScreen extends StatefulWidget {
  @override
  _DrawPointsScreenState createState() => _DrawPointsScreenState();
}

class _DrawPointsScreenState extends State<DrawPointsScreen> {
  double angle = 0.0;

  late List<Spline> points = [];

  void _addPoint(DragUpdateDetails details) {
    setState(() {
      points.add(Spline(details.localPosition));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTapDown: _addPoint,
      onPanUpdate: _addPoint,
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
  final List<Spline> points;
  // int elapsedTime;

  PointsPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final elapsedTime = points.length * 20;
    int r = (155 + 100 * sin(0.0005 * elapsedTime)).toInt();
    int g = (155 + 100 * sin(0.0003 * elapsedTime + 2)).toInt();
    int b = (155 + 100 * sin(0.0007 * elapsedTime + 4)).toInt();

    final paint = Paint()
      // ..color = Color.fromARGB(255, r, g, b)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;
    final color = Color.fromARGB(255, r, g, b);
    points.last.color = color;
    points[points.length - 1].color = color;
    points[points.length - 2].color = color;
    points[points.length - 3].color = color;
    // Draw circles at each point
    // for (final point in points) {
    //   canvas.drawCircle(point, 5.0, paint);
    // }

    // Draw lines between consecutive points
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i].offset, points[i + 1].offset, paint..color = points[i].color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Spline {
  final Offset offset;
  Color color;
  Spline(this.offset, {this.color = Colors.white});
}
