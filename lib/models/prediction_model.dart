import 'package:cloud_recognition/services/inference.dart';
import 'package:hive/hive.dart';
part 'prediction_model.g.dart';

@HiveType(typeId: 0)
class PredictionModel extends HiveObject {
  @HiveField(0)
  String imagePath;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  int imageWidth;

  @HiveField(4)
  int imageHeight;

  // Replaced single type/confidence with a list of detections
  @HiveField(5)
  List<CloudDetection> detections;

  PredictionModel({
    this.imagePath = '',
    this.name = '',
    DateTime? date,
    this.imageWidth=0,
    this.imageHeight=0,
    this.detections = const [], // Default to an empty list
  }) : date = date ?? DateTime.now();
}
@HiveType(typeId: 1) // Make sure this ID is unique across your app
class CloudDetection extends HiveObject {
  @HiveField(0)
  CloudType cloudType;

  @HiveField(1)
  double confidence;

  @HiveField(2)
  double xMin;

  @HiveField(3)
  double yMin;

  @HiveField(4)
  double width;

  @HiveField(5)
  double height;

  CloudDetection({
    required this.cloudType,
    required this.confidence,
    required this.xMin,
    required this.yMin,
    required this.width,
    required this.height,
  });
  DetectionResult toDetectionResult() {
    return DetectionResult(
      box: {
        "xMin": xMin.toInt(),
        "yMin": yMin.toInt(),
        "width": width.toInt(),
        "height": height.toInt(),
      },
      classification: InferenceResult(
        type: cloudType,
        confidence: confidence,
      ),
    );
  }
}
