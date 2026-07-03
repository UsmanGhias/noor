import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noor_ul_haya/core/providers/prayer_providers.dart';
import 'package:noor_ul_haya/core/services/prayer_preferences_service.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';

/// Location and calculation method configuration.
class LocationSettingsScreen extends ConsumerStatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  ConsumerState<LocationSettingsScreen> createState() =>
      _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends ConsumerState<LocationSettingsScreen> {
  late bool _autoDetect;
  late PakistanCity _city;
  late CalculationMethodOption _method;
  late Madhab _madhab;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(prayerPreferencesProvider);
    _autoDetect = prefs.autoDetectLocation;
    _city = prefs.manualCity;
    _method = prefs.calculationMethod;
    _madhab = prefs.madhab;
  }

  Future<void> _apply() async {
    await ref.read(prayerPreferencesProvider.notifier).update(
          (prefs) => prefs.copyWith(
            autoDetectLocation: _autoDetect,
            manualCity: _city,
            calculationMethod: _method,
            madhab: _madhab,
          ),
        );
    ref.invalidate(prayerScheduleProvider);
    if (!mounted) {
      return;
    }
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location and calculation updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text('Location & Calculation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Auto Detect'),
              value: _autoDetect,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _autoDetect = value),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _autoDetect ? 'Fallback Location' : 'Set Location Manually',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PakistanCity>(
                    value: _city,
                    decoration: const InputDecoration(labelText: 'City'),
                    items: PakistanCity.values
                        .map(
                          (city) => DropdownMenuItem(
                            value: city,
                            child: Text(city.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _city = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calculation Methods & Madhhab',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CalculationMethodOption>(
                    value: _method,
                    decoration: const InputDecoration(labelText: 'Method'),
                    items: CalculationMethodOption.values
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(method.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _method = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Madhab>(
                    value: _madhab,
                    decoration: const InputDecoration(labelText: 'Madhhab'),
                    items: const [
                      DropdownMenuItem(
                        value: Madhab.shafi,
                        child: Text('Shafii/Maliki/Hanbali'),
                      ),
                      DropdownMenuItem(
                        value: Madhab.hanafi,
                        child: Text('Hanafi'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _madhab = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _apply,
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
