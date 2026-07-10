import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:noor_ul_haya/core/config/router/app_router.dart';
import 'package:noor_ul_haya/core/providers/prayer_providers.dart';
import 'package:noor_ul_haya/core/services/prayer_alarm_service.dart';
import 'package:noor_ul_haya/core/services/prayer_location_service.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';
import 'package:noor_ul_haya/core/utils/prayer_utils.dart';
import 'package:noor_ul_haya/features/hadith/providers/hadith_providers.dart';

/// Main prayer dashboard with greeting, quick actions, times, and alarms.
class PrayersScreen extends ConsumerStatefulWidget {
  const PrayersScreen({super.key});

  @override
  ConsumerState<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends ConsumerState<PrayersScreen> {
  final _scrollController = ScrollController();
  final _prayerTimesKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPrayerTimes() {
    final ctx = _prayerTimesKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(prayerScheduleProvider);
    final prefs = ref.watch(prayerPreferencesProvider);
    final dailyHadithAsync = ref.watch(dailyHadithProvider);
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
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                children: [
                  // Compact status banner
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bannerBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: AppColors.brandPrimary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Prayer times based on ${schedule.location.label}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Compact Assalam greeting (no large empty gap)
                  Text(
                    'ٱلسَّلَامُ عَلَيْكُمْ',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.brandAccent,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Assalamu Alaikum',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.15,
                    ),
                  ),
                  Text(
                    _timeGreeting(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 14, color: AppColors.brandAccent),
                          const SizedBox(width: 4),
                          Text(
                            schedule.location.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quick actions: Prayers, Quran, Hadith, Calendar
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.mosque_rounded,
                          label: 'Prayers',
                          onTap: _scrollToPrayerTimes,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.menu_book_rounded,
                          label: 'Quran',
                          onTap: () => context.push(AppRoutes.quran),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.format_quote_rounded,
                          label: 'Hadith',
                          onTap: () => context.push(AppRoutes.hadith),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.calendar_month_rounded,
                          label: 'Calendar',
                          onTap: () => context.push(AppRoutes.calendar),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dates
                  Row(
                    children: [
                      Text(
                        '${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(now),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress + Next prayer
                  Row(
                    children: [
                      Expanded(
                        child: _TrackerCard(
                          prayedCount: prayedCount,
                          total: PrayerSchedule.obligatoryPrayers.length,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _NextPrayerCard(
                          next: next,
                          schedule: schedule,
                          countdown: nextCountdown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Daily hadith teaser
                  dailyHadithAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (hadith) => _DailyCard(
                      title: 'Daily Hadith',
                      subtitle: '${hadith.bookName} #${hadith.number}',
                      arabic: hadith.arabic,
                      body: hadith.english,
                      onTap: () => context.push(AppRoutes.hadith),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Prayer times section (scroll target)
                  KeyedSubtree(
                    key: _prayerTimesKey,
                    child: Text(
                      'Prayer Times',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Imsak ${DateFormat.jm().format(prayerLocal(schedule.times.fajr))} · Sunrise ${DateFormat.jm().format(prayerLocal(schedule.times.sunrise))}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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
                        onSetAlarm: () =>
                            _showAlarmSheet(context, prayer, time),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(AppRoutes.duas),
                          icon: const Icon(Icons.volunteer_activism_outlined),
                          label: const Text('Duas'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(AppRoutes.tasbih),
                          icon: const Icon(Icons.radio_button_checked),
                          label: const Text('Tasbih'),
                        ),
                      ),
                    ],
                  ),
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
                      color: AppColors.brandPrimary,
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
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.brandAccent, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({
    required this.title,
    required this.subtitle,
    required this.body,
    this.arabic,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String body;
  final String? arabic;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_quote_rounded,
                      color: AppColors.brandAccent, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (arabic != null && arabic!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  arabic!,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, height: 1.6),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.45,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({
    required this.next,
    required this.schedule,
    required this.countdown,
  });

  final Prayer? next;
  final PrayerSchedule schedule;
  final Duration? countdown;

  @override
  Widget build(BuildContext context) {
    final displayPrayer = next ?? Prayer.fajr;
    final time = displayTimeForPrayer(schedule.times, displayPrayer);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.bannerBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Next Prayer',
              style: TextStyle(
                color: AppColors.brandPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  prayerLabel(displayPrayer),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
              Text(
                prayerEmoji(displayPrayer),
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          Text(
            DateFormat.jm().format(prayerLocal(time)),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          if (countdown != null) ...[
            const SizedBox(height: 6),
            Text(
              formatDuration(countdown!),
              style: const TextStyle(
                color: AppColors.brandAccent,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ],
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  color: AppColors.brandAccent,
                  backgroundColor: AppColors.accentMint,
                ),
                Text(
                  '$prayedCount/$total',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Today's progress",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
                isPrayed ? Icons.check_circle : Icons.radio_button_unchecked,
                color:
                    isPrayed ? AppColors.accentGreen : AppColors.textSecondary,
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
                color:
                    alarmOn ? AppColors.brandAccent : AppColors.textSecondary,
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
