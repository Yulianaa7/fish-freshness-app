class InspectionModel {
  final int? id;
  final String fishName;
  final String? eyeImagePath;
  final String? gillImagePath;
  final String resultLabel;
  final double confidence;
  final bool isFresh;
  final String inspectedAt;

  InspectionModel({
    this.id,
    required this.fishName,
    this.eyeImagePath,
    this.gillImagePath,
    required this.resultLabel,
    required this.confidence,
    required this.isFresh,
    required this.inspectedAt,
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    return InspectionModel(
      id: json['id'],
      fishName: json['fish_name'] ?? 'Tidak diketahui',
      eyeImagePath: json['eye_image_path'],
      gillImagePath: json['gill_image_path'],
      resultLabel: json['result_label'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      isFresh: json['is_fresh'] == 1 || json['is_fresh'] == true,
      inspectedAt: json['inspected_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'fish_name': fishName,
        'eye_image_path': eyeImagePath,
        'gill_image_path': gillImagePath,
        'result_label': resultLabel,
        'confidence': confidence,
        'is_fresh': isFresh ? 1 : 0,
        'inspected_at': inspectedAt,
      };

  // Label yang ditampilkan ke user
  String get freshnessLabel {
    if (resultLabel.contains('fresh') && !resultLabel.contains('non')) {
      return 'Segar';
    }
    return 'Tidak Segar';
  }

  // Jenis bagian yang difoto
  String get partLabel {
    if (resultLabel.startsWith('eye')) return 'Mata Ikan';
    if (resultLabel.startsWith('gill')) return 'Insang Ikan';
    return 'Ikan';
  }
}