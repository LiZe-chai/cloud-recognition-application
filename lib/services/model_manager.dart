import 'cloud_detector.dart';
import 'cloud_type_classifier.dart';

class ModelManager {
  static final ModelManager instance = ModelManager._internal();

  late CloudTypeClassifier classifier;
  late CloudDetector detector;

  ModelManager._internal();

  Future<void> init() async {
    classifier = CloudTypeClassifier();
    detector = CloudDetector();

    await classifier.loadModel();
    await detector.loadModel();
  }
}