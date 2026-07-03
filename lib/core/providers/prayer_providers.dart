import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noor_ul_haya/core/services/app_bootstrap.dart';
import 'package:noor_ul_haya/core/services/prayer_alarm_service.dart';
import 'package:noor_ul_haya/core/services/prayer_location_service.dart';
import 'package:noor_ul_haya/core/services/prayer_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final bootstrapProvider = FutureProvider<void>((ref) async {
  await AppBootstrap.ensureInitialized();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final prayerPreferencesServiceProvider = Provider<PrayerPreferencesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PrayerPreferencesService(prefs);
});

final prayerLocationServiceProvider = Provider<PrayerLocationService>((ref) {
  return PrayerLocationService(ref.watch(prayerPreferencesServiceProvider));
});

class PrayerPreferencesNotifier extends StateNotifier<PrayerPreferences> {
  PrayerPreferencesNotifier(this._service, PrayerPreferences initial)
      : super(initial);

  final PrayerPreferencesService _service;

  Future<void> update(PrayerPreferences Function(PrayerPreferences) transform) async {
    state = transform(state);
    await _service.save(state);
  }

  Future<void> togglePrayed(String prayerKey) async {
    final updated = Set<String>.from(state.prayedToday);
    if (updated.contains(prayerKey)) {
      updated.remove(prayerKey);
    } else {
      updated.add(prayerKey);
    }
    await update((prefs) => prefs.copyWith(prayedToday: updated));
  }

  Future<void> toggleAlarm(String prayerKey) async {
    final alarms = Map<String, bool>.from(state.prayerAlarms);
    alarms[prayerKey] = !(alarms[prayerKey] ?? false);
    await update((prefs) => prefs.copyWith(prayerAlarms: alarms));
  }
}

final prayerPreferencesProvider =
    StateNotifierProvider<PrayerPreferencesNotifier, PrayerPreferences>((ref) {
  final service = ref.watch(prayerPreferencesServiceProvider);
  return PrayerPreferencesNotifier(service, service.load());
});

final prayerScheduleProvider = FutureProvider<PrayerSchedule>((ref) async {
  ref.watch(prayerPreferencesProvider);
  final prefs = ref.read(prayerPreferencesProvider);
  final schedule =
      await ref.watch(prayerLocationServiceProvider).loadSchedule(prefs);
  await PrayerAlarmService.instance.syncAlarms(
    schedule: schedule,
    prefs: prefs,
  );
  return schedule;
});
