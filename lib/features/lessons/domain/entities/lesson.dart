import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.subject,
    required this.className,
    required this.weekday,
    required this.hour,
    required this.minute,
    this.room = '',
    this.durationMinutes = 45,
    this.remindBefore = 15,
    this.repeatWeekly = true,
    this.onceDate,
    this.enabled = true,
  });

  final int id;
  final String subject;
  final String className; // masalan "9-A sinf"
  final int weekday; // 1..7
  final int hour;
  final int minute;
  final String room;
  final int durationMinutes;
  final int remindBefore; // daqiqa
  final bool repeatWeekly;
  final DateTime? onceDate; // repeatWeekly=false bo'lsa — dars sanasi
  final bool enabled; // eslatma yoqilganmi

  String get timeLabel => _fmt(hour * 60 + minute);
  String get endLabel => _fmt(hour * 60 + minute + durationMinutes);
  int get minutesOfDay => hour * 60 + minute;

  String get placeLabel => room.isEmpty ? className : '$className · $room';

  static String _fmt(int m) {
    final x = m % 1440;
    return '${(x ~/ 60).toString().padLeft(2, '0')}:${(x % 60).toString().padLeft(2, '0')}';
  }

  DateTime startOn(DateTime day) => DateTime(day.year, day.month, day.day, hour, minute);

  /// Dars shu kunda bo'ladimi?
  bool occursOn(DateTime day) {
    if (repeatWeekly) return day.weekday == weekday;
    final d = onceDate;
    return d != null && d.year == day.year && d.month == day.month && d.day == day.day;
  }

  /// Keyingi boshlanish vaqti (yo'q bo'lsa null).
  DateTime? nextStart(DateTime now) {
    if (repeatWeekly) {
      for (var i = 0; i < 8; i++) {
        final d = DateTime(now.year, now.month, now.day + i);
        final s = startOn(d);
        if (d.weekday == weekday && s.isAfter(now)) return s;
      }
      return null;
    }
    final d = onceDate;
    if (d == null) return null;
    final s = startOn(d);
    return s.isAfter(now) ? s : null;
  }

  /// Bir martalik dars uchun eng yaqin sana.
  static DateTime firstOccurrenceDate(int weekday, int hour, int minute, DateTime now) {
    for (var i = 0; i < 8; i++) {
      final d = DateTime(now.year, now.month, now.day + i);
      if (d.weekday == weekday && DateTime(d.year, d.month, d.day, hour, minute).isAfter(now)) {
        return d;
      }
    }
    return DateTime(now.year, now.month, now.day);
  }

  Lesson copyWith({
    String? subject,
    String? className,
    int? weekday,
    int? hour,
    int? minute,
    String? room,
    int? durationMinutes,
    int? remindBefore,
    bool? repeatWeekly,
    DateTime? onceDate,
    bool clearOnceDate = false,
    bool? enabled,
  }) =>
      Lesson(
        id: id,
        subject: subject ?? this.subject,
        className: className ?? this.className,
        weekday: weekday ?? this.weekday,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        room: room ?? this.room,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        remindBefore: remindBefore ?? this.remindBefore,
        repeatWeekly: repeatWeekly ?? this.repeatWeekly,
        onceDate: clearOnceDate ? null : (onceDate ?? this.onceDate),
        enabled: enabled ?? this.enabled,
      );

  @override
  List<Object?> get props => [
        id, subject, className, weekday, hour, minute, room,
        durationMinutes, remindBefore, repeatWeekly, onceDate, enabled,
      ];
}

class NextLesson {
  const NextLesson(this.lesson, this.start);
  final Lesson lesson;
  final DateTime start;
}
