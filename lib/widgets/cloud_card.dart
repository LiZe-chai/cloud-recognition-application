import 'package:cloud_recognition/pages/saved_result_page.dart';
import 'package:cloud_recognition/services/inference.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../models/prediction_model.dart';

class CloudCard extends StatelessWidget {
  final VoidCallback? onPressed;
  final PredictionModel result;

  const CloudCard({
    super.key,
    this.onPressed,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed ?? () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SavedResultPage(result: result)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.file(
                File(result.imagePath),
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        result.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${result.date.year}-${result.date.month}-${result.date.day}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: result.detections.map((detection) {
                      final themeColor = detection.cloudType.color;
                      final borderColor = detection.cloudType.borderColor;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              detection.cloudType.label(context),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const VerticalDivider(width: 10),
                            Text(
                              '${(detection.confidence).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
