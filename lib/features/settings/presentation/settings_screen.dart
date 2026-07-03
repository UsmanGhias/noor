import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noor_ul_haya/core/config/app_config.dart';
import 'package:noor_ul_haya/core/config/router/app_router.dart';
import 'package:noor_ul_haya/core/providers/prayer_providers.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';

/// App settings and explore section.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prayerPreferencesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Explore more',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ExploreCard(
                  icon: '📖',
                  label: 'Quran',
                  onTap: () => context.push(AppRoutes.quran),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ExploreCard(
                  icon: '🤲',
                  label: 'Duas',
                  onTap: () => context.push(AppRoutes.duas),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ExploreCard(
                  icon: '📿',
                  label: 'Tasbih',
                  onTap: () => context.push(AppRoutes.tasbih),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Location',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Location'),
                  subtitle: Text('${prefs.manualCity.label}, Pakistan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.locationSettings),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.my_location_outlined),
                  title: const Text('Auto-detect location'),
                  subtitle: const Text(
                    'Use device location for accurate prayer times',
                  ),
                  value: prefs.autoDetectLocation,
                  activeThumbColor: AppColors.accentGreen,
                  onChanged: (value) {
                    ref.read(prayerPreferencesProvider.notifier).update(
                          (state) => state.copyWith(autoDetectLocation: value),
                        );
                    ref.invalidate(prayerScheduleProvider);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Prayer Calculation',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: const Text('Calculation method'),
              subtitle: Text(prefs.calculationMethod.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.locationSettings),
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(kAppName),
              subtitle: Text('Version $kAppVersion'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
