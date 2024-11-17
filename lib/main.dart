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
  late List<Point> points = [];
  late Curve curve;

  @override
  void initState() {
    super.initState();
    curve = Curve(onUpdate: () => setState(() {}));
  }

  void _addPoint(TapDownDetails details) {
    setState(() {
      points.add(Point(details.localPosition.dx, details.localPosition.dy, curve.update));
      curve.addPoint(details.localPosition.dx, details.localPosition.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _addPoint,
      onPanUpdate: (details) {
        if (curve.dragging) {
          curve.updatePoint(details.localPosition.dx, details.localPosition.dy);
        }
      },
      onPanEnd: (_) {
        curve.endDrag();
      },
      child: Container(
        color: Colors.black,
        child: CustomPaint(
          painter: PointsPainter(curve),
          child: Container(),
        ),
      ),
    );
  }
}

class PointsPainter extends CustomPainter {
  final Curve curve;

  PointsPainter(this.curve);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;
    final circlePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    // curve.drawLines(canvas, paint);
    curve.drawCurve(canvas, paint);
    curve.drawCircles(canvas, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Point {
  double x, y;
  final Function onUpdate;
  bool isDragging = false;

  Point(this.x, this.y, this.onUpdate);

  void startDrag() {
    isDragging = true;
  }

  void endDrag() {
    isDragging = false;
  }

  void updatePosition(Offset newPos) {
    x = newPos.dx;
    y = newPos.dy;
    onUpdate();
  }
}

class Curve {
  List<Point> points = [];
  bool dragging = false;
  final Function onUpdate;

  Curve({required this.onUpdate});

  void addPoint(double x, double y) {
    points.add(Point(x, y, onUpdate));
    onUpdate();
  }

  void update() {
    onUpdate();
  }

  void startDrag(Point point) {
    dragging = true;
    point.startDrag();
  }

  void endDrag() {
    dragging = false;
    for (var point in points) {
      point.endDrag();
    }
  }

  void updatePoint(double x, double y) {
    for (var point in points) {
      if (point.isDragging) {
        point.updatePosition(Offset(x, y));
      }
    }
  }

  void drawLines(Canvas canvas, Paint paint) {
    if (points.isEmpty) return;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(Offset(points[i].x, points[i].y), Offset(points[i + 1].x, points[i + 1].y), paint);
    }
  }

  void drawCircles(Canvas canvas, Paint paint) {
    // if (points.isEmpty) return;

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(Offset(points[i].x, points[i].y), 5, paint);
    }
  }

  void drawCurve(Canvas canvas, Paint paint) {
    if (points.length < 2) return; // Need at least 4 points for a smooth curve

    // Extrapolate the first and last points
    final first = Point(2 * points[0].x - points[1].x, 2 * points[0].y - points[1].y, onUpdate);
    final last = Point(2 * points[points.length - 1].x - points[points.length - 2].x,
        2 * points[points.length - 1].y - points[points.length - 2].y, onUpdate);

    final extendedPoints = [first] + points + [last];

    // Draw the curve using the extended points
    for (int i = 0; i < extendedPoints.length - 3; i++) {
      final p0 = extendedPoints[i];
      final p1 = extendedPoints[i + 1];
      final p2 = extendedPoints[i + 2];
      final p3 = extendedPoints[i + 3];

      _drawCatmullRomCurve(canvas, paint, p0, p1, p2, p3);
    }
  }

  void _drawCatmullRomCurve(Canvas canvas, Paint paint, Point p0, Point p1, Point p2, Point p3) {
    const step = 0.01; // How detailed the curve is
    const amount = 600; // Number of steps

    for (int i = 0; i < amount; i++) {
      final t = i / amount;

      // Catmull-Rom spline equation
      final x = 0.5 *
          ((2 * p1.x) +
              (-p0.x + p2.x) * t +
              (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * t * t +
              (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * t * t * t);

      final y = 0.5 *
          ((2 * p1.y) +
              (-p0.y + p2.y) * t +
              (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t * t +
              (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t * t * t);

      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }
}
