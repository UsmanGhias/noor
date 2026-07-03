import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noor_ul_haya/core/config/app_config.dart';
import 'package:noor_ul_haya/core/config/router/app_router.dart';
import 'package:noor_ul_haya/core/theme/app_theme.dart';

/// Root widget wiring theme, routing, and Riverpod.
class NoorApp extends ConsumerWidget {
  const NoorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
