import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
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
  bool drawLines = true;
  bool drawPoints = true;
  bool closedLoop = false;

  @override
  void initState() {
    super.initState();
    curve = Curve(onUpdate: () => setState(() {}));
  }

  void _addPoint(TapDownDetails details) {
    setState(() {
      // points.add(Point(details.localPosition.dx, details.localPosition.dy, curve.update));
      curve.addPoint(details.localPosition.dx, details.localPosition.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
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
            painter: PointsPainter(curve, drawLines: drawLines, drawPoints: drawPoints, closedLoop: closedLoop),
            child: Container(),
          ),
        ),
      ),
      Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, top: 16),
          child: Material(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Draw Lines'),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: drawLines,
                        onChanged: (value) => setState(() {
                          drawLines = !drawLines;
                        }),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Draw Points'),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: drawPoints,
                        onChanged: (value) => setState(() {
                          drawPoints = !drawPoints;
                        }),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Closed loop'),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: closedLoop,
                        onChanged: (value) => setState(() {
                          closedLoop = !closedLoop;
                        }),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              curve.points.clear();
                            });
                          },
                          child: const Text('Clear')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

class PointsPainter extends CustomPainter {
  final Curve curve;
  final bool drawLines;
  final bool drawPoints;
  final bool closedLoop;

  PointsPainter(this.curve, {required this.drawPoints, required this.drawLines, required this.closedLoop});

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

    final linesPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    if (drawLines) {
      curve.drawLines(canvas, linesPaint);
    }
    curve.drawCurve(canvas, paint, closedLoop);
    if (drawPoints) {
      curve.drawCircles(canvas, circlePaint);
    }
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

  void drawCurve(Canvas canvas, Paint paint, bool closedLoop) {
    if (points.length < 2) return; // Need at least 4 points for a smooth curve
    List<Point> extendedPoints;
    // Extrapolate the first and last points
    if (closedLoop) {
      extendedPoints = [points[points.length - 1]] + points + [points[0]] + [points[1]];
    } else {
      final first = Point(2 * points[0].x - points[1].x, 2 * points[0].y - points[1].y, onUpdate);
      final last = Point(2 * points[points.length - 1].x - points[points.length - 2].x,
          2 * points[points.length - 1].y - points[points.length - 2].y, onUpdate);

      extendedPoints = [first] + points + [last];
    }

    // Draw the curve using the extended points
    for (int i = 0; i < extendedPoints.length - 3; i++) {
      final p0 = extendedPoints[i];
      final p1 = extendedPoints[i + 1];
      final p2 = extendedPoints[i + 2];
      final p3 = extendedPoints[i + 3];

      _drawCatmullRomCurve(canvas, paint, p0, p1, p2, p3);
    }
  }

  void _drawCatmullRomCurve(Canvas canvas, Paint paint, Point p0, Point p1, Point p2, Point p3,
      {double alpha = 0.5, double tension = 0.0}) {
    const step = 0.01; // How detailed the curve is
    const amount = 600; // Number of steps

    // Calculate the distances and time parameters
    double t0 = 0.0;
    double t1 = t0 + pow(distance(p0, p1), alpha);
    double t2 = t1 + pow(distance(p1, p2), alpha);
    double t3 = t2 + pow(distance(p2, p3), alpha);

    // Calculate m1 and m2 for the tangents
    final double t01 = pow(distance(p0, p1), alpha).toDouble();
    final double t12 = pow(distance(p1, p2), alpha).toDouble();
    final double t23 = pow(distance(p2, p3), alpha).toDouble();

    final m1 = Offset(
      (1.0 - tension) * (p2.x - p1.x + t12 * ((p1.x - p0.x) / t01 - (p2.x - p0.x) / (t01 + t12))),
      (1.0 - tension) * (p2.y - p1.y + t12 * ((p1.y - p0.y) / t01 - (p2.y - p0.y) / (t01 + t12))),
    );

    final m2 = Offset(
      (1.0 - tension) * (p2.x - p1.x + t12 * ((p3.x - p2.x) / t23 - (p3.x - p1.x) / (t12 + t23))),
      (1.0 - tension) * (p2.y - p1.y + t12 * ((p3.y - p2.y) / t23 - (p3.y - p1.y) / (t12 + t23))),
    );

    // Segment coefficients
    final a = Offset(2 * (p1.x - p2.x) + m1.dx + m2.dx, 2 * (p1.y - p2.y) + m1.dy + m2.dy);
    final b = Offset(-3 * (p1.x - p2.x) - m1.dx - m1.dx - m2.dx, -3 * (p1.y - p2.y) - m1.dy - m1.dy - m2.dy);
    final c = m1;
    final d = Offset(p1.x, p1.y);

    // Draw the curve
    for (int i = 0; i < amount; i++) {
      final t = i / amount;

      // Calculate the position on the curve
      final x = a.dx * t * t * t + b.dx * t * t + c.dx * t + d.dx;
      final y = a.dy * t * t * t + b.dy * t * t + c.dy * t + d.dy;

      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

// Helper function to calculate the distance between two points
  double distance(Point p1, Point p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
  }
}
