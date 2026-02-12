import 'dart:math';

import 'package:flutter/material.dart';

import '../generated/l10n.dart';

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
  String label(BuildContext context) {
    final s = S.of(context)!;

    return {
      CloudType.cirrus: s.cloudTypeCirrus,
      CloudType.cirrostratus: s.cloudTypeCirrostratus,
      CloudType.cirrocumulus: s.cloudTypeCirrocumulus,
      CloudType.altostratus: s.cloudTypeAltostratus,
      CloudType.altocumulus: s.cloudTypeAltocumulus,
      CloudType.stratus: s.cloudTypeStratus,
      CloudType.stratocumulus: s.cloudTypeStratocumulus,
      CloudType.nimbostratus: s.cloudTypeNimbostratus,
      CloudType.cumulus: s.cloudTypeCumulus,
      CloudType.cumulonimbus: s.cloudTypeCumulonimbus,
    }[this]!;
  }
}


