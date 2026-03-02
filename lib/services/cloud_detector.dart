import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

class CloudDetector {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  Future<void> loadModel() async {
    if (_isInitialized) return;

    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/TL_MACNN_cloud_detection.tflite',
      );

      _isInitialized = true;
      print("TFLite model loaded successfully");
    } catch (e) {
      print("Failed to load TFLite model: $e");
    }
  }

  Future<List<List<List<List<double>>>>?> predict(
      img.Image imageInput) async {

    if (!_isInitialized || _interpreter == null) {
      print("Interpreter not initialized!");
      return null;
    }

    final input = imageToFloat32List(imageInput);

    final inputShape = [1, 512, 512, 3];
    final outputShape = _interpreter!.getOutputTensor(0).shape;

    final output = List.generate(
      outputShape[0],
          (_) => List.generate(
        outputShape[1],
            (_) => List.generate(
          outputShape[2],
              (_) => List<double>.filled(outputShape[3], 0.0),
        ),
      ),
    );

    _interpreter!.run(
      input.reshape(inputShape),
      output,
    );

    return output;
  }

  Float32List imageToFloat32List(img.Image image) {
    img.Image resized =
    img.copyResize(image, width: 512, height: 512);

    const int size = 512;
    final Float32List buffer =
    Float32List(size * size * 3);

    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    int index = 0;

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final pixel = resized.getPixel(x, y);

        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        buffer[index++] = (r - mean[0]) / std[0];
        buffer[index++] = (g - mean[1]) / std[1];
        buffer[index++] = (b - mean[2]) / std[2];
      }
    }

    return buffer;
  }

  void close() {
    _interpreter?.close();
  }
}
class CloudPostProcessor {
  static const MethodChannel _channel = MethodChannel('cloud_opencv');

  static Future<List<dynamic>> processMask(
      List<List<List<List<double>>>> mask4D,
      int width,
      int height) async {

    final Float32List maskFlat =
    _flattenMask(mask4D, width, height);

    final result = await _channel.invokeMethod('processMask', {
      "mask": maskFlat,
      "width": width,
      "height": height,
    });

    return result;
  }

  static Float32List _flattenMask(
      List<List<List<List<double>>>> mask4D,
      int width,
      int height) {

    final flat = Float32List(width * height);

    final imageMask = mask4D[0];

    int index = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        flat[index++] =
        imageMask[y][x][0] > 0.5 ? 1.0 : 0.0;
      }
    }

    return flat;
  }
}