import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import 'providers.dart';
import 'router.dart';

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
    final router = createRouter(
      isFirstLaunch: isFirstLaunch,
      isLoggedIn: isLoggedIn,
    );

    return MultiProvider(
      providers: appProviders,
      child: MaterialApp.router(
        title: 'My Gardener',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}