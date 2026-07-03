import 'package:adhan_dart/adhan_dart.dart';

void main() {
  final c = const Coordinates(31.063, 72.961);
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
