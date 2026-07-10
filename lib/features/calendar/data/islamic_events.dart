class IslamicEvent {
  const IslamicEvent({
    required this.id,
    required this.hijriMonth,
    required this.hijriDay,
    required this.titleEn,
  });

  final String id;
  final int hijriMonth;
  final int hijriDay;
  final String titleEn;
}

const islamicEvents = <IslamicEvent>[
  IslamicEvent(
    id: 'new_year',
    hijriMonth: 1,
    hijriDay: 1,
    titleEn: 'Islamic New Year',
  ),
  IslamicEvent(
    id: 'ashura',
    hijriMonth: 1,
    hijriDay: 10,
    titleEn: 'Day of Ashura',
  ),
  IslamicEvent(
    id: 'ramadan',
    hijriMonth: 9,
    hijriDay: 1,
    titleEn: 'Ramadan begins',
  ),
  IslamicEvent(
    id: 'laylat_qadr',
    hijriMonth: 9,
    hijriDay: 27,
    titleEn: 'Laylat al-Qadr',
  ),
  IslamicEvent(
    id: 'eid_fitr',
    hijriMonth: 10,
    hijriDay: 1,
    titleEn: 'Eid al-Fitr',
  ),
  IslamicEvent(
    id: 'eid_adha',
    hijriMonth: 12,
    hijriDay: 10,
    titleEn: 'Eid al-Adha',
  ),
];
