import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ul_haya/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NoorApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Noor ul Haya'), findsWidgets);
    expect(find.byIcon(Icons.mosque_outlined), findsOneWidget);
  });
}
