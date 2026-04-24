import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

class CloudDetector {
  late Interpreter? _interpreter;
  bool _isInitialized = false;

  Future<List<List<List<List<double>>>>?> predict(
      img.Image imageInput) async {

    if (!_isInitialized || _interpreter == null) {
      print("Interpreter not initialized!");
      return null;
    }

    final input = imageToFloat32List(imageInput);

    final inputShape = [1, 300, 300, 3];
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
    img.copyResize(image, width: 300, height: 300);

    const int size = 300;
    final Float32List buffer =
    Float32List(size * size * 3);

    int index = 0;

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final pixel = resized.getPixel(x, y);

        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        buffer[index++] = r;
        buffer[index++] = g;
        buffer[index++] = b;
      }
    }

    return buffer;
  }

  void close() {
    _interpreter?.close();
  }

  CloudDetector(this._interpreter, this._isInitialized);
}
class CloudPostProcessor {
  static const MethodChannel _channel = MethodChannel('cloud_opencv');

  static Future<List<dynamic>> processMask(
      List<List<List<List<double>>>> mask4D,
      int width,
      int height) async {

    final Float32List maskFlat = _flattenMask(mask4D, width, height);

    final result = await _channel.invokeMethod('processMask', {
      "mask": maskFlat,
      "width": width,
      "height": height,
    });

    return result;
  }

  static Float32List _flattenMask(
      List<List<List<List<double>>>> mask4D,
      int targetWidth,
      int targetHeight) {

    final imageMask = mask4D[0];
    final int srcHeight = imageMask.length;
    final int srcWidth = imageMask[0].length;

    final flat = Float32List(targetWidth * targetHeight);

    int index = 0;

    for (int y = 0; y < targetHeight; y++) {
      for (int x = 0; x < targetWidth; x++) {
        final int srcY =
        (y * srcHeight / targetHeight).floor().clamp(0, srcHeight - 1);
        final int srcX =
        (x * srcWidth / targetWidth).floor().clamp(0, srcWidth - 1);

        flat[index++] = imageMask[srcY][srcX][0] > 0.5 ? 1.0 : 0.0;
      }
    }

    return flat;
  }
}
