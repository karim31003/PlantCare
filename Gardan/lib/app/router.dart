// lib/app/router.dart

import 'package:gardain/features/cart/cart_screen.dart';
import 'package:gardain/features/checkout/checkout_screen.dart';
import 'package:gardain/features/orders/order_tracking_screen.dart';
import 'package:gardain/features/plants/plant_detail_screen.dart';
import 'package:gardain/features/profile/presentation/addresses_screen.dart';
import 'package:gardain/features/profile/presentation/edit_profile_screen.dart';
import 'package:gardain/features/profile/presentation/help_screen.dart';
import 'package:gardain/features/profile/presentation/my_orders_screen.dart';
import 'package:gardain/features/profile/presentation/payment_screen.dart';
import 'package:gardain/features/profile/presentation/settings_screen.dart';
import 'package:gardain/features/shop/product_detail_screen.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/main_scaffold.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/plants/my_plants_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/scan/presentation/scan_screen.dart';
import '../features/shop/ShopScreen.dart';

GoRouter createRouter({
  required bool isFirstLaunch,
  required bool isLoggedIn,
}) {
  final initialLocation = isFirstLaunch
      ? '/onboarding'
      : (isLoggedIn ? '/home' : '/login');

  return GoRouter(
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

      // ── Outside ShellRoute (no bottom nav) ──────────────────────────
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderTrackingScreen(orderId: orderId);
        },
      ),

      // ── Profile sub-screens (no bottom nav) ─────────────────────────
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/orders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/profile/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/profile/addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/profile/payment',
        builder: (context, state) => const PaymentScreen(),
      ),

      // ── Shell (with bottom nav) ──────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/plants',
            builder: (context, state) => const PlantsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final plantId = state.pathParameters['id']!;
                  return PlantDetailScreen(plantId: plantId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/shop',
            builder: (context, state) => const ShopScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final productId = state.pathParameters['id']!;
                  return ProductDetailScreen(productId: productId);
                },
              ),
            ],
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
}
