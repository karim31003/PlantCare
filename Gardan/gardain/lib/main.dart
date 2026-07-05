import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/persistence_service.dart';
import 'core/theme/app_theme.dart';
// TODO: Import feature pages as they are created
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/plants/presentation/plant_provider.dart';
import 'features/home/presentation/main_scaffold.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/scan/presentation/scan_screen.dart';
import 'features/plants/presentation/my_plants_screen.dart';
import 'features/profile/presentation/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // TODO: Replace with actual URL and Key from User
  await Supabase.initialize(
    url: 'https://orrvgipkejjqkidqvtph.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ycnZnaXBrZWpqcWtpZHF2dHBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1NDYxMjAsImV4cCI6MjA4NzEyMjEyMH0.1SuZuAJcGCY5Y_kK-CzhzU_OnZA67WIimRxW6SDtijs',
  );

  final bool isFirstLaunch = await PersistenceService.isFirstLaunch();
  final bool isLoggedIn = Supabase.instance.client.auth.currentSession != null;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlantProvider()),
      ],
      child: MyGardenerApp(
        isFirstLaunch: isFirstLaunch,
        isLoggedIn: isLoggedIn,
      ),
    ),
  );
}

class MyGardenerApp extends StatelessWidget {
  final bool isFirstLaunch;
  final bool isLoggedIn;

  const MyGardenerApp({
    super.key,
    required this.isFirstLaunch,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final String initialLocation = isFirstLaunch 
        ? '/onboarding' 
        : (isLoggedIn ? '/home' : '/login');

    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return MainScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/plants',
              builder: (context, state) => const MyPlantsScreen(),
            ),
            GoRoute(
              path: '/scan',
              builder: (context, state) => const ScanScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'My Gardener',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
