const _weekdays = [
  'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba',
];
const _short = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
const _months = [
  'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
  'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr',
];

/// 1 = Dushanba ... 7 = Yakshanba
String weekdayName(int weekday) => _weekdays[weekday - 1];
String weekdayShort(int weekday) => _short[weekday - 1];

String two(int n) => n.toString().padLeft(2, '0');

/// Daqiqalarni (0..1439+) "HH:mm" ga aylantiradi.
String hm(int minutes) {
  final m = minutes % (24 * 60);
  return '${two(m ~/ 60)}:${two(m % 60)}';
}

/// "Dushanba, 5-oktabr"
String fullDate(DateTime d) => '${weekdayName(d.weekday)}, ${d.day}-${_months[d.month - 1]}';

/// "Oktabr, 2026"
String monthYear(DateTime d) {
  final m = _months[d.month - 1];
  return '${m[0].toUpperCase()}${m.substring(1)}, ${d.year}';
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// "29 daqiqadan keyin boshlanadi" ko'rinishidagi matn.
String untilLabel(DateTime start, DateTime now) {
  final diff = start.difference(now);
  if (diff.inMinutes < 1) return 'Hozir boshlanadi';
  if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqadan keyin boshlanadi';
  final time = '${two(start.hour)}:${two(start.minute)}';
  if (sameDay(start, now)) {
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return m == 0 ? '$h soatdan keyin boshlanadi' : '$h soat $m daqiqadan keyin boshlanadi';
  }
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  if (sameDay(start, tomorrow)) return 'Ertaga $time da boshlanadi';
  return '${weekdayName(start.weekday)} kuni $time da boshlanadi';
}
