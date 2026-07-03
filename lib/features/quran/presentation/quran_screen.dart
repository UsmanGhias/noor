import 'package:flutter/material.dart';
import 'package:noor_ul_haya/core/data/islamic_content.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';

/// Quran surah reader.
class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Quran')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: IslamicContent.surahs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final surah = IslamicContent.surahs[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _openSurah(context, surah),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.accentMint,
                      foregroundColor: AppColors.accentGreen,
                      child: Text('${surah.number}'),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${surah.verses} verses',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      surah.arabicName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
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

  void _openSurah(BuildContext context, SurahEntry surah) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _SurahDetailScreen(surah: surah),
      ),
    );
  }
}

class _SurahDetailScreen extends StatelessWidget {
  const _SurahDetailScreen({required this.surah});

  final SurahEntry surah;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: Text(surah.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            surah.arabicName,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            surah.translation,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
