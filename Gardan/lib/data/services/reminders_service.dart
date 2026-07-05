// lib/data/services/reminders_service.dart

import '../models/reminder.dart';
import 'supabase_service.dart';

class RemindersService {
  RemindersService._();

  static final _client = SupabaseService.client;
  static const _table = 'reminders';

  static Future<List<Reminder>> getReminders() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw 'User not logged in';

    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Reminder.fromMap(e)).toList();
  }

  static Future<void> addReminder(Reminder reminder) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw 'User not logged in';

    final data = reminder.toMap();
    data['user_id'] = userId;

    await _client.from(_table).insert(data);
  }

  static Future<void> updateReminder(Reminder reminder) async {
    await _client.from(_table).update(reminder.toMap()).eq('id', reminder.id);
  }

  static Future<void> toggleReminder({
    required String reminderId,
    required bool isActive,
  }) async {
    await _client
        .from(_table)
        .update({'is_active': isActive}).eq('id', reminderId);
  }

  static Future<void> deleteReminder(String reminderId) async {
    await _client.from(_table).delete().eq('id', reminderId);
  }
}