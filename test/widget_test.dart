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
    AppBootstrap.skipAlarmsForTest = true;
    AppBootstrap.resetForTest();
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            if (call.method == 'getApplicationDocumentsDirectory') {
              return '.';
            }
            return null;
          },
        );
    await AppBootstrap.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          (call) async => false,
        );
  });

  tearDown(() {
    for (final channel in [
      'flutter.baseflow.com/geolocator',
      'plugins.flutter.io/path_provider',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), null);
    }
  });

  testWidgets('Prayers screen builds', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(AppBootstrap.preferences),
        ],
        child: const MaterialApp(home: PrayersScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(PrayersScreen), findsOneWidget);
  });
}
