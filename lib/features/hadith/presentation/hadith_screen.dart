import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';
import 'package:noor_ul_haya/features/hadith/data/hadith_api_service.dart';
import 'package:noor_ul_haya/features/hadith/providers/hadith_providers.dart';

class HadithScreen extends ConsumerStatefulWidget {
  const HadithScreen({super.key});

  @override
  ConsumerState<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends ConsumerState<HadithScreen> {
  String? _selectedBookId;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(hadithBooksProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        child: booksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _ErrorRetry(
            message: 'Could not load books',
            onRetry: () => ref.invalidate(hadithBooksProvider),
          ),
          data: (books) {
            final selectedId = _selectedBookId ?? books.first.id;
            final listAsync = ref.watch(hadithListProvider(selectedId));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hadith',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brandPrimary,
                                  ),
                            ),
                            const Text(
                              'Sahih Bukhari & Sahih Muslim',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search hadith',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v.trim()),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final selected = book.id == selectedId;
                      return ChoiceChip(
                        label: Text(book.name),
                        selected: selected,
                        selectedColor: AppColors.brandPrimary,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedBookId = book.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: listAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => _ErrorRetry(
                      message: 'Could not load hadith',
                      onRetry: () =>
                          ref.invalidate(hadithListProvider(selectedId)),
                    ),
                    data: (items) {
                      final filtered = _query.isEmpty
                          ? items
                          : items
                              .where(
                                (h) =>
                                    h.english
                                        .toLowerCase()
                                        .contains(_query.toLowerCase()) ||
                                    h.arabic.contains(_query) ||
                                    '${h.number}'.contains(_query),
                              )
                              .toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No hadith found'),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final hadith = filtered[index];
                          return _HadithCard(hadith: hadith);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  const _HadithCard({required this.hadith});

  final HadithEntry hadith;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetail(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentMint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${hadith.bookName} #${hadith.number}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      final text = [
                        if (hadith.arabic.isNotEmpty) hadith.arabic,
                        hadith.english,
                        '${hadith.bookName} #${hadith.number}',
                      ].join('\n\n');
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    color: AppColors.brandPrimary,
                  ),
                ],
              ),
              if (hadith.arabic.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  hadith.arabic,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                hadith.english,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(
              '${hadith.bookName} #${hadith.number}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.brandPrimary,
              ),
            ),
            if (hadith.arabic.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                hadith.arabic,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 24, height: 1.85),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              hadith.english,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                final text = [
                  if (hadith.arabic.isNotEmpty) hadith.arabic,
                  hadith.english,
                  '${hadith.bookName} #${hadith.number}',
                ].join('\n\n');
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied')),
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel_outlined,
                size: 48, color: AppColors.brandAccent),
            const SizedBox(height: 12),
            Text(message),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                minimumSize: const Size(180, 48),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
