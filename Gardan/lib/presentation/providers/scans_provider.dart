// lib/presentation/providers/scans_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/scan.dart';
import '../../data/repositories/scans_repository.dart';

class ScansProvider extends ChangeNotifier {
  final _repository = ScansRepository();


  List<Scan> _scans = [];
  Scan? _latestScan;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  String? _error;

  List<Scan> get scans => _scans;
  Scan? get latestScan => _latestScan;
  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchScans() async {
    _setLoading(true);
    _error = null;
    try {
      _scans = await _repository.getScans();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchScansByPlant(String plantId) async {
    _setLoading(true);
    _error = null;
    try {
      _scans = await _repository.getScansByPlant(plantId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ─── Analyze image + save + update latest ─────────────────────────

  Future<bool> analyzeImage(File imageFile, Object? object, {String? plantId}) async {
    _isAnalyzing = true;
    _error = null;
    notifyListeners();
    try {
      _latestScan = await _repository.analyzeAndSave(
        imageFile,
        plantId: plantId,
      );
      await fetchScans();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<bool> deleteScan(String scanId) async {
    _error = null;
    try {
      await _repository.deleteScan(scanId);
      await fetchScans();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateScanPlant(String scanId, String? plantId) async {
    _error = null;
    try {
      await _repository.updateScanPlant(scanId, plantId);
      await fetchScans();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
