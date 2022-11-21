import 'dart:ui';
import 'package:flutter/material.dart';

class NNPainer extends StatefulWidget {
  const NNPainer({super.key});

  @override
  State<NNPainer> createState() => _NNPainerState();
}

class _NNPainerState extends State<NNPainer> {
  List<DrawingPoints?> points = [];
  final StrokeCap strokeCap = StrokeCap.round;
  final double strokeWidth = 50.0;
  final Color drawColor = Colors.white;
  final bool isAntiAlias = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          GestureDetector(
            child: CustomPaint(
              size: Size.infinite,
              painter: DrawingPainter(pointsList: points),
            ),
            onPanUpdate: (details) {
              RenderObject? renderBox = context.findRenderObject();
              if (renderBox != null && renderBox is RenderBox) {
                points.add(
                  DrawingPoints(
                    points: renderBox.globalToLocal(details.globalPosition),
                    paint: Paint()
                      ..strokeCap = StrokeCap.round
                      ..isAntiAlias = isAntiAlias
                      ..color = drawColor
                      ..strokeWidth = strokeWidth,
                  ),
                );
                print(points.length);
              }
              setState(() {});
            },
            onPanStart: (details) {
              RenderObject? renderBox = context.findRenderObject();
              if (renderBox != null && renderBox is RenderBox) {
                points.add(
                  DrawingPoints(
                    points: renderBox.globalToLocal(details.globalPosition),
                    paint: Paint()
                      ..strokeCap = strokeCap
                      ..isAntiAlias = isAntiAlias
                      ..color = drawColor
                      ..strokeWidth = strokeWidth,
                  ),
                );
              }
              setState(() {});
            },
            onPanEnd: (details) {
              setState(() {
                points.add(null);
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                setState(() {
                  points = [];
                });
              },
              child: const Text("Clear"),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({
    required this.points,
    required this.paint,
  });
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({required this.pointsList});
  List<DrawingPoints?> pointsList;
  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(
          pointsList[i]!.points,
          pointsList[i + 1]!.points,
          pointsList[i]!.paint,
        );
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i]!.points);
        offsetPoints.add(
          Offset(
            pointsList[i]!.points.dx + 0.1,
            pointsList[i]!.points.dy + 0.1,
          ),
        );
        canvas.drawPoints(
          PointMode.points,
          offsetPoints,
          pointsList[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
