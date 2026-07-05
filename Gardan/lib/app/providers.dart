// lib/app/providers.dart

import 'package:gardain/presentation/providers/cart_provider.dart';
import 'package:gardain/presentation/providers/orders_provider.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/plants_provider.dart';
import '../presentation/providers/scans_provider.dart';
import '../presentation/providers/reminders_provider.dart';
import '../presentation/providers/products_provider.dart';

final appProviders = [
  ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
  ChangeNotifierProvider<PlantsProvider>(create: (_) => PlantsProvider()),
  ChangeNotifierProvider<ScansProvider>(create: (_) => ScansProvider()),
  ChangeNotifierProvider<RemindersProvider>(create: (_) => RemindersProvider()),
  ChangeNotifierProvider<ProductsProvider>(create: (_) => ProductsProvider()),
  ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
  ChangeNotifierProvider<OrdersProvider>(create: (_) => OrdersProvider()),
];