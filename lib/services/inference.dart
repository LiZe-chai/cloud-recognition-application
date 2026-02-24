import 'dart:math';

import 'package:cloud_recognition/services/cloud_type_classifier.dart';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import 'package:image/image.dart' as img;

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
  contrail,
}


class InferenceResult {
  final CloudType type;
  final double confidence;

  InferenceResult({
    required this.type,
    required this.confidence,
  });
}

InferenceResult InferCloud(CloudTypeClassifier classifier, img.Image imageInput) {
  final result = classifier.predict(imageInput);

  return InferenceResult(
    type: result!.$1,
    confidence: result.$2,
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


