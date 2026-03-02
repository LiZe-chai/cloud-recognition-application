import 'dart:io';
import 'dart:math';

import 'package:cloud_recognition/pages/preview_page.dart';
import 'package:cloud_recognition/services/cloud_type_classifier.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../generated/l10n.dart';
import '../services/cloud_detector.dart';
import '../services/model_manager.dart';
import '/services/inference.dart';

class InferencePage extends StatefulWidget {
  final String tempImagePath;
  const InferencePage({super.key,required this.tempImagePath});

  @override
  State<InferencePage> createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
  final classifier = ModelManager.instance.classifier;
  final detector = ModelManager.instance.detector;

  @override
  void initState() {
    super.initState();
    _runInference();

  }

  Future<void> _runInference() async {
    final file = File(widget.tempImagePath);
    final bytes = await file.readAsBytes();
    final inputImage = img.decodeImage(bytes);


    final mask = await detector.predict(inputImage!);
    final boxes = await CloudPostProcessor.processMask(mask!, 512, 512,);
    List<DetectionResult> results = [];
    for (var box in boxes) {
      final map = Map<String, dynamic>.from(box);

      int x = map['x'];
      int y = map['y'];
      int w = map['w'];
      int h = map['h'];

      double scaleX = inputImage.width / 512;
      double scaleY = inputImage.height / 512;

      int realX = (x * scaleX).toInt();
      int realY = (y * scaleY).toInt();
      int realW = (w * scaleX).toInt();
      int realH = (h * scaleY).toInt();

      realX = max(0, realX);
      realY = max(0, realY);
      realW = min(inputImage.width - realX, realW);
      realH = min(inputImage.height - realY, realH);

      final cropped = img.copyCrop(
        inputImage,
        x: realX,
        y: realY,
        width: realW,
        height: realH,
      );
      final classification = await InferCloud(classifier,cropped!);
      results.add(
        DetectionResult(
          box: map.cast<String, int>(),
          classification: classification,
        ),
      );
    }

    if (results.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("No Cloud Detected"),
          content: const Text(
            "Couldn't detect any clouds in this image.\n\n"
                "Try capturing more sky area or ensure the clouds are clearly visible.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Try Again"),
            ),
          ],
        ),
      );

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: w * 0.12,
              height: w * 0.12,
              child: const CircularProgressIndicator(
                strokeWidth: 8,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.of(context)!.identifyingCloudType,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
