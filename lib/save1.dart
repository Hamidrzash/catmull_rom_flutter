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
  late List<Offset> points = [];

  void _addPoint(TapDownDetails details) {
    setState(() {
      points.add(details.localPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _addPoint,
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
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
