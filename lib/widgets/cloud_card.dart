import 'package:flutter/material.dart';

class CloudCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final DateTime date;
  final String cloudType;
  final double confidence;
  final VoidCallback? onPressed;

  const CloudCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.date,
    required this.cloudType,
    required this.confidence,
    this.onPressed,
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
          // TODO: handle card pressed
          debugPrint('CloudCard pressed');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                imagePath,
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
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: h * 0.01),

                  Text(
                    '${date.year}-${date.month}-${date.day} · $cloudType · ${(confidence * 100).toStringAsFixed(0)}%',
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
