import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuthService {
  AuthService._();

  static final _client = SupabaseService.client;

  static const _webClientId =
      '832276128132-fmtlgsdcui31e3hsqjfoq8g9k03psk1a.apps.googleusercontent.com';

  // ─── Email / Password ─────────────────────────────────────────────

  static Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ─── Google OAuth ──────────────────────────────────────────────────

  static Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(serverClientId: _webClientId);
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;

    if (googleAuth?.accessToken == null || googleAuth?.idToken == null) {
      throw 'Google Sign In failed: Missing tokens';
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth!.idToken!,
      accessToken: googleAuth.accessToken!,
    );
  }

  // ─── Sign Out ──────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _client.auth.signOut();
  }

  // ─── Session / User ────────────────────────────────────────────────

  static Session? get currentSession => _client.auth.currentSession;

  static User? get currentUser => _client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;
}