import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:noor_ul_haya/core/config/router/app_router.dart';
import 'package:noor_ul_haya/core/providers/prayer_providers.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';
import 'package:noor_ul_haya/core/services/prayer_alarm_service.dart';
import 'package:noor_ul_haya/core/utils/prayer_utils.dart';
import 'package:noor_ul_haya/core/services/prayer_location_service.dart';
import 'package:adhan_dart/adhan_dart.dart';

/// First-run onboarding flow.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  Future<void> _finish({required bool enableNotifications}) async {
    if (enableNotifications) {
      await PrayerAlarmService.instance.requestPermission();
    }
    await ref.read(prayerPreferencesProvider.notifier).update(
          (prefs) => prefs.copyWith(onboardingComplete: true),
        );
    ref.invalidate(prayerScheduleProvider);
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.prayers);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(prayerScheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: (_page + 1) / 3,
                        minHeight: 6,
                        backgroundColor: AppColors.cardBorder,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _finish(enableNotifications: false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _page = index),
                children: [
                  _LocationStep(
                    onContinue: () => _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    ),
                  ),
                  scheduleAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (_, __) => const Center(
                      child: Text('Loading prayer times...'),
                    ),
                    data: (schedule) => _ReviewStep(
                      schedule: schedule,
                      onContinue: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  _NotificationStep(
                    onEnable: () => _finish(enableNotifications: true),
                    onSkip: () => _finish(enableNotifications: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationStep extends ConsumerWidget {
  const _LocationStep({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentMint,
            ),
            child: const Icon(
              Icons.location_on,
              size: 72,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Setting your location',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Enable location for accurate prayer times where you are.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          FilledButton(
            onPressed: () async {
              await ref.read(prayerPreferencesProvider.notifier).update(
                    (prefs) => prefs.copyWith(autoDetectLocation: true),
                  );
              ref.invalidate(prayerScheduleProvider);
              onContinue();
            },
            child: const Text('Enable Location'),
          ),
          TextButton(
            onPressed: onContinue,
            child: const Text('Select location manually'),
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.schedule, required this.onContinue});

  final PrayerSchedule schedule;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review your prayer time settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('dd MMMM yyyy').format(DateTime.now()),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(schedule.location.label),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: PrayerSchedule.obligatoryPrayers.map((prayer) {
                      final time = displayTimeForPrayer(schedule.times, prayer);
                      return Column(
                        children: [
                          Text(prayerEmoji(prayer), style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            prayerLabel(prayer),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(DateFormat.jm().format(prayerLocal(time))),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          FilledButton(onPressed: onContinue, child: const Text('Continue')),
        ],
      ),
    );
  }
}

class _NotificationStep extends StatelessWidget {
  const _NotificationStep({
    required this.onEnable,
    required this.onSkip,
  });

  final VoidCallback onEnable;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.accentMint,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.graphic_eq,
              size: 72,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Stay on time with Adhan reminders',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Get gentle reminders for prayer, Quran reading, and daily spiritual habits.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          FilledButton(
            onPressed: onEnable,
            child: const Text('Enable Notifications'),
          ),
          TextButton(onPressed: onSkip, child: const Text('Maybe later')),
        ],
      ),
    );
  }
}
