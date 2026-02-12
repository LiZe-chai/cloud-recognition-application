class InferenceResult {
  final int? id;
  final String imagePath;
  final String cloudType;
  final double confidence;
  final String createdAt;

  InferenceResult({
    this.id,
    required this.imagePath,
    required this.cloudType,
    required this.confidence,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "imagePath": imagePath,
      "cloudType": cloudType,
      "confidence": confidence,
      "createdAt": createdAt,
    };
  }

  factory InferenceResult.fromMap(Map<String, dynamic> json) {
    return InferenceResult(
      id: json["id"],
      imagePath: json["imagePath"],
      cloudType: json["cloudType"],
      confidence: json["confidence"],
      createdAt: json["createdAt"],
    );
  }
}
