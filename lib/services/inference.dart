import 'dart:math';

enum CloudType {
  cirrus,
  cumulus,
  stratus,
  cumulonimbus,
  altostratus,
}

class InferenceResult {
  final CloudType type;
  final double confidence;

  InferenceResult({
    required this.type,
    required this.confidence,
  });
}

Future<InferenceResult> fakeInferCloud() async {
  await Future.delayed(const Duration(seconds: 2));

  final rand = Random();
  final type = CloudType.values[rand.nextInt(CloudType.values.length)];
  final confidence = 0.7 + rand.nextDouble() * 0.3; // 70% - 100%

  return InferenceResult(
    type: type,
    confidence: double.parse(confidence.toStringAsFixed(2)),
  );
}

String cloudTypeToText(CloudType type) {
  switch (type) {
    case CloudType.cirrus:
      return 'Cirrus';
    case CloudType.cumulus:
      return 'Cumulus';
    case CloudType.stratus:
      return 'Stratus';
    case CloudType.cumulonimbus:
      return 'Cumulonimbus';
    case CloudType.altostratus:
      return 'Altostratus';
  }
}
