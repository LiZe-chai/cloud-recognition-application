import 'dart:io';

import 'package:cloud_recognition/services/inference.dart';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../models/prediction_model.dart';
import 'camera_page.dart';

class SavedResultPage extends StatelessWidget {
  final PredictionModel result;

  const SavedResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 70),
                Container(
                  height: 260,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: Image.file(
                    File(result.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 24),

                // Prediction Result
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context)!.predictionResult,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context)!.name,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              result.name,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Divider(),
                            Text(
                              S.of(context)!.date,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${result.date.year}-${result.date.month}-${result.date.day}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Divider(),
                            Text(
                              S.of(context)!.predictedCloudType,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              cloudTypeToText(result.cloudType),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Divider(),
                            Text(
                              S.of(context)!.predictionConfidence,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${(result.confidence * 100).toStringAsFixed(1)}%'
                              ,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              top: 8,
              left: 8,
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
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E2E2E),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          color: Colors.white,
                          iconSize: 28,
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CameraPage(cameras: cameras),
                              ),
                            );
                          },
                        ),
                        Text(
                          S.of(context)!.newAction,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
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
}
