import 'package:flutter/foundation.dart';

class Plant {
  final String id; // FIX: nullable because DB may generate it
  final String userId;

  final String name;
  final String? species;
  final String? imageUrl;
  final DateTime? lastWatered;
  final Duration wateringFrequency;
  final String healthStatus;
  final DateTime createdAt;

  final String? newImagePath;

  Plant({
    required this.id,
    required this.userId,
    required this.name,
    this.species,
    this.imageUrl,
    this.lastWatered,
    required this.wateringFrequency,
    required this.healthStatus,
    required this.createdAt,
    this.newImagePath,
  });

  // ───────────────────────── COPY WITH ─────────────────────────

  static const _keep = Object();

Plant copyWith({
  String? id,
  String? userId,
  String? name,
  String? species,
  String? imageUrl,
  DateTime? lastWatered,
  Duration? wateringFrequency,
  String? healthStatus,
  DateTime? createdAt,
  Object? newImagePath = _keep,   // <-- sentinel
}) {
  return Plant(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    species: species ?? this.species,
    imageUrl: imageUrl ?? this.imageUrl,
    lastWatered: lastWatered ?? this.lastWatered,
    wateringFrequency: wateringFrequency ?? this.wateringFrequency,
    healthStatus: healthStatus ?? this.healthStatus,
    createdAt: createdAt ?? this.createdAt,
    newImagePath: identical(newImagePath, _keep)
        ? this.newImagePath
        : newImagePath as String?,  // allows null to clear it
  );
}

  // ───────────────────────── FROM MAP ─────────────────────────

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      species: map['species'] as String?,
      imageUrl: map['image_url'] as String?,
      lastWatered: map['last_watered'] != null
          ? DateTime.parse(map['last_watered'])
          : null,
      wateringFrequency:
          Duration(days: (map['watering_frequency_days'] ?? 0) as int),
      healthStatus: map['health_status'] as String,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // ───────────────────────── TO MAP (INSERT) ─────────────────────────

Map<String, dynamic> toInsertMap() {
  return {
    'user_id': userId,
    'name': name,
    'species': species,
    'image_url': imageUrl,
    'last_watered': lastWatered?.toIso8601String(),
    'watering_frequency_days': wateringFrequency.inDays,
    'health_status': healthStatus,
    'created_at': createdAt.toIso8601String(),
  };
}

  // ───────────────────────── TO MAP (UPDATE) ─────────────────────────

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'species': species,
      'image_url': imageUrl,
      'last_watered': lastWatered?.toIso8601String(),
      'watering_frequency_days': wateringFrequency.inDays,
      'health_status': healthStatus,
    };
  }
}