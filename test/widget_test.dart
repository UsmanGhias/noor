import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ul_haya/core/providers/prayer_providers.dart';
import 'package:noor_ul_haya/core/services/app_bootstrap.dart';
import 'package:noor_ul_haya/features/prayers/presentation/prayers_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    AppBootstrap.resetForTest();
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async {
        if (call.method == 'getApplicationDocumentsDirectory') {
          return '.';
        }
        return null;
      },
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/geolocator'),
      (call) async => false,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_timezone'),
      (call) async => 'Asia/Karachi',
    );
    await AppBootstrap.ensureInitialized();
  });

  tearDown(() {
    for (final channel in [
      'flutter.baseflow.com/geolocator',
      'plugins.flutter.io/path_provider',
      'flutter_timezone',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), null);
    }
  });

  testWidgets('Prayers dashboard renders schedule', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(AppBootstrap.preferences),
        ],
        child: const MaterialApp(home: PrayersScreen()),
      ),
    );

    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('Prayer Times').evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.textContaining('Assalamu'), findsWidgets);
    expect(find.text('Prayer Times'), findsOneWidget);
    expect(find.text('Hadith'), findsWidgets);
  });
}
