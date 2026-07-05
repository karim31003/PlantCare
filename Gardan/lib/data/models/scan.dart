class Scan {
  final String id;
  final String userId;
  final String? plantId;
  final String? imageUrl;
  final String diseaseName;
  final double? confidence;
  final String? treatmentSuggestion;
  final DateTime? createdAt;

  Scan({
    required this.id,
    required this.userId,
    this.plantId,
    this.imageUrl,
    required this.diseaseName,
    this.confidence,
    this.treatmentSuggestion,
    this.createdAt,
  });

  factory Scan.fromMap(Map<String, dynamic> map) => Scan(
        id: map['id'],
        userId: map['user_id'],
        plantId: map['plant_id'],
        imageUrl: map['image_url'],
        diseaseName: map['disease_name'],
        confidence: map['confidence'] != null
            ? (map['confidence'] as num).toDouble()
            : null,
        treatmentSuggestion: map['treatment_suggestion'],
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'])
            : null,
      );

 Map<String, dynamic> toMap() => {
  'user_id': userId,
  'plant_id': plantId,
  'image_url': imageUrl,
  'disease_name': diseaseName,
  'confidence': confidence,
  'treatment_suggestion': treatmentSuggestion,
};
}