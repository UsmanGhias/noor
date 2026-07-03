import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noor_ul_haya/core/data/islamic_content.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';

/// Daily duas collection.
class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Duas')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: IslamicContent.duas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final dua = IslamicContent.duas[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _openDua(context, dua),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dua.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dua.arabic,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dua.reference,
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openDua(BuildContext context, DuaEntry dua) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dua.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                dua.arabic,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 24, height: 1.8),
              ),
              const SizedBox(height: 12),
              Text(
                dua.transliteration,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(dua.translation),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: dua.arabic));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dua copied')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Arabic'),
              ),
            ],
          ),
        );
      },
    );
  }
}
