import 'dart:io';

import 'package:cloud_recognition/services/cloud_type_classifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;



void main() {
  test('Cloud Type Prediction Logic Test', () async {
    final classifier = CloudTypeClassifier();
    await classifier.loadModel();

    final file = File('assets/Ac-N004.jpg');
    final bytes = await file.readAsBytes();

    final testImage = img.decodeImage(bytes);

    final result = classifier.predict(testImage!);

    expect(result?.$1, 'Ac');
    expect(result?.$2, isA<num>());
  });
}
