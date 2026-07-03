import 'package:go_router/go_router.dart';
import 'package:noor_ul_haya/core/widgets/main_shell.dart';
import 'package:noor_ul_haya/features/duas/presentation/duas_screen.dart';
import 'package:noor_ul_haya/features/onboarding/presentation/onboarding_screen.dart';
import 'package:noor_ul_haya/features/prayers/presentation/prayers_screen.dart';
import 'package:noor_ul_haya/features/qibla/presentation/qibla_screen.dart';
import 'package:noor_ul_haya/features/quran/presentation/quran_screen.dart';
import 'package:noor_ul_haya/features/settings/presentation/location_settings_screen.dart';
import 'package:noor_ul_haya/features/settings/presentation/settings_screen.dart';
import 'package:noor_ul_haya/features/splash/presentation/splash_screen.dart';
import 'package:noor_ul_haya/features/tasbih/presentation/tasbih_screen.dart';

/// Central route path definitions.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String prayers = '/prayers';
  static const String qibla = '/qibla';
  static const String settings = '/settings';
  static const String locationSettings = '/settings/location';
  static const String quran = '/quran';
  static const String duas = '/duas';
  static const String tasbih = '/tasbih';
}

/// Application router configuration.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.locationSettings,
      builder: (_, __) => const LocationSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.quran,
      builder: (_, __) => const QuranScreen(),
    ),
    GoRoute(
      path: AppRoutes.duas,
      builder: (_, __) => const DuasScreen(),
    ),
    GoRoute(
      path: AppRoutes.tasbih,
      builder: (_, __) => const TasbihScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.prayers,
              builder: (_, __) => const PrayersScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.qibla,
              builder: (_, __) => const QiblaScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (_, __) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
