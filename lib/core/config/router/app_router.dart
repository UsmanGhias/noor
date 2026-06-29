import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noor_ul_haya/features/home/presentation/home_screen.dart';

/// Central route path definitions.
abstract final class AppRoutes {
  static const String home = '/';
}

/// Application router configuration.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
  ],
);
