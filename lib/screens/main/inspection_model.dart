class InspectionModel {
  final int? id;
  final String fishName;
  final double confidence;
  final String freshnessLabel;
  final bool isFresh;
  final String partLabel;
  final String? eyeImagePath;
  final String? gillImagePath;
  final String inspectedAt;

  InspectionModel({
    this.id,
    required this.fishName,
    required this.confidence,
    required this.freshnessLabel,
    required this.isFresh,
    required this.partLabel,
    this.eyeImagePath,
    this.gillImagePath,
    required this.inspectedAt,
  });
}