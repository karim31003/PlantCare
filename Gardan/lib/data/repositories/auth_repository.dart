// lib/data/repositories/auth_repository.dart

import '../services/auth_service.dart';

class AuthRepository {
  // ─── Email / Password ─────────────────────────────────────────────

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await AuthService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await AuthService.signIn(email: email, password: password);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Google ───────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    try {
      await AuthService.signInWithGoogle();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await AuthService.signOut();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Session ──────────────────────────────────────────────────────

  get currentUser => AuthService.currentUser;
  get currentSession => AuthService.currentSession;
  get authStateChanges => AuthService.authStateChanges;

  // ─── Error Handler ────────────────────────────────────────────────

  String _handleError(dynamic e) {
    if (e.toString().contains('invalid_credentials')) {
      return 'Invalid email or password.';
    } else if (e.toString().contains('email_taken')) {
      return 'This email is already registered.';
    } else if (e.toString().contains('network')) {
      return 'Network error. Check your connection.';
    }
    return e.toString();
  }
}