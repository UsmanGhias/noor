import 'package:adhan_dart/adhan_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CalculationMethodOption {
  karachi('Islamic University, Karachi', 'karachi'),
  muslimWorldLeague('Muslim World League', 'mwl'),
  ummAlQura('Umm Al-Qura', 'umm'),
  egyptian('Egyptian General Authority', 'egypt'),
  dubai('Dubai', 'dubai');

  const CalculationMethodOption(this.label, this.key);
  final String label;
  final String key;

  static CalculationMethodOption fromKey(String key) {
    return CalculationMethodOption.values.firstWhere(
      (option) => option.key == key,
      orElse: () => CalculationMethodOption.karachi,
    );
  }
}

enum PakistanCity {
  karachi('Karachi', 24.8607, 67.0011),
  lahore('Lahore', 31.5204, 74.3587),
  islamabad('Islamabad', 33.6844, 73.0479),
  faisalabad('Faisalabad', 31.4180, 73.0790),
  samundri('Samundri', 31.0630, 72.9610);

  const PakistanCity(this.label, this.latitude, this.longitude);
  final String label;
  final double latitude;
  final double longitude;

  Coordinates get coordinates => Coordinates(latitude, longitude);

  static PakistanCity fromKey(String key) {
    return PakistanCity.values.firstWhere(
      (city) => city.name == key,
      orElse: () => PakistanCity.karachi,
    );
  }
}

class PrayerPreferences {
  const PrayerPreferences({
    required this.onboardingComplete,
    required this.autoDetectLocation,
    required this.manualCity,
    required this.calculationMethod,
    required this.madhab,
    required this.prayerAlarms,
    required this.prayedToday,
  });

  final bool onboardingComplete;
  final bool autoDetectLocation;
  final PakistanCity manualCity;
  final CalculationMethodOption calculationMethod;
  final Madhab madhab;
  final Map<String, bool> prayerAlarms;
  final Set<String> prayedToday;

  PrayerPreferences copyWith({
    bool? onboardingComplete,
    bool? autoDetectLocation,
    PakistanCity? manualCity,
    CalculationMethodOption? calculationMethod,
    Madhab? madhab,
    Map<String, bool>? prayerAlarms,
    Set<String>? prayedToday,
  }) {
    return PrayerPreferences(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      autoDetectLocation: autoDetectLocation ?? this.autoDetectLocation,
      manualCity: manualCity ?? this.manualCity,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      prayerAlarms: prayerAlarms ?? this.prayerAlarms,
      prayedToday: prayedToday ?? this.prayedToday,
    );
  }
}

class PrayerPreferencesService {
  PrayerPreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingKey = 'onboarding_complete';
  static const _autoDetectKey = 'auto_detect_location';
  static const _cityKey = 'manual_city';
  static const _methodKey = 'calculation_method';
  static const _madhabKey = 'madhab';
  static const _alarmsKey = 'prayer_alarms';
  static const _prayedPrefix = 'prayed_';

  PrayerPreferences load() {
    final todayKey = _prayedKey(DateTime.now());
    final prayed = _prefs.getStringList(todayKey) ?? <String>[];
    final alarmsRaw = _prefs.getStringList(_alarmsKey) ?? <String>[];
    final alarms = {
      for (final entry in alarmsRaw)
        if (entry.contains(':'))
          entry.split(':').first: entry.split(':').last == '1',
    };

    return PrayerPreferences(
      onboardingComplete: _prefs.getBool(_onboardingKey) ?? false,
      autoDetectLocation: _prefs.getBool(_autoDetectKey) ?? true,
      manualCity: PakistanCity.fromKey(_prefs.getString(_cityKey) ?? 'karachi'),
      calculationMethod: CalculationMethodOption.fromKey(
        _prefs.getString(_methodKey) ?? 'karachi',
      ),
      madhab: _prefs.getString(_madhabKey) == 'hanafi'
          ? Madhab.hanafi
          : Madhab.shafi,
      prayerAlarms: {
        'fajr': alarms['fajr'] ?? true,
        'dhuhr': alarms['dhuhr'] ?? true,
        'asr': alarms['asr'] ?? true,
        'maghrib': alarms['maghrib'] ?? true,
        'isha': alarms['isha'] ?? true,
      },
      prayedToday: prayed.toSet(),
    );
  }

  Future<void> save(PrayerPreferences prefs) async {
    await _prefs.setBool(_onboardingKey, prefs.onboardingComplete);
    await _prefs.setBool(_autoDetectKey, prefs.autoDetectLocation);
    await _prefs.setString(_cityKey, prefs.manualCity.name);
    await _prefs.setString(_methodKey, prefs.calculationMethod.key);
    await _prefs.setString(
      _madhabKey,
      prefs.madhab == Madhab.hanafi ? 'hanafi' : 'shafi',
    );
    await _prefs.setStringList(
      _alarmsKey,
      prefs.prayerAlarms.entries
          .map((entry) => '${entry.key}:${entry.value ? 1 : 0}')
          .toList(),
    );
    await _prefs.setStringList(
      _prayedKey(DateTime.now()),
      prefs.prayedToday.toList(),
    );
  }

  CalculationParameters calculationParameters(PrayerPreferences prefs) {
    final params = switch (prefs.calculationMethod) {
      CalculationMethodOption.karachi =>
        CalculationMethodParameters.karachi(),
      CalculationMethodOption.muslimWorldLeague =>
        CalculationMethodParameters.muslimWorldLeague(),
      CalculationMethodOption.ummAlQura =>
        CalculationMethodParameters.ummAlQura(),
      CalculationMethodOption.egyptian =>
        CalculationMethodParameters.egyptian(),
      CalculationMethodOption.dubai => CalculationMethodParameters.dubai(),
    };
    params.madhab = prefs.madhab;
    return params;
  }

  String _prayedKey(DateTime date) {
    return '$_prayedPrefix${date.year}-${date.month}-${date.day}';
  }
}
