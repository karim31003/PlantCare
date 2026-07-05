// lib/data/repositories/reminders_repository.dart

import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/reminders_service.dart';

class RemindersRepository {
  Future<List<Reminder>> getReminders() async {
    try {
      return await RemindersService.getReminders();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Add reminder + schedule notification ─────────────────────────

  Future<void> addReminder(Reminder reminder) async {
    try {
      await RemindersService.addReminder(reminder);
      await NotificationService.scheduleReminder(
        id: reminder.id.hashCode,
        plantName: reminder.plantName,
        scheduledTime: reminder.scheduledTime,
        frequency: reminder.frequency,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      await RemindersService.updateReminder(reminder);
      await NotificationService.cancelReminder(reminder.id.hashCode);
      if (reminder.isActive) {
        await NotificationService.scheduleReminder(
          id: reminder.id.hashCode,
          plantName: reminder.plantName,
          scheduledTime: reminder.scheduledTime,
          frequency: reminder.frequency,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Toggle + sync notification ───────────────────────────────────

  Future<void> toggleReminder(Reminder reminder) async {
    try {
      await RemindersService.toggleReminder(
        reminderId: reminder.id,
        isActive: !reminder.isActive,
      );
      if (reminder.isActive) {
        await NotificationService.cancelReminder(reminder.id.hashCode);
      } else {
        await NotificationService.scheduleReminder(
          id: reminder.id.hashCode,
          plantName: reminder.plantName,
          scheduledTime: reminder.scheduledTime,
          frequency: reminder.frequency,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Delete reminder + cancel notification ────────────────────────

  Future<void> deleteReminder(Reminder reminder) async {
    try {
      await RemindersService.deleteReminder(reminder.id);
      await NotificationService.cancelReminder(reminder.id.hashCode);
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    if (e.toString().contains('network')) {
      return 'Network error. Check your connection.';
    }
    return 'Something went wrong with your reminders. Please try again.';
  }
}