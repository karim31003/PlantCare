import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String fullName);
  Future<void> loginWithGoogle();
  Future<void> logout();
  Session? get currentSession;
  User? get currentUser;
  Stream<AuthState> get authStateChanges;
}
