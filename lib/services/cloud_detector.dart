import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:image/image.dart' as img;

class CloudDetector {
  OrtSession? _session;
  bool _isInitialized = false;

  void loadModel() async {
    if (_isInitialized) return;

    try {
      OrtEnv.instance.init();

      final modelData = await rootBundle.load(
          'assets/cloud_detection_model.onnx');
      final modelBytes = modelData.buffer.asUint8List();
      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromBuffer(modelBytes, sessionOptions);

      _isInitialized = true;
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<Float32List?> predict(img.Image imageInput) async {
    final data = imageToFloat32List(imageInput);

    final shape = [1, 3, 512, 512];
    final inputOrt = OrtValueTensor.createTensorWithDataList(data, shape);
    final inputs = {'input': inputOrt};
    final runOptions = OrtRunOptions();

    List<OrtValue?>? outputs;

    try {
      outputs = await _session?.runAsync(runOptions, inputs);

      if (outputs != null && outputs.isNotEmpty) {
        final outputData = outputs[0]?.value;
        if (outputData is Float32List) {
          return outputData;
        }
      }
    } catch (e) {
      print("Inference error: $e");
    } finally {
      inputOrt.release();
      runOptions.release();

      if (outputs != null) {
        for (var element in outputs) {
          element?.release();
        }
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
    const std  = [0.229, 0.224, 0.225];

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
  Uint8List thresholdMask(Float32List output) {
    const int size = 512;
    Uint8List mask = Uint8List(size * size);

    for (int i = 0; i < size * size; i++) {
      double v = output[i];
      mask[i] = v > 0.5 ? 1 : 0;
    }

    return mask;
  }
  List<BoundingBox> findConnectedComponents(Uint8List mask) {
    const int size = 512;
    List<BoundingBox> boxes = [];
    List<bool> visited = List.filled(size * size, false);

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        int idx = y * size + x;

        if (mask[idx] == 1 && !visited[idx]) {
          int minX = x, maxX = x;
          int minY = y, maxY = y;
          int area = 0;

          List<Point<int>> queue = [Point(x, y)];
          visited[idx] = true;

          while (queue.isNotEmpty) {
            Point<int> p = queue.removeLast();
            int cx = p.x;
            int cy = p.y;
            int cidx = cy * size + cx;

            area++;

            minX = min(minX, cx);
            maxX = max(maxX, cx);
            minY = min(minY, cy);
            maxY = max(maxY, cy);

            // 4-neighborhood
            List<Point<int>> neighbors = [
              Point(cx - 1, cy),
              Point(cx + 1, cy),
              Point(cx, cy - 1),
              Point(cx, cy + 1),
            ];

            for (var n in neighbors) {
              if (n.x >= 0 &&
                  n.x < size &&
                  n.y >= 0 &&
                  n.y < size) {
                int nidx = n.y * size + n.x;

                if (mask[nidx] == 1 && !visited[nidx]) {
                  visited[nidx] = true;
                  queue.add(n);
                }
              }
            }
          }

          if (area > 500) {
            boxes.add(BoundingBox(minX, minY, maxX, maxY, area));
          }
        }
      }
    }

    return boxes;
  }

  void dispose() {
    _session?.release();
    _isInitialized = false;
  }
}
class BoundingBox {
  int minX, minY, maxX, maxY;
  int area;

  BoundingBox(this.minX, this.minY, this.maxX, this.maxY, this.area);
}
