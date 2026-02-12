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
  String cloudType;

  @HiveField(4)
  double confidence;

  PredictionModel({
    this.imagePath = '',
    this.name = '',
    DateTime? date,
    this.cloudType = '',
    this.confidence = 0.0,
  }) : date = date ?? DateTime.now();
}
