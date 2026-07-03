import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noor_ul_haya/core/config/app_config.dart';
import 'package:noor_ul_haya/core/config/router/app_router.dart';
import 'package:noor_ul_haya/core/providers/prayer_providers.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';

/// Branded splash shown while the app starts.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _launch();
  }

  Future<void> _launch() async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      return;
    }

    final prefs = ref.read(prayerPreferencesProvider);
    if (prefs.onboardingComplete) {
      context.go(AppRoutes.prayers);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mosque_outlined,
                  size: 52,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                kAppName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your daily prayer companion',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
