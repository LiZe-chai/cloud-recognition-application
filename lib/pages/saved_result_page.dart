import 'dart:io';

import 'package:cloud_recognition/services/inference.dart';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../models/prediction_model.dart';
import '../widgets/bounding_box_painter.dart';
import 'camera_page.dart';

class SavedResultPage extends StatelessWidget {
  final PredictionModel result;

  const SavedResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child:
          Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        color: Colors.grey[900],
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.file(
                                  File(result.imagePath),
                                  fit: BoxFit.contain,
                                ),
                                CustomPaint(
                                  size: Size(
                                    constraints.maxWidth,
                                    constraints.maxHeight,
                                  ),
                                  painter: BoundingBoxPainter(
                                    result.detections.map((d) => d.toDetectionResult()).toList(),
                                    result.imageWidth,
                                    result.imageHeight,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            '${S.of(context)!.predictionResult} (${result.detections.length})',
                            style: TextStyle(
                              fontSize:
                              Theme.of(context).textTheme.bodyLarge?.fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children:
                              result.detections.asMap().entries.map<Widget>((entry) {
                                int index = entry.key;
                                final detection = entry.value;
                                final cloudColor =
                                    detection.cloudType.color;
                                bool isLast = index == result.detections.length - 1;

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 26,
                                                height: 26,
                                                decoration: BoxDecoration(
                                                  color:
                                                  cloudColor.withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    color: cloudColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.fontSize,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                detection.cloudType
                                                    .label(context),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.fontSize,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '${(detection.confidence).toStringAsFixed(0)}%',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.fontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Stack(
                                            children: [
                                              Container(
                                                height: 6,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.black26,
                                                  borderRadius:
                                                  BorderRadius.circular(3),
                                                ),
                                              ),
                                              FractionallySizedBox(
                                                widthFactor: detection.confidence.clamp(0.0, 1.0),
                                                child: Container(
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: cloudColor,
                                                    borderRadius:
                                                    BorderRadius.circular(3),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isLast)
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.white.withOpacity(0.05),
                                        indent: 16,
                                        endIndent: 16,
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 28,
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E2E2E),
                  border: Border(
                      top: BorderSide(color: Colors.white10, width: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraPage(cameras: cameras),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt, color: Colors.white,
                              size: 28),
                          const SizedBox(height: 4),
                          Text(
                            S.of(context)!.newAction,
                            style: TextStyle(
                                color: Colors.white, fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleInfoTile(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: Colors.white54, fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(
              color: Colors.white, fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white12),
        ],
      ),
    );
  }
}
