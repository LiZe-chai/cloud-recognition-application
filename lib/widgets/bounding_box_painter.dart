import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/inference.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> results;
  final BuildContext context;

  BoundingBoxPainter(this.results, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < results.length; i++) {
      final detection = results[i];
      final box = detection.box;

      final cloudColor = detection.classification.type.color;

      final paint = Paint()
        ..color = cloudColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final rect = Rect.fromLTWH(
        box["x"]!.toDouble(),
        box["y"]!.toDouble(),
        box["width"]!.toDouble(),
        box["height"]!.toDouble(),
      );

      canvas.drawRect(rect, paint);

      final circlePaint = Paint()
        ..color = cloudColor;

      final circleRadius = 14.0;

      final circleCenter = Offset(
        rect.left + circleRadius,
        rect.top + circleRadius,
      );

      canvas.drawCircle(circleCenter, circleRadius, circlePaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: "${i + 1}",
          style: TextStyle(
            color: Colors.white,
            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          circleCenter.dx - textPainter.width / 2,
          circleCenter.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}