import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/inference.dart';

import 'dart:math';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> results;
  final int imageWidth;
  final int imageHeight;

  BoundingBoxPainter(
      this.results,
      this.imageWidth,
      this.imageHeight,
      );

  @override
  void paint(Canvas canvas, Size size) {
    if (imageWidth == 0 || imageHeight == 0) return;

    final scale = min(
      size.width / imageWidth,
      size.height / imageHeight,
    );

    final displayWidth = imageWidth * scale;
    final displayHeight = imageHeight * scale;

    final dx = (size.width - displayWidth) / 2;
    final dy = (size.height - displayHeight) / 2;

    for (int i = 0; i < results.length; i++) {
      final detection = results[i];
      final box = detection.box;

      final cloudColor = detection.classification.type.color;

      final paint = Paint()
        ..color = cloudColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final rect = Rect.fromLTWH(
        dx + box["x"]! * scale,
        dy + box["y"]! * scale,
        box["w"]! * scale,
        box["h"]! * scale,
      );

      canvas.drawRect(rect, paint);

      final circlePaint = Paint()..color = cloudColor;
      const circleRadius = 14.0;

      final circleCenter = Offset(
        rect.left + circleRadius,
        rect.top + circleRadius,
      );

      canvas.drawCircle(circleCenter, circleRadius, circlePaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: "${i + 1}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
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