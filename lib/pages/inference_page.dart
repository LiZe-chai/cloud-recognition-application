import 'dart:io';

import 'package:cloud_recognition/pages/preview_page.dart';
import 'package:cloud_recognition/services/cloud_type_classifier.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../generated/l10n.dart';
import '/services/inference.dart';

class InferencePage extends StatefulWidget {
  final String tempImagePath;
  const InferencePage({super.key,required this.tempImagePath});

  @override
  State<InferencePage> createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
  final classifier = CloudTypeClassifier();
  @override
  void initState() {
    super.initState();
    classifier.loadModel();
    _runInference();
  }

  Future<void> _runInference() async {
    final file = File(widget.tempImagePath);
    final bytes = await file.readAsBytes();
    final inputImage = img.decodeImage(bytes);
    final result = await InferCloud(classifier,inputImage!);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewPage(result: result, tempImagePath: widget.tempImagePath,),
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
