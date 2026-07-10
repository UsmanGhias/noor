import 'dart:convert';

import 'package:http/http.dart' as http;

class HadithBook {
  const HadithBook({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.edition,
    required this.total,
  });

  final String id;
  final String name;
  final String nameAr;
  final String edition;
  final int total;
}

class HadithEntry {
  const HadithEntry({
    required this.bookId,
    required this.bookName,
    required this.number,
    required this.arabic,
    required this.english,
  });

  final String bookId;
  final String bookName;
  final int number;
  final String arabic;
  final String english;
}

class HadithApiService {
  HadithApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _cdn =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';

  static const books = <HadithBook>[
    HadithBook(
      id: 'bukhari',
      name: 'Sahih Bukhari',
      nameAr: 'صحيح البخاري',
      edition: 'eng-bukhari',
      total: 7563,
    ),
    HadithBook(
      id: 'muslim',
      name: 'Sahih Muslim',
      nameAr: 'صحيح مسلم',
      edition: 'eng-muslim',
      total: 7563,
    ),
    HadithBook(
      id: 'abudawud',
      name: 'Sunan Abu Dawud',
      nameAr: 'سنن أبي داود',
      edition: 'eng-abudawud',
      total: 5274,
    ),
    HadithBook(
      id: 'tirmidhi',
      name: 'Jami at-Tirmidhi',
      nameAr: 'جامع الترمذي',
      edition: 'eng-tirmidhi',
      total: 3956,
    ),
  ];

  static const fallbackHadiths = <HadithEntry>[
    HadithEntry(
      bookId: 'bukhari',
      bookName: 'Sahih Bukhari',
      number: 1,
      arabic:
          'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
      english:
          'Actions are according to intentions, and everyone will get what they intended.',
    ),
    HadithEntry(
      bookId: 'bukhari',
      bookName: 'Sahih Bukhari',
      number: 8,
      arabic:
          'بُنِيَ الإِسْلاَمُ عَلَى خَمْسٍ: شَهَادَةِ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَإِقَامِ الصَّلاَةِ، وَإِيتَاءِ الزَّكَاةِ، وَالْحَجِّ، وَصَوْمِ رَمَضَانَ',
      english:
          'Islam is built upon five: testifying there is no god but Allah and Muhammad is His Messenger, establishing prayer, giving zakat, pilgrimage, and fasting Ramadan.',
    ),
    HadithEntry(
      bookId: 'muslim',
      bookName: 'Sahih Muslim',
      number: 16,
      arabic:
          'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      english:
          'Whoever believes in Allah and the Last Day should speak good or remain silent.',
    ),
    HadithEntry(
      bookId: 'bukhari',
      bookName: 'Sahih Bukhari',
      number: 13,
      arabic:
          'لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      english:
          'None of you truly believes until he loves for his brother what he loves for himself.',
    ),
    HadithEntry(
      bookId: 'tirmidhi',
      bookName: 'Jami at-Tirmidhi',
      number: 2516,
      arabic: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ',
      english: 'Fear Allah wherever you are.',
    ),
    HadithEntry(
      bookId: 'muslim',
      bookName: 'Sahih Muslim',
      number: 2564,
      arabic: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
      english:
          'The Muslim is the one from whose tongue and hand the Muslims are safe.',
    ),
  ];

  Future<List<HadithBook>> getBooks() async {
    try {
      final response = await _client
          .get(Uri.parse('$_cdn/editions.min.json'))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        return books;
      }
      return books;
    } on Object {
      return books;
    }
  }

  Future<List<HadithEntry>> getHadiths({
    required String bookId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final book = books.firstWhere(
      (b) => b.id == bookId,
      orElse: () => books.first,
    );

    try {
      final engUri = Uri.parse('$_cdn/editions/${book.edition}.min.json');
      final araUri =
          Uri.parse('$_cdn/editions/ara-${book.id}.min.json');

      final results = await Future.wait([
        _client.get(engUri).timeout(const Duration(seconds: 20)),
        _client.get(araUri).timeout(const Duration(seconds: 20)),
      ]);

      if (results[0].statusCode != 200) {
        return _fallbackForBook(bookId);
      }

      final engJson = jsonDecode(results[0].body) as Map<String, dynamic>;
      final engHadiths = (engJson['hadiths'] as List<dynamic>? ?? []);

      Map<int, String> arabicByNumber = {};
      if (results[1].statusCode == 200) {
        final araJson = jsonDecode(results[1].body) as Map<String, dynamic>;
        for (final item in (araJson['hadiths'] as List<dynamic>? ?? [])) {
          final map = item as Map<String, dynamic>;
          final num = map['hadithnumber'];
          final n = num is int ? num : int.tryParse('$num') ?? 0;
          arabicByNumber[n] = (map['text'] as String? ?? '').trim();
        }
      }

      final start = (page - 1) * pageSize;
      if (start >= engHadiths.length) {
        return [];
      }
      final slice = engHadiths.skip(start).take(pageSize);

      return slice.map((item) {
        final map = item as Map<String, dynamic>;
        final num = map['hadithnumber'];
        final n = num is int ? num : int.tryParse('$num') ?? 0;
        return HadithEntry(
          bookId: book.id,
          bookName: book.name,
          number: n,
          arabic: arabicByNumber[n] ?? '',
          english: (map['text'] as String? ?? '').trim(),
        );
      }).where((h) => h.english.isNotEmpty).toList();
    } on Object {
      return _fallbackForBook(bookId);
    }
  }

  List<HadithEntry> _fallbackForBook(String bookId) {
    final filtered =
        fallbackHadiths.where((h) => h.bookId == bookId).toList();
    if (filtered.isNotEmpty) {
      return filtered;
    }
    return fallbackHadiths;
  }

  Future<HadithEntry> dailyHadith() async {
    final day = DateTime.now().difference(DateTime(2024)).inDays;
    return fallbackHadiths[day % fallbackHadiths.length];
  }
}
