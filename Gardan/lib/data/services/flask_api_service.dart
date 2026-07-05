// lib/data/services/flask_api_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../core/config/app_config.dart';
import '../models/scan.dart';
import 'supabase_service.dart';

class FlaskApiService {
  FlaskApiService._();

  static String get _baseUrl => AppConfig.flaskBaseUrl;

  static Future<Scan> analyzeImage(File imageFile, {String? plantId}) async {
    final uri = Uri.parse('$_baseUrl/predict');

    // Determine content type from file extension (default to jpeg)
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mimeSubtype = ext == 'png' ? 'png' : 'jpeg';

    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', mimeSubtype),
      ),
    );

    final streamedResponse = await request.send().timeout(
          const Duration(seconds: 60),
          onTimeout: () => throw 'Request timed out. Please check your connection and try again.',
        );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw _extractErrorMessage(
        response.body,
        fallback: 'Analysis failed: ${response.statusCode}',
      );
    }

    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw 'Unexpected response from analysis server.';
    }

    // Check if the API reported success
    if (json['success'] != true) {
      throw json['message'] ?? 'No plant detected in the image';
    }

    // Extract the first (highest-confidence) detection from the list
    final detections = json['detections'];
    if (detections is! List || detections.isEmpty) {
      throw 'No plant detected in the image';
    }

    final detection = detections.first as Map<String, dynamic>;
    final plantType = detection['plant_type'] ?? 'Unknown';
    final diseaseName = detection['disease'] ?? 'Unknown';
    final confidence = detection['disease_confidence'] != null
        ? (detection['disease_confidence'] as num).toDouble()
        : null;

    return Scan(
      id: '',
      userId: SupabaseService.currentUserId ?? '',
      plantId: plantId,
      diseaseName: '$plantType - $diseaseName',
      treatmentSuggestion: _getTreatmentSuggestion(diseaseName),
      confidence: confidence,
    );
  }

  static String _extractErrorMessage(String body, {required String fallback}) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Ignore parse failures and use the fallback message.
    }

    return fallback;
  }

  /// Returns a basic treatment suggestion based on the detected disease name.
  static String _getTreatmentSuggestion(String diseaseName) {
    final lower = diseaseName.toLowerCase();

    if (lower.contains('healthy') || lower.contains('fresh')) {
      return 'Your plant looks healthy! Keep up the good care.';
    } else if (lower.contains('anthracnose')) {
      return 'Remove infected parts, apply copper-based fungicide, and avoid overhead watering.';
    } else if (lower.contains('bacterial')) {
      return 'Remove affected leaves, apply copper spray, and ensure good air circulation.';
    } else if (lower.contains('blight')) {
      return 'Remove infected foliage, apply fungicide, and rotate crops next season.';
    } else if (lower.contains('canker')) {
      return 'Prune infected branches, apply copper-based treatment, and sterilize tools.';
    } else if (lower.contains('mildew')) {
      return 'Apply neem oil or sulfur-based fungicide. Improve air circulation around the plant.';
    } else if (lower.contains('rust')) {
      return 'Remove affected leaves, apply fungicide, and avoid wetting foliage during watering.';
    } else if (lower.contains('rot')) {
      return 'Improve drainage, reduce watering, and apply appropriate fungicide.';
    } else if (lower.contains('virus') || lower.contains('curl')) {
      return 'Remove infected plants to prevent spread. Control insect vectors like whiteflies.';
    } else if (lower.contains('mould') || lower.contains('mold')) {
      return 'Wash leaves with soapy water. Control aphids and other honeydew-producing insects.';
    } else if (lower.contains('mites') || lower.contains('spider')) {
      return 'Spray with neem oil or insecticidal soap. Increase humidity around the plant.';
    } else if (lower.contains('weevil')) {
      return 'Remove affected fruits, use pheromone traps, and apply appropriate insecticide.';
    } else if (lower.contains('deficiency')) {
      return 'Test soil nutrients and apply balanced fertilizer. Ensure proper pH levels.';
    } else if (lower.contains('dry')) {
      return 'Increase watering frequency and check for root health. Ensure adequate mulching.';
    }

    return 'Consult a local agricultural expert for specific treatment recommendations.';
  }
}
