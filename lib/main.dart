import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:noor_ul_haya/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  tz.initializeTimeZones();

  await SharedPreferences.getInstance();

  runApp(
    const ProviderScope(
      child: NoorApp(),
    ),
  );
}
