// lib/presentation/providers/reminders_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/reminder.dart';
import '../../data/repositories/reminders_repository.dart';

class RemindersProvider extends ChangeNotifier {
  final _repository = RemindersRepository();

  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get reminders => _reminders;
  List<Reminder> get activeReminders =>
      _reminders.where((r) => r.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchReminders() async {
    _setLoading(true);
    _error = null;
    try {
      _reminders = await _repository.getReminders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addReminder(Reminder reminder) async {
    _setLoading(true);
    _error = null;
    try {
      await _repository.addReminder(reminder);
      await fetchReminders();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateReminder(Reminder reminder) async {
    _setLoading(true);
    _error = null;
    try {
      await _repository.updateReminder(reminder);
      await fetchReminders();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleReminder(Reminder reminder) async {
    _error = null;
    try {
      await _repository.toggleReminder(reminder);
      await fetchReminders();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReminder(Reminder reminder) async {
    _setLoading(true);
    _error = null;
    try {
      await _repository.deleteReminder(reminder);
      await fetchReminders();
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