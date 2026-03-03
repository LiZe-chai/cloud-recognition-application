import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import 'inference.dart';

class CloudTypeClassifier {
  late Interpreter _interpreter;
  final List<CloudType> _cloudTypes
    = [CloudType.altocumulus,
      CloudType.altostratus,
      CloudType.cumulonimbus,
      CloudType.cirrocumulus,
      CloudType.cirrus,
      CloudType.cirrostratus,
      CloudType.cumulus,
      CloudType.nimbostratus,
      CloudType.stratocumulus,
      CloudType.stratus,
      CloudType.contrail];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/TL_mobilenetv2_cloud_classification.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  (CloudType, double)? predict(img.Image imageInput) {
    img.Image resizedImage = img.copyResize(imageInput, width: 224, height: 224);
    var input = imageToByteListFloat32(resizedImage, 224);

    var output = List<double>.filled(11, 0).reshape([1, 11]);

    _interpreter.run(input, output);

    print("Probabilities: $output");

    double maxProb = -1;
    int predIndex = -1;
    for (int i = 0; i < 11; i++) {
      if (output[0][i] > maxProb) {
        maxProb = output[0][i];
        predIndex = i;
      }
    }
    if (predIndex != -1 && predIndex < _cloudTypes.length) {
      CloudType type = _cloudTypes[predIndex];
      double confidence = maxProb * 100;

      return (type, confidence);
    } else {
      print("No valid category detected");
      return null;
    }
  }

  Uint8List imageToByteListFloat32(img.Image image, int inputSize) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {

        final pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r.toDouble();
        buffer[pixelIndex++] = pixel.g.toDouble();
        buffer[pixelIndex++] = pixel.b.toDouble();
      }
    }
    return convertedBytes.buffer.asUint8List();
  }
  void close() {
    _interpreter.close();
  }
}