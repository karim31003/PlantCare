import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseClient client = Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static String? get currentUserId => client.auth.currentUser?.id;

  static bool get isLoggedIn => client.auth.currentUser != null;
}