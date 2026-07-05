import '../models/plant.dart';
import '../services/plants_service.dart';

class PlantsRepository {
  Future<List<Plant>> getPlants() async {
    try {
      return await PlantsService.getPlants();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Plant?> getPlantById(String plantId) async {
    try {
      return await PlantsService.getPlantById(plantId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> addPlant(Plant plant) async {
    try {
      await PlantsService.addPlant(plant);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updatePlant(Plant plant) async {
    try {
      await PlantsService.updatePlant(plant);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markAsWatered(String plantId) async {
    try {
      await PlantsService.markAsWatered(plantId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePlant(String plantId) async {
    try {
      await PlantsService.deletePlant(plantId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ───────────────────────── FIX ─────────────────────────

  Exception _handleError(dynamic e) {
    print('REPOSITORY ERROR: $e');
    return Exception(e.toString());
  }
}