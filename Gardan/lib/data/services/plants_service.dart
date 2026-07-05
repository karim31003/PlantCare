import 'dart:io';

import 'package:gardain/data/services/storage_service.dart';

import '../models/plant.dart';
import 'supabase_service.dart';

class PlantsService {
  PlantsService._();

  static final _client = SupabaseService.client;
  static const _table = 'plants';

  static Future<List<Plant>> getPlants() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => Plant.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Plant?> getPlantById(String plantId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', plantId)
        .maybeSingle();

    return response != null
        ? Plant.fromMap(response as Map<String, dynamic>)
        : null;
  }

  static Future<void> addPlant(Plant plant) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final data = plant.toInsertMap();
    data['user_id'] = userId;

    await _client.from(_table).insert(data);
  }

  static Future<void> updatePlant(Plant plant) async {
    if (plant.id == null || plant.id!.isEmpty) {
      throw Exception('Plant id is required for update');
    }

    String? imageUrl = plant.imageUrl;

    if (plant.newImagePath != null) {
      try {
        imageUrl = await StorageService.uploadPlantImage(
          File(plant.newImagePath!),
        );
      } catch (e) {
        throw Exception('Image upload failed: $e');
      }
    }

    final data = plant.toUpdateMap();
    data['image_url'] = imageUrl;

    await _client
        .from(_table)
        .update(data)
        .eq('id', plant.id!);
  }

  static Future<void> markAsWatered(String plantId) async {
    await _client.from(_table).update({
      'last_watered': DateTime.now().toIso8601String(),
    }).eq('id', plantId);
  }

  static Future<void> deletePlant(String plantId) async {
    await _client.from(_table).delete().eq('id', plantId);
  }
}