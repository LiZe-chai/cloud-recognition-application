import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CloudTypeClassifier {
  late  Interpreter _interpreter;

  Future<void> loadModel() async {
    try {
      final modelData = await rootBundle.load(
        'assets/TL_mobilenetv2_cloud_classification_multilabel.tflite',
      );

      final bytes = modelData.buffer.asUint8List();

      _interpreter = Interpreter.fromBuffer(bytes);

      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  List<double>? predict(img.Image imageInput) {
    img.Image resizedImage = img.copyResize(imageInput, width: 224, height: 224);
    var input = imageToByteListFloat32(resizedImage, 224);

    var output = List<double>.filled(11, 0).reshape([1, 11]);

    _interpreter.run(input, output);

    print("Probabilities: ${output[0]}");

    return output[0];
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

  CloudTypeClassifier(this._interpreter);
}