
import 'package:cloud_recognition/services/cloud_type_classifier.dart';
import 'package:cloud_recognition/services/inference.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/src/image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Cloud type classifier model work properly', () async {
    late Uint8List classifierModelBytes;
    final classifierData = await rootBundle.load('assets/TL_mobilenetv2_cloud_classification_multilabel.tflite');
    classifierModelBytes = classifierData.buffer.asUint8List();
    final classifierInterpreter = Interpreter.fromBuffer(classifierModelBytes);
    final classifier = CloudTypeClassifier(classifierInterpreter);
    final randomImage = Uint8List(224 * 224 * 3);
    final prob = classifier.predict(randomImage as Image);
    expect(prob, isA<List>());
    expect(prob?.length, equals(11), reason: 'Model should return 11 cloud type probabilities');
  });

  test('Cloud type extension testing', () async {
    CloudType test = CloudType.cirrus;
    expect(test.color,isA<Color>());
    //expect(test.description,isA<>());
    expect(test.imageAsset,isA<String>());
  });
}