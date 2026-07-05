// lib/data/services/storage_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  StorageService._();

  static final _client = SupabaseService.client;
  static const _bucket = 'plant-images';

  // ─── Upload plant image ───────────────────────────────────────────

  static Future<String> uploadPlantImage(File imageFile) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw 'User not logged in';

    final ext = imageFile.path.split('.').last.toLowerCase();
    final safeExt = (ext == 'png' || ext == 'jpg' || ext == 'jpeg') ? ext : 'jpg';
    final fileName =
        '$userId/${DateTime.now().millisecondsSinceEpoch}.$safeExt';
    final contentType = safeExt == 'png' ? 'image/png' : 'image/jpeg';

    await _client.storage
        .from(_bucket)
        .upload(
          fileName,
          imageFile,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw 'Image upload timed out. Please try again.',
        );

    return _client.storage.from(_bucket).getPublicUrl(fileName);
  }

  // ─── Delete plant image ───────────────────────────────────────────

  static Future<void> deletePlantImage(String imageUrl) async {
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;

    // Extract path after /object/public/plant-images/
    final bucketIndex = pathSegments.indexOf(_bucket);
    if (bucketIndex == -1) return;

    final filePath =
        pathSegments.sublist(bucketIndex + 1).join('/');

    await _client.storage.from(_bucket).remove([filePath]);
  }
}
