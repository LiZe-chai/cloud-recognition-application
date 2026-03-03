import 'dart:io';
import 'package:cloud_recognition/pages/preview_page.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../generated/l10n.dart';
import '../services/cloud_detector.dart';
import '../services/model_manager.dart';
import '/services/inference.dart';

class InferencePage extends StatefulWidget {
  final String tempImagePath;

  const InferencePage({super.key, required this.tempImagePath});

  @override
  State<InferencePage> createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
  final classifier = ModelManager.instance.classifier;
  final detector = ModelManager.instance.detector;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runInference();
    });
  }

  Future<void> _runInference() async {
    final file = File(widget.tempImagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;
    final imageWidth = image.width;
    final imageHeight = image.height;

    final mask = await detector.predict(image);
    final boxes = await CloudPostProcessor.processMask(mask!, 512, 512);

    List<DetectionResult> results = [];

    for (var box in boxes) {
      final x = box['x'];
      final y = box['y'];
      final w = box['w'];
      final h = box['h'];

      final cropped = img.copyCrop(
        image,
        x: x,
        y: y,
        width: w,
        height: h,
      );

      final classification =
      InferCloud(classifier, cropped!);

      results.add(
        DetectionResult(
          box: {
            "x": x,
            "y": y,
            "w": w,
            "h": h,
          },
          classification: classification,
        ),
      );
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewPage(
          tempImagePath: widget.tempImagePath,
          results: results,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
        ),
      ),
    );
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