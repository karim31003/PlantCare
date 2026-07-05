// lib/data/repositories/scans_repository.dart

import 'dart:io';

import '../models/scan.dart';
import '../services/flask_api_service.dart';
import '../services/scans_service.dart';

class ScansRepository {
  Future<List<Scan>> getScans() async {
    try {
      return await ScansService.getScans();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Scan>> getScansByPlant(String plantId) async {
    try {
      return await ScansService.getScansByPlant(plantId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Analyze image then save result ───────────────────────────────

  Future<Scan> analyzeAndSave(File imageFile, {String? plantId}) async {
    try {
      final scan = await FlaskApiService.analyzeImage(
        imageFile,
        plantId: plantId,
      );
      await ScansService.saveScan(scan);
      return scan;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteScan(String scanId) async {
    try {
      await ScansService.deleteScan(scanId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateScanPlant(String scanId, String? plantId) async {
    try {
      await ScansService.updateScanPlant(scanId, plantId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    final message = e.toString();

    if (message.contains('timed out')) {
      return 'Analysis timed out. Please check your connection and try again.';
    } else if (message.contains('network')) {
      return 'Network error. Check your connection.';
    } else if (message.contains('User not logged in')) {
      return 'Please sign in again before scanning.';
    } else if (message.contains('No plant detected in the image')) {
      return 'No plant detected in the image. Try a clearer leaf photo.';
    } else if (message.contains('Server error occurred during model inference')) {
      return message;
    } else if (message.contains('Analysis failed:')) {
      return message;
    } else if (message.contains('Unexpected response from analysis server')) {
      return message;
    } else if (message.contains('duplicate key')) {
      return 'This scan was already saved. Please try again.';
    } else if (message.startsWith('Exception:')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message.isNotEmpty
        ? message
        : 'Something went wrong with the scan. Please try again.';
  }
}
