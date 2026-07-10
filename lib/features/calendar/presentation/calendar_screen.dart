import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';
import 'package:noor_ul_haya/features/calendar/data/islamic_events.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _viewYear;
  late int _viewMonth;

  @override
  void initState() {
    super.initState();
    final now = HijriCalendar.now();
    _viewYear = now.hYear;
    _viewMonth = now.hMonth;
  }

  HijriCalendar _monthCal() {
    final cal = HijriCalendar()
      ..hYear = _viewYear
      ..hMonth = _viewMonth
      ..hDay = 1;
    return cal;
  }

  void _shiftMonth(int delta) {
    setState(() {
      _viewMonth += delta;
      while (_viewMonth > 12) {
        _viewMonth -= 12;
        _viewYear++;
      }
      while (_viewMonth < 1) {
        _viewMonth += 12;
        _viewYear--;
      }
    });
  }

  int _leadingBlanks(HijriCalendar monthCal) {
    final firstGreg = monthCal.hijriToGregorian(_viewYear, _viewMonth, 1);
    return firstGreg.weekday % 7;
  }

  Color? _dayColor(int day, bool isToday) {
    if (isToday) {
      return AppColors.brandAccent.withValues(alpha: 0.28);
    }
    if (_viewMonth == 9) {
      return AppColors.brandAccent.withValues(alpha: 0.1);
    }
    for (final e in islamicEvents) {
      if (e.hijriMonth == _viewMonth && e.hijriDay == day) {
        if (e.id == 'ashura') {
          return Colors.red.withValues(alpha: 0.12);
        }
        if (e.id.startsWith('eid')) {
          return AppColors.brandPrimary.withValues(alpha: 0.15);
        }
        return AppColors.accentMint;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    HijriCalendar.setLocal('en');
    final monthCal = _monthCal();
    final daysInMonth = monthCal.lengthOfMonth;
    final leading = _leadingBlanks(monthCal);
    final today = HijriCalendar.now();
    final firstGreg = monthCal.hijriToGregorian(_viewYear, _viewMonth, 1);
    final lastGreg =
        monthCal.hijriToGregorian(_viewYear, _viewMonth, daysInMonth);
    final gregRange =
        '${DateFormat('d MMM').format(firstGreg)} - ${DateFormat('d MMM yyyy').format(lastGreg)}';

    final events = islamicEvents.map((event) {
      final greg = monthCal.hijriToGregorian(
        _viewYear,
        event.hijriMonth,
        event.hijriDay,
      );
      return (event: event, greg: greg);
    }).toList()
      ..sort((a, b) => a.greg.compareTo(b.greg));

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    'Islamic Calendar',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandPrimary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${today.hDay} ${today.getLongMonthName()} ${today.hYear}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPrimary.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _shiftMonth(-1),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${monthCal.getLongMonthName()} $_viewYear',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: AppColors.brandPrimary,
                              ),
                            ),
                            Text(
                              gregRange,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _shiftMonth(1),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map(
                          (d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    ),
                    itemCount: leading + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < leading) {
                        return const SizedBox.shrink();
                      }
                      final day = index - leading + 1;
                      final isToday = today.hYear == _viewYear &&
                          today.hMonth == _viewMonth &&
                          today.hDay == day;
                      final bg = _dayColor(day, isToday);
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                          border: isToday
                              ? Border.all(
                                  color: AppColors.brandAccent, width: 1.5)
                              : null,
                        ),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontWeight:
                                isToday ? FontWeight.w800 : FontWeight.w600,
                            color: isToday
                                ? AppColors.brandPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Important dates',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...events.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: AppColors.goldGradient,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${e.event.hijriDay}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.event.titleEn,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${e.event.hijriDay}/${e.event.hijriMonth}/$_viewYear · ${DateFormat('d MMM yyyy').format(e.greg)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
