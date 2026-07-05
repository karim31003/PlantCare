import 'dart:io';

class Plant {
  final String id;
  final String userId;
  final String name;
  final String? species;
  final String? imageUrl;
  final DateTime lastWatered;
  final int wateringFrequencyDays;
  final String healthStatus;
  final DateTime createdAt;

  Plant({
    required this.id,
    required this.userId,
    required this.name,
    this.species,
    this.imageUrl,
    required this.lastWatered,
    this.wateringFrequencyDays = 7,
    this.healthStatus = 'Healthy',
    required this.createdAt,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      species: json['species'],
      imageUrl: json['image_url'],
      lastWatered: DateTime.parse(json['last_watered']),
      wateringFrequencyDays: json['watering_frequency_days'] ?? 7,
      healthStatus: json['health_status'] ?? 'Healthy',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'image_url': imageUrl,
      'last_watered': lastWatered.toIso8601String(),
      'watering_frequency_days': wateringFrequencyDays,
      'health_status': healthStatus,
    };
  }
}

abstract class PlantRepository {
  Future<List<Plant>> getPlants();
  Future<void> addPlant(Plant plant, File? image);
  Future<void> updatePlant(Plant plant);
  Future<void> deletePlant(String id);
}
