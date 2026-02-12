import 'package:cloud_recognition/pages/preview_page.dart';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '/services/inference.dart';

class InferencePage extends StatefulWidget {
  final String tempImagePath;
  const InferencePage({super.key,required this.tempImagePath});

  @override
  State<InferencePage> createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
  @override
  void initState() {
    super.initState();
    _runInference();
  }

  Future<void> _runInference() async {
    final result = await fakeInferCloud();

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
