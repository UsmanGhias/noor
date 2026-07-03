import 'package:adhan_dart/adhan_dart.dart';

class SurahEntry {
  const SurahEntry({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.verses,
    required this.translation,
  });

  final int number;
  final String name;
  final String arabicName;
  final int verses;
  final String translation;
}

class DuaEntry {
  const DuaEntry({
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
  });

  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;
}

abstract final class IslamicContent {
  static const surahs = [
    SurahEntry(
      number: 1,
      name: 'Al-Fatiha',
      arabicName: 'الفاتحة',
      verses: 7,
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. '
          'All praise is due to Allah, Lord of the worlds. The Entirely Merciful, '
          'the Especially Merciful. Master of the Day of Judgment.',
    ),
    SurahEntry(
      number: 112,
      name: 'Al-Ikhlas',
      arabicName: 'الإخلاص',
      verses: 4,
      translation:
          'Say, He is Allah, the One. Allah, the Eternal Refuge. '
          'He neither begets nor is born, nor is there to Him any equivalent.',
    ),
    SurahEntry(
      number: 113,
      name: 'Al-Falaq',
      arabicName: 'الفلق',
      verses: 5,
      translation:
          'Say, I seek refuge in the Lord of daybreak, from the evil of what He has created.',
    ),
    SurahEntry(
      number: 114,
      name: 'An-Nas',
      arabicName: 'الناس',
      verses: 6,
      translation:
          'Say, I seek refuge in the Lord of mankind, the Sovereign of mankind, '
          'the God of mankind.',
    ),
    SurahEntry(
      number: 36,
      name: 'Ya-Sin',
      arabicName: 'يس',
      verses: 83,
      translation:
          'Ya-Sin. By the wise Quran, indeed you are from the messengers, '
          'on a straight path.',
    ),
  ];

  static const duas = [
    DuaEntry(
      title: 'Before eating',
      arabic: 'بِسْمِ اللَّهِ',
      transliteration: 'Bismillah',
      translation: 'In the name of Allah.',
      reference: 'Sunnah',
    ),
    DuaEntry(
      title: 'After eating',
      arabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      transliteration:
          'Alhamdu lillahil-ladhi at\'amani hadha wa razaqanihi min ghayri haulin minni wa la quwwah',
      translation:
          'All praise is for Allah who fed me this and provided it for me without any might or power from myself.',
      reference: 'Tirmidhi',
    ),
    DuaEntry(
      title: 'Entering the home',
      arabic:
          'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
      transliteration:
          'Bismillahi walajna, wa bismillahi kharajna, wa \'alallahi rabbina tawakkalna',
      translation:
          'In the name of Allah we enter, in the name of Allah we leave, and upon our Lord we place our trust.',
      reference: 'Abu Dawud',
    ),
    DuaEntry(
      title: 'Before sleep',
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      transliteration: 'Bismika Allahumma amutu wa ahya',
      translation: 'In Your name O Allah, I die and I live.',
      reference: 'Bukhari',
    ),
    DuaEntry(
      title: 'For forgiveness',
      arabic:
          'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ',
      transliteration:
          'Rabbighfir li wa tub \'alayya innaka Antat-Tawwabur-Rahim',
      translation:
          'My Lord, forgive me and accept my repentance. Indeed, You are the Accepting of repentance, the Merciful.',
      reference: 'Abu Dawud',
    ),
    DuaEntry(
      title: 'When distressed',
      arabic: 'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      transliteration: 'La ilaha illa Anta Subhanaka inni kuntu minaz-zalimin',
      translation:
          'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
      reference: 'Quran 21:87',
    ),
  ];
}
