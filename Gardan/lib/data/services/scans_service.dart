// lib/data/services/scans_service.dart

import '../models/scan.dart';
import 'supabase_service.dart';

class ScansService {
  ScansService._();

  static final _client = SupabaseService.client;
  static const _table = 'scans';

  static Future<List<Scan>> getScans() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw 'User not logged in';

    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Scan.fromMap(e)).toList();
  }

  static Future<List<Scan>> getScansByPlant(String plantId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('plant_id', plantId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Scan.fromMap(e)).toList();
  }

  static Future<void> saveScan(Scan scan) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw 'User not logged in';

    final data = scan.toMap();
    data['user_id'] = userId;

    await _client.from(_table).insert(data);
  }

  static Future<void> deleteScan(String scanId) async {
    await _client.from(_table).delete().eq('id', scanId);
  }

  static Future<void> updateScanPlant(String scanId, String? plantId) async {
    await _client.from(_table).update({'plant_id': plantId}).eq('id', scanId);
  }
}
