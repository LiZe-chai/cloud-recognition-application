
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
class DetectionResult {
  final Map<String, int> box;
  final InferenceResult classification;

  DetectionResult({
    required this.box,
    required this.classification,
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
      CloudType.contrail: s.cloudTypeContrail
    }[this]!;
  }

  Color get color {
    switch (this) {
      case CloudType.cirrus:
        return const Color(0xFF7B1FA2);
      case CloudType.cirrostratus:
        return const Color(0xFF512DA8);
      case CloudType.cirrocumulus:
        return const Color(0xFF303F9F);
      case CloudType.altostratus:
        return const Color(0xFF00796B);
      case CloudType.altocumulus:
        return const Color(0xFF388E3C);
      case CloudType.stratus:
        return const Color(0xFF455A64);
      case CloudType.stratocumulus:
        return const Color(0xFF263238);
      case CloudType.cumulus:
        return const Color(0xFF0288D1);
      case CloudType.nimbostratus:
        return const Color(0xFF121212);
      case CloudType.cumulonimbus:
        return const Color(0xFFC2185B);
      case CloudType.contrail:
        return const Color(0xFFE65100);
    }
  }

  Color get borderColor => Colors.black.withOpacity(0.5);

  String description(BuildContext context) {
    final s = S.of(context)!;

    return {
      CloudType.cirrus: s.cloudDescCirrus,
      CloudType.cirrostratus: s.cloudDescCirrostratus,
      CloudType.cirrocumulus: s.cloudDescCirrocumulus,
      CloudType.altostratus: s.cloudDescAltostratus,
      CloudType.altocumulus: s.cloudDescAltocumulus,
      CloudType.stratus: s.cloudDescStratus,
      CloudType.stratocumulus: s.cloudDescStratocumulus,
      CloudType.nimbostratus: s.cloudDescNimbostratus,
      CloudType.cumulus: s.cloudDescCumulus,
      CloudType.cumulonimbus: s.cloudDescCumulonimbus,
      CloudType.contrail: s.cloudDescContrail
    }[this]!;
  }
  String get imageAsset {
    switch (this) {
      case CloudType.cirrus:
        return "assets/cirrus.jpg";
      case CloudType.cirrostratus:
        return "assets/cirrostratus.jpg";
      case CloudType.cirrocumulus:
        return "assets/cirrocumulus.jpg";
      case CloudType.altostratus:
        return "assets/altostratus.jpg";
      case CloudType.altocumulus:
        return "assets/altocumulus.jpg";
      case CloudType.stratus:
        return "assets/stratus.jpg";
      case CloudType.stratocumulus:
        return "assets/stratocumulus.jpg";
      case CloudType.nimbostratus:
        return "assets/nimbostratus.jpg";
      case CloudType.cumulus:
        return "assets/cumulus.jpg";
      case CloudType.cumulonimbus:
        return "assets/cumulonimbus.jpg";
      case CloudType.contrail:
        return "assets/contrail.jpg";
    }
  }
}
