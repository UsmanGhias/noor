import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:noor_ul_haya/core/services/prayer_alarm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// One-time app initialization (storage, timezone data).
abstract final class AppBootstrap {
  static Future<void>? _initFuture;
  static SharedPreferences? _preferences;

  static SharedPreferences get preferences {
    final prefs = _preferences;
    if (prefs == null) {
      throw StateError('AppBootstrap.ensureInitialized() must be called first');
    }
    return prefs;
  }

  static Future<void> ensureInitialized() {
    return _initFuture ??= _initialize();
  }

  /// Resets bootstrap state for tests.
  static void resetForTest() {
    _initFuture = null;
    _preferences = null;
  }

  static Future<void> _initialize() async {
    await Hive.initFlutter();
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } on Object {
      tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
    }
    try {
      await PrayerAlarmService.instance.initialize();
    } on Object {
      // Notifications may be unavailable in tests / unsupported platforms.
    }
    _preferences = await SharedPreferences.getInstance();
  }
}
