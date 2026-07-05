import 'package:flutter/material.dart';
import '../../data/models/plant.dart';
import '../../data/repositories/plants_repository.dart';

class PlantsProvider extends ChangeNotifier {
  final _repository = PlantsRepository();

  List<Plant> _plants = [];
  bool _isLoading = false;
  String? _error;

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ───────────────────────── FETCH ─────────────────────────

  Future<void> fetchPlants() async {
    _setLoading(true);
    _error = null;

    try {
      _plants = await _repository.getPlants();
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  // ───────────────────────── ADD ─────────────────────────

  Future<bool> addPlant(Plant plant) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.addPlant(plant);
      _plants.insert(0, plant);
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ───────────────────────── UPDATE ─────────────────────────

  Future<bool> updatePlant(Plant plant) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.updatePlant(plant);

      await fetchPlants();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ───────────────────────── WATER (OPTIMIZED) ─────────────────────────

  Future<bool> markAsWatered(String plantId) async {
    _error = null;

    try {
      await _repository.markAsWatered(plantId);

      // 🔥 LOCAL UPDATE (no full refresh)
      final index = _plants.indexWhere((p) => p.id == plantId);
      if (index != -1) {
        final plant = _plants[index];
        _plants[index] = plant.copyWith(
          lastWatered: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ───────────────────────── DELETE (OPTIMIZED) ─────────────────────────

  Future<bool> deletePlant(String plantId) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deletePlant(plantId);

      // 🔥 LOCAL REMOVE (no reload)
      _plants.removeWhere((p) => p.id == plantId);
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
