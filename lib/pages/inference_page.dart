import 'dart:io';
import 'dart:typed_data';
import 'package:asset_delivery/asset_delivery.dart';
import 'package:cloud_recognition/pages/preview_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../generated/l10n.dart';
import '../services/cloud_detector.dart';
import '../services/cloud_type_classifier.dart';

class InferencePage extends StatefulWidget {
  final String tempImagePath;

  const InferencePage({super.key, required this.tempImagePath});

  @override
  State<InferencePage> createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
  late Uint8List detectorModelBytes;
  late Uint8List classifierModelBytes;


  @override
  void initState() {
    super.initState();
    _startInference();
  }
  Future<void> _startInference() async {
    await initModels();
    await _runInference();
  }
  Future<bool> initModels({bool useLocalAssets = true}) async {
    try {
      const detectorName = 'TL_MACNN_cloud_detection.tflite';
      const classifierName = 'TL_mobilenetv2_cloud_classification_multilabel.tflite';

      Uint8List detectorBytes;
      Uint8List classifierBytes;

      if (useLocalAssets) {
        print('Loading models from LOCAL assets...');

        final detectorData = await rootBundle.load('assets/$detectorName');
        final classifierData = await rootBundle.load('assets/$classifierName');

        detectorBytes = detectorData.buffer.asUint8List();
        classifierBytes = classifierData.buffer.asUint8List();
      } else {
        print('Loading models from ASSET PACK...');

        const assetPackName = 'TFmodels';

        await AssetDelivery.fetch(assetPackName);

        final detectorPath = await AssetDelivery.getAssetPackPath(
          assetPackName: assetPackName,
          count: 1,
          namingPattern: 'TL_MACNN_cloud_detection',
          fileExtension: 'tflite',
        );

        final classifierPath = await AssetDelivery.getAssetPackPath(
          assetPackName: assetPackName,
          count: 1,
          namingPattern: 'TL_mobilenetv2_cloud_classification_multilabel',
          fileExtension: 'tflite',
        );
        print('detectorPath: $detectorPath');
        print('classifierPath: $classifierPath');

        if (detectorPath == null || classifierPath == null) {
          print('Could not find model paths in asset pack.');
          return false;
        }
        final detectorFile = File(
          '$detectorPath/TL_MACNN_cloud_detection.tflite',
        );

        final classifierFile = File(
          '$classifierPath/TL_mobilenetv2_cloud_classification_multilabel.tflite',
        );

        print('detector FULL path: ${detectorFile.path}');
        print('classifier FULL path: ${classifierFile.path}');
        print('detector exists: ${await detectorFile.exists()}');
        print('classifier exists: ${await classifierFile.exists()}');

        if (!await detectorFile.exists() || !await classifierFile.exists()) {
          print('Model file does not exist.');
          return false;
        }

        detectorBytes = await detectorFile.readAsBytes();
        classifierBytes = await classifierFile.readAsBytes();

        print('detector bytes: ${detectorBytes.length}');
        print('classifier bytes: ${classifierBytes.length}');
      }

      detectorModelBytes = detectorBytes;
      classifierModelBytes = classifierBytes;

      print('detector bytes: ${detectorModelBytes.length}');
      print('classifier bytes: ${classifierModelBytes.length}');

      if (detectorModelBytes.isEmpty || classifierModelBytes.isEmpty) {
        print('Model bytes are empty.');
        return false;
      }

      print('Models loaded successfully');
      return true;

    } catch (e, st) {
      print('Error loading models: $e');
      print(st);
      return false;
    }
  }

  Future<void> _runInference() async {

    final params = InferenceParams(
      imagePath: widget.tempImagePath,
      detectorModel: detectorModelBytes,
      classifierModel: classifierModelBytes,
    );

    final result = await compute(runInference, params);

    final rawContours = await CloudPostProcessor.processMask(
        result["mask"], 512, 512);

    final contours = (rawContours as List)
        .map((contour) => (contour as List)
        .map((p) => Map<String, int>.from(p))
        .toList())
        .toList();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewPage(
          tempImagePath: widget.tempImagePath,
          contours: contours,
          results: result["prob"],
          imageWidth: result["width"],
          imageHeight: result["height"],
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

class InferenceParams {
  final String imagePath;
  final Uint8List detectorModel;
  final Uint8List classifierModel;

  InferenceParams({
    required this.imagePath,
    required this.detectorModel,
    required this.classifierModel,
  });
}

Future<Map<String, dynamic>> runInference(InferenceParams params) async {

  final detectorInterpreter =
  Interpreter.fromBuffer(params.detectorModel);

  final classifierInterpreter =
  Interpreter.fromBuffer(params.classifierModel);

  final detector = CloudDetector(detectorInterpreter, true);
  final classifier = CloudTypeClassifier(classifierInterpreter);

  final file = File(params.imagePath);
  final bytes = await file.readAsBytes();

  final image = img.decodeImage(bytes)!;

  final mask = await detector.predict(image);

  final prob = classifier.predict(image);

  return {
    "mask": mask,
    "prob": prob,
    "width": image.width,
    "height": image.height
  };
}