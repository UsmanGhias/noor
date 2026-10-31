// Command-line tool: printing is its output.
// ignore_for_file: avoid_print

import 'package:adhan_dart/adhan_dart.dart';

void main() {
  const c = Coordinates(31.063, 72.961);
  final t = PrayerTimes(
    date: DateTime.now(),
    coordinates: c,
    calculationParameters: CalculationMethodParameters.karachi(),
  );
  print('fajr raw: ${t.fajr}');
  print('fajr toLocal: ${t.fajr.toLocal()}');
  print('isha raw: ${t.isha}');
  print('isha toLocal: ${t.isha.toLocal()}');
}
