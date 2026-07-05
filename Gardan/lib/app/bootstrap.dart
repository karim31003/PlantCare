import 'package:flutter/material.dart';
import 'package:gardain/data/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/api_config_service.dart';
import '../core/services/persistence_service.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

 await Supabase.initialize(
    url: 'https://orrvgipkejjqkidqvtph.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ycnZnaXBrZWpqcWtpZHF2dHBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1NDYxMjAsImV4cCI6MjA4NzEyMjEyMH0.1SuZuAJcGCY5Y_kK-CzhzU_OnZA67WIimRxW6SDtijs',
  );
await NotificationService.init();
  await ApiConfigService.init();


  final bool isFirstLaunch = await PersistenceService.isFirstLaunch();
  final bool isLoggedIn =
      Supabase.instance.client.auth.currentSession != null;

  runApp(
    MyGardenerApp(
      isFirstLaunch: isFirstLaunch,
      isLoggedIn: isLoggedIn,
    ),
  );
}
