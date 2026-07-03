import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:noor_ul_haya/core/services/prayer_location_service.dart';
import 'package:noor_ul_haya/core/services/prayer_preferences_service.dart';
import 'package:noor_ul_haya/core/utils/prayer_utils.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:timezone/timezone.dart' as tz;

/// Schedules local notifications for enabled prayer alarms.
class PrayerAlarmService {
  PrayerAlarmService._();

  static final PrayerAlarmService instance = PrayerAlarmService._();
  static const _channelId = 'prayer_alarms';
  static const _minutesBefore = 15;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      'Prayer Alarms',
      description: 'Adhan reminders before each prayer',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> syncAlarms({
    required PrayerSchedule schedule,
    required PrayerPreferences prefs,
  }) async {
    await initialize();
    await _plugin.cancelAll();

    for (final prayer in PrayerSchedule.obligatoryPrayers) {
      final key = prayerKey(prayer);
      if (!(prefs.prayerAlarms[key] ?? false)) {
        continue;
      }

      var prayerAt = obligatoryPrayerTime(schedule.times, prayer);
      final now = prayerLocalNow();
      if (prayer == Prayer.fajr && now.isAfter(prayerLocal(schedule.times.isha))) {
        prayerAt = prayerLocal(schedule.times.fajrAfter);
      }

      var alarmAt = prayerAt.subtract(const Duration(minutes: _minutesBefore));
      if (alarmAt.isBefore(now)) {
        continue;
      }

      await _plugin.zonedSchedule(
        _notificationId(prayer),
        '${prayerLabel(prayer)} in $_minutesBefore minutes',
        'Prepare for ${prayerLabel(prayer)} at ${_formatTime(prayerAt)}',
        tz.TZDateTime.from(alarmAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Prayer Alarms',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  int _notificationId(Prayer prayer) {
    return switch (prayer) {
      Prayer.fajr => 1,
      Prayer.dhuhr => 2,
      Prayer.asr => 3,
      Prayer.maghrib => 4,
      Prayer.isha => 5,
      _ => 99,
    };
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
