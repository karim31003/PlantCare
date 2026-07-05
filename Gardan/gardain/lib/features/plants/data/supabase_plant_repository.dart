import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/plant_repository.dart';

class SupabasePlantRepository implements PlantRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<Plant>> getPlants() async {
    final response = await _client
        .from('plants')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => Plant.fromJson(json)).toList();
  }

  @override
  Future<void> addPlant(Plant plant, File? image) async {
    String? imageUrl;
    
    if (image != null) {
      final fileName = '${_client.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage.from('plants').upload(fileName, image);
      imageUrl = _client.storage.from('plants').getPublicUrl(fileName);
    }

    await _client.from('plants').insert({
      ...plant.toJson(),
      'user_id': _client.auth.currentUser!.id,
      'image_url': imageUrl ?? plant.imageUrl,
    });
  }

  @override
  Future<void> updatePlant(Plant plant) async {
    await _client
        .from('plants')
        .update(plant.toJson())
        .eq('id', plant.id);
  }

  @override
  Future<void> deletePlant(String id) async {
    await _client.from('plants').delete().eq('id', id);
  }
}
