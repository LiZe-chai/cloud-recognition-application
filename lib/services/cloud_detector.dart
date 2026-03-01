import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:image/image.dart' as img;

class CloudDetector {
  OrtSession? _session;
  bool _isInitialized = false;

  Future<void> loadModel() async {
    if (_isInitialized) return;

    try {
      OrtEnv.instance.init();

      final modelData =
      await rootBundle.load('assets/cloud_detection_model.onnx');
      final modelBytes = modelData.buffer.asUint8List();

      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromBuffer(modelBytes, sessionOptions);

      _isInitialized = true;
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<List<List<List<List<double>>>>?> predict(
      img.Image imageInput) async {

    if (!_isInitialized || _session == null) {
      print("Session not initialized!");
      return null;
    }

    final data = imageToFloat32List(imageInput);
    final shape = [1, 3, 512, 512];

    final inputOrt =
    OrtValueTensor.createTensorWithDataList(data, shape);

    final inputs = {'input': inputOrt};
    final runOptions = OrtRunOptions();

    List<OrtValue?>? outputs;

    try {
      outputs = await _session!.runAsync(runOptions, inputs);

      if (outputs == null || outputs.isEmpty) {
        print("No outputs");
        return null;
      }

      final outputData = outputs[0]?.value;

      print("Output type: ${outputData.runtimeType}");

      if (outputData is List) {
        return outputData
        as List<List<List<List<double>>>>;
      }

      print("Unexpected output type");
      return null;

    } finally {
      inputOrt.release();
      runOptions.release();

      for (var element in outputs ?? []) {
        element?.release();
      }
    }
  }
  Float32List imageToFloat32List(img.Image image) {
    img.Image resizedImage =
    img.copyResize(image, width: 512, height: 512);

    const int size = 512;
    final int pixelCount = size * size;
    final floatBuffer = Float32List(3 * pixelCount);

    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final pixel = resizedImage.getPixel(x, y);
        final int index = y * size + x;

        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        floatBuffer[index] =
            (r - mean[0]) / std[0];

        floatBuffer[index + pixelCount] =
            (g - mean[1]) / std[1];

        floatBuffer[index + 2 * pixelCount] =
            (b - mean[2]) / std[2];
      }
    }

    return floatBuffer;
  }

  void dispose() {
    _session?.release();
    _session = null;
    _isInitialized = false;
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
    final channel = mask4D[0][0];

    int index = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        flat[index++] =
        channel[y][x] > 0.5 ? 1.0 : 0.0;
      }
    }

    return flat;
  }
}