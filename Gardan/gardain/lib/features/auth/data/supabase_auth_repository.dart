import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> register(String email, String password, String fullName) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  @override
  Future<void> loginWithGoogle() async {
    // Note: client_id is required for iOS/Android
    // For web, serverClientId is used. For iOS, use iosClientId from Google Cloud.
    const webClientId = '832276128132-97a692iqo57ls3lf555qt1t5peqgdbaf.apps.googleusercontent.com';
    final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: webClientId);
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;
    
    if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth!.idToken!,
        accessToken: googleAuth.accessToken!,
      );
    } else {
      throw 'Google Sign In failed: Missing tokens';
    }
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
