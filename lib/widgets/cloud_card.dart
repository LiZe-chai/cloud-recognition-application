import 'package:cloud_recognition/pages/saved_result_page.dart';
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
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SavedResultPage(result: result),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.file(
                File(result.imagePath),
                height: h * 0.2,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Text section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: h * 0.01),

                  Text(
                    '${result.date.year}-${result.date.month}-${result.date.day} · $result.cloudType · ${(result.confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
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
