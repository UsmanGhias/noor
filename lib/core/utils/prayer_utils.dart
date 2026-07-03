import 'package:adhan_dart/adhan_dart.dart';
import 'package:noor_ul_haya/core/services/prayer_location_service.dart';

/// Converts adhan_dart UTC instants to local wall-clock [DateTime].
DateTime prayerLocal(DateTime time) => time.toLocal();

DateTime prayerLocalNow() => DateTime.now();

String prayerLabel(Prayer prayer) {
  return switch (prayer) {
    Prayer.fajr => 'Fajr',
    Prayer.sunrise => 'Sunrise',
    Prayer.dhuhr => 'Dhuhr',
    Prayer.asr => 'Asr',
    Prayer.maghrib => 'Maghrib',
    Prayer.isha => "Isha'a",
    Prayer.ishaBefore => "Isha'a",
    Prayer.fajrAfter => 'Fajr',
  };
}

String prayerEmoji(Prayer prayer) {
  return switch (prayer) {
    Prayer.fajr => '✨',
    Prayer.dhuhr => '☀️',
    Prayer.asr => '🌤️',
    Prayer.maghrib => '🌇',
    Prayer.isha => '🌙',
    _ => '🕌',
  };
}

String prayerKey(Prayer prayer) {
  return switch (prayer) {
    Prayer.fajr => 'fajr',
    Prayer.dhuhr => 'dhuhr',
    Prayer.asr => 'asr',
    Prayer.maghrib => 'maghrib',
    Prayer.isha => 'isha',
    _ => prayer.name,
  };
}

DateTime displayTimeForPrayer(PrayerTimes times, Prayer prayer) {
  if (prayer == Prayer.fajr &&
      prayerLocalNow().isAfter(prayerLocal(times.isha))) {
    return prayerLocal(times.fajrAfter);
  }
  return obligatoryPrayerTime(times, prayer);
}

DateTime obligatoryPrayerTime(PrayerTimes times, Prayer prayer) {
  if (prayer == Prayer.fajr) {
    return prayerLocal(times.fajr);
  }
  return prayerLocal(times.timeForPrayer(prayer));
}

DateTime? nextObligatoryPrayerTime(PrayerTimes times) {
  final now = prayerLocalNow();
  for (final prayer in PrayerSchedule.obligatoryPrayers) {
    final at = obligatoryPrayerTime(times, prayer);
    if (now.isBefore(at)) {
      return at;
    }
  }
  return prayerLocal(times.fajrAfter);
}

Prayer? nextObligatoryPrayer(PrayerTimes times) {
  final now = prayerLocalNow();
  for (final prayer in PrayerSchedule.obligatoryPrayers) {
    if (now.isBefore(obligatoryPrayerTime(times, prayer))) {
      return prayer;
    }
  }
  return Prayer.fajr;
}

Prayer? currentObligatoryPrayer(PrayerTimes times) {
  final now = prayerLocalNow();
  Prayer? current;
  for (final prayer in PrayerSchedule.obligatoryPrayers) {
    if (!now.isBefore(obligatoryPrayerTime(times, prayer))) {
      current = prayer;
    }
  }
  return current;
}

Duration? timeUntilPrayer(PrayerTimes times, Prayer prayer) {
  final target = prayer == Prayer.fajr && prayerLocalNow().isAfter(prayerLocal(times.isha))
      ? prayerLocal(times.fajrAfter)
      : obligatoryPrayerTime(times, prayer);
  final diff = target.difference(prayerLocalNow());
  return diff.isNegative ? null : diff;
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  if (minutes > 0) {
    return '${minutes}m';
  }
  return '${duration.inSeconds}s';
}

double normalizeHeading(double? heading) {
  if (heading == null || heading.isNaN) {
    return 0;
  }
  return (heading % 360 + 360) % 360;
}

/// Degrees to rotate Qibla indicator on a north-up compass rose.
double qiblaRelativeAngle(double qiblaBearing, double? heading) {
  final h = normalizeHeading(heading);
  return (qiblaBearing - h + 360) % 360;
}

String turnInstruction(double qiblaBearing, double? heading) {
  if (heading == null || heading.isNaN) {
    return 'Calibrating compass...';
  }
  final delta = qiblaRelativeAngle(qiblaBearing, heading);
  if (delta <= 12 || delta >= 348) {
    return 'Facing Qibla';
  }
  return delta <= 180 ? 'Turn right' : 'Turn left';
}
