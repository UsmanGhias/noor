import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noor_ul_haya/app.dart';
import 'package:noor_ul_haya/core/providers/prayer_providers.dart';
import 'package:noor_ul_haya/core/services/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(AppBootstrap.preferences),
      ],
      child: const NoorApp(),
    ),
  );
}
