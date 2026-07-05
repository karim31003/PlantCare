import 'package:flutter/material.dart';
import '../domain/auth_repository.dart';
import '../data/supabase_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = SupabaseAuthRepository();
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  AuthRepository get repository => _repository;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.login(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.register(email, password, fullName);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.loginWithGoogle();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    notifyListeners();
  }
}
