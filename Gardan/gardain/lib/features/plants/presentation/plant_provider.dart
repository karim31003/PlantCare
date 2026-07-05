import 'dart:io';
import 'package:flutter/material.dart';
import '../domain/plant_repository.dart';
import '../data/supabase_plant_repository.dart';

class PlantProvider extends ChangeNotifier {
  final PlantRepository _repository = SupabasePlantRepository();
  List<Plant> _plants = [];
  bool _isLoading = false;

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;

  Future<void> fetchPlants() async {
    _isLoading = true;
    notifyListeners();
    try {
      _plants = await _repository.getPlants();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPlant(Plant plant, File? image) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.addPlant(plant, image);
      await fetchPlants();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePlant(Plant plant) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.updatePlant(plant);
      await fetchPlants();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePlant(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.deletePlant(id);
      await fetchPlants();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
