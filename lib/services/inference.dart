import 'dart:math';

enum CloudType {
  cirrus,
  cirrostratus,
  cirrocumulus,
  altostratus,
  altocumulus,
  stratus,
  stratocumulus,
  nimbostratus,
  cumulus,
  cumulonimbus,
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

extension CloudTypeX on CloudType {
  String get label {
    switch (this) {
      case CloudType.cirrus:
        return 'Cirrus';
      case CloudType.cirrostratus:
        return 'Cirrostratus';
      case CloudType.cirrocumulus:
        return 'Cirrocumulus';
      case CloudType.altostratus:
        return 'Altostratus';
      case CloudType.altocumulus:
        return 'Altocumulus';
      case CloudType.stratus:
        return 'Stratus';
      case CloudType.stratocumulus:
        return 'Stratocumulus';
      case CloudType.nimbostratus:
        return 'Nimbostratus';
      case CloudType.cumulus:
        return 'Cumulus';
      case CloudType.cumulonimbus:
        return 'Cumulonimbus';
    }
  }
}

