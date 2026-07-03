import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noor_ul_haya/core/services/prayer_preferences_service.dart';

/// Resolved location used for prayer calculations.
class ResolvedLocation {
  const ResolvedLocation({
    required this.coordinates,
    required this.label,
    required this.usesDeviceLocation,
  });

  final Coordinates coordinates;
  final String label;
  final bool usesDeviceLocation;
}

/// Today's prayer schedule for the resolved location.
class PrayerSchedule {
  const PrayerSchedule({
    required this.location,
    required this.times,
    required this.generatedAt,
    required this.calculationLabel,
  });

  final ResolvedLocation location;
  final PrayerTimes times;
  final DateTime generatedAt;
  final String calculationLabel;

  static const List<Prayer> obligatoryPrayers = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];
}

class PrayerLocationService {
  PrayerLocationService(this._preferencesService);

  final PrayerPreferencesService _preferencesService;

  Future<ResolvedLocation> resolve(PrayerPreferences prefs) async {
    if (!prefs.autoDetectLocation) {
      return ResolvedLocation(
        coordinates: prefs.manualCity.coordinates,
        label: '${prefs.manualCity.label}, Pakistan',
        usesDeviceLocation: false,
      );
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _fallback(prefs);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return _fallback(prefs);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return ResolvedLocation(
        coordinates: Coordinates(position.latitude, position.longitude),
        label: _formatCoordinates(position.latitude, position.longitude),
        usesDeviceLocation: true,
      );
    } on Object {
      return _fallback(prefs);
    }
  }

  Future<PrayerSchedule> loadSchedule(PrayerPreferences prefs) async {
    final location = await resolve(prefs);
    final now = DateTime.now();
    final times = PrayerTimes(
      date: now,
      coordinates: location.coordinates,
      calculationParameters: _preferencesService.calculationParameters(prefs),
    );

    return PrayerSchedule(
      location: location,
      times: times,
      generatedAt: now,
      calculationLabel: prefs.calculationMethod.label,
    );
  }

  ResolvedLocation _fallback(PrayerPreferences prefs) {
    return ResolvedLocation(
      coordinates: prefs.manualCity.coordinates,
      label: '${prefs.manualCity.label}, Pakistan',
      usesDeviceLocation: false,
    );
  }

  String _formatCoordinates(double latitude, double longitude) {
    final lat = latitude.abs().toStringAsFixed(2);
    final lng = longitude.abs().toStringAsFixed(2);
    final latHemisphere = latitude >= 0 ? 'N' : 'S';
    final lngHemisphere = longitude >= 0 ? 'E' : 'W';
    return '$lat°$latHemisphere, $lng°$lngHemisphere';
  }
}

double qiblaDirection(Coordinates coordinates) {
  return Qibla.qibla(coordinates);
}
