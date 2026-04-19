import 'dart:math';
import 'package:flutter/material.dart';

class ContourPainter extends CustomPainter {
  final List<List<Map<String, int>>> contours;
  final int imageWidth;
  final int imageHeight;

  ContourPainter(
      this.contours,
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

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final contour in contours) {
      if (contour.isEmpty) continue;

      final path = Path();

      for (int j = 0; j < contour.length; j++) {
        final p = contour[j];

        final x = dx + p["x"]! * scale;
        final y = dy + p["y"]! * scale;

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}