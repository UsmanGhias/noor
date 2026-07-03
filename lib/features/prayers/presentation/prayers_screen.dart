import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:noor_ul_haya/core/services/prayer_alarm_service.dart';
import 'package:noor_ul_haya/core/providers/prayer_providers.dart';
import 'package:noor_ul_haya/core/services/prayer_location_service.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';
import 'package:noor_ul_haya/core/utils/prayer_utils.dart';
import 'package:adhan_dart/adhan_dart.dart';

/// Main prayer dashboard with times, tracker, and alarms.
class PrayersScreen extends ConsumerStatefulWidget {
  const PrayersScreen({super.key});

  @override
  ConsumerState<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends ConsumerState<PrayersScreen> {
  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(prayerScheduleProvider);
    final prefs = ref.watch(prayerPreferencesProvider);
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        child: scheduleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _ErrorState(onRetry: () {
            ref.invalidate(prayerScheduleProvider);
          }),
          data: (schedule) {
            final current = currentObligatoryPrayer(schedule.times);
            final next = nextObligatoryPrayer(schedule.times);
            final nextCountdown =
                next == null ? null : timeUntilPrayer(schedule.times, next);
            final prayedCount = PrayerSchedule.obligatoryPrayers
                .where((prayer) => prefs.prayedToday.contains(prayerKey(prayer)))
                .length;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(prayerScheduleProvider);
                await ref.read(prayerScheduleProvider.future);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today, ${DateFormat('d MMMM').format(now)}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.invalidate(prayerScheduleProvider);
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(
                        icon: Icons.location_on_outlined,
                        label: schedule.location.label,
                      ),
                      _Chip(
                        icon: Icons.calculate_outlined,
                        label: schedule.calculationLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _CurrentPrayerCard(
                          current: current,
                          next: next,
                          schedule: schedule,
                          countdown: nextCountdown,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _TrackerCard(
                        prayedCount: prayedCount,
                        total: PrayerSchedule.obligatoryPrayers.length,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        'Imsak ${DateFormat.jm().format(prayerLocal(schedule.times.fajr))} | '
                        'Sunrise ${DateFormat.jm().format(prayerLocal(schedule.times.sunrise))}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Prayer Times',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...PrayerSchedule.obligatoryPrayers.map((prayer) {
                    final isCurrent = prayer == current;
                    final isNext = prayer == next;
                    final time = displayTimeForPrayer(schedule.times, prayer);
                    final key = prayerKey(prayer);
                    final isPrayed = prefs.prayedToday.contains(key);
                    final alarmOn = prefs.prayerAlarms[key] ?? false;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PrayerRow(
                        prayer: prayer,
                        timeLabel: DateFormat.jm().format(prayerLocal(time)),
                        isCurrent: isCurrent,
                        isNext: isNext,
                        nextIn: isNext ? nextCountdown : null,
                        isPrayed: isPrayed,
                        alarmOn: alarmOn,
                        onTogglePrayed: () {
                          ref
                              .read(prayerPreferencesProvider.notifier)
                              .togglePrayed(key);
                        },
                        onToggleAlarm: () async {
                          await PrayerAlarmService.instance.requestPermission();
                          final wasOn = alarmOn;
                          await ref
                              .read(prayerPreferencesProvider.notifier)
                              .toggleAlarm(key);
                          ref.invalidate(prayerScheduleProvider);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                wasOn
                                    ? '${prayerLabel(prayer)} alarm off'
                                    : '${prayerLabel(prayer)} alarm on (15 min before)',
                              ),
                            ),
                          );
                        },
                        onSetAlarm: () => _showAlarmSheet(context, prayer, time),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAlarmSheet(
    BuildContext context,
    Prayer prayer,
    DateTime time,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${prayerLabel(prayer)} Alarm',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat.jm().format(prayerLocal(time)),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  await PrayerAlarmService.instance.requestPermission();
                  final key = prayerKey(prayer);
                  final current = ref.read(prayerPreferencesProvider);
                  if (!(current.prayerAlarms[key] ?? false)) {
                    await ref
                        .read(prayerPreferencesProvider.notifier)
                        .toggleAlarm(key);
                  }
                  ref.invalidate(prayerScheduleProvider);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${prayerLabel(prayer)} alarm set 15 minutes before',
                      ),
                    ),
                  );
                },
                child: const Text('Set alarm 15 minutes before'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Adjust alarm time'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accentGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _CurrentPrayerCard extends StatelessWidget {
  const _CurrentPrayerCard({
    required this.current,
    required this.next,
    required this.schedule,
    required this.countdown,
  });

  final Prayer? current;
  final Prayer? next;
  final PrayerSchedule schedule;
  final Duration? countdown;

  @override
  Widget build(BuildContext context) {
    final displayPrayer = current ?? next ?? Prayer.fajr;
    final time = displayTimeForPrayer(schedule.times, displayPrayer);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentMint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Now',
                style: TextStyle(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${prayerEmoji(displayPrayer)} ${prayerLabel(displayPrayer)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat.jm().format(prayerLocal(time)),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (next != null && countdown != null) ...[
              const SizedBox(height: 8),
              Text(
                '${prayerLabel(next!)} in ${formatDuration(countdown!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrackerCard extends StatelessWidget {
  const _TrackerCard({required this.prayedCount, required this.total});

  final int prayedCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : prayedCount / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    color: AppColors.accentGreen,
                    backgroundColor: AppColors.accentMint,
                  ),
                  Text(
                    '$prayedCount/$total',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'prayed',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.prayer,
    required this.timeLabel,
    required this.isCurrent,
    required this.isNext,
    required this.nextIn,
    required this.isPrayed,
    required this.alarmOn,
    required this.onTogglePrayed,
    required this.onToggleAlarm,
    required this.onSetAlarm,
  });

  final Prayer prayer;
  final String timeLabel;
  final bool isCurrent;
  final bool isNext;
  final Duration? nextIn;
  final bool isPrayed;
  final bool alarmOn;
  final VoidCallback onTogglePrayed;
  final VoidCallback onToggleAlarm;
  final VoidCallback onSetAlarm;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isCurrent ? AppColors.accentGreen : AppColors.cardBorder;

    return InkWell(
      onTap: onSetAlarm,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onTogglePrayed,
              icon: Icon(
                isPrayed
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: isPrayed ? AppColors.accentGreen : AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${prayerEmoji(prayer)} ${prayerLabel(prayer)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (isNext && nextIn != null)
                    Text(
                      'in ${formatDuration(nextIn!)}',
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              timeLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            IconButton(
              onPressed: onToggleAlarm,
              icon: Icon(
                alarmOn ? Icons.notifications_active : Icons.notifications_none,
                color: alarmOn ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text('Could not load prayer times'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
