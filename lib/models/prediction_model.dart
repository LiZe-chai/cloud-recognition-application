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

  @HiveField(5)
  List<List<Map<String,int>>> contours;

  @HiveField(6)
  List<double> probabilities;

  PredictionModel({
    this.imagePath = '',
    this.name = '',
    DateTime? date,
    this.imageWidth = 0,
    this.imageHeight = 0,
    this.contours = const [],
    this.probabilities = const [],
  }) : date = date ?? DateTime.now();
}