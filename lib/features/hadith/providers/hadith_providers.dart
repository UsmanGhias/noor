import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noor_ul_haya/features/hadith/data/hadith_api_service.dart';

final hadithApiProvider = Provider<HadithApiService>((ref) {
  return HadithApiService();
});

final hadithBooksProvider = FutureProvider<List<HadithBook>>((ref) async {
  return ref.watch(hadithApiProvider).getBooks();
});

final hadithListProvider =
    FutureProvider.family<List<HadithEntry>, String>((ref, bookId) async {
  return ref.watch(hadithApiProvider).getHadiths(bookId: bookId);
});

final dailyHadithProvider = FutureProvider<HadithEntry>((ref) async {
  return ref.watch(hadithApiProvider).dailyHadith();
});
