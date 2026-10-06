import 'package:flutter_test/flutter_test.dart';

import 'package:darsvaqti_app/core/utils/uz_date.dart';
import 'package:darsvaqti_app/features/lessons/domain/entities/lesson.dart';
import 'package:darsvaqti_app/features/lessons/domain/usecases/lesson_usecases.dart';

Lesson _lesson({
  int id = 1,
  int weekday = DateTime.monday,
  int hour = 9,
  int minute = 0,
  bool repeat = true,
  DateTime? once,
}) =>
    Lesson(
      id: id,
      subject: 'Matematika',
      className: '9-A sinf',
      weekday: weekday,
      hour: hour,
      minute: minute,
      repeatWeekly: repeat,
      onceDate: once,
    );

void main() {
  // 2026-yil 5-oktabr — dushanba
  final mondayMorning = DateTime(2026, 10, 5, 8, 31);

  group('Lesson', () {
    test('tugash vaqti davomiylikdan hisoblanadi', () {
      expect(_lesson().endLabel, '09:45');
    });

    test('haftalik dars bugun hali boshlanmagan bo\'lsa — bugun', () {
      expect(_lesson().nextStart(mondayMorning), DateTime(2026, 10, 5, 9, 0));
    });

    test('haftalik dars boshlanib bo\'lgan bo\'lsa — keyingi hafta', () {
      final now = DateTime(2026, 10, 5, 9, 30);
      expect(_lesson().nextStart(now), DateTime(2026, 10, 12, 9, 0));
    });

    test('bir martalik dars o\'tib ketgan bo\'lsa — null', () {
      final l = _lesson(repeat: false, once: DateTime(2026, 10, 1));
      expect(l.nextStart(mondayMorning), isNull);
    });

    test('firstOccurrenceDate keyingi mos kunni topadi', () {
      final now = DateTime(2026, 10, 5, 10, 0); // dars vaqti o'tgan
      expect(Lesson.firstOccurrenceDate(DateTime.monday, 9, 0, now), DateTime(2026, 10, 12));
    });
  });

  group('GetNextLesson', () {
    test('eng yaqin darsni tanlaydi', () {
      final lessons = [_lesson(id: 1, hour: 13), _lesson(id: 2, hour: 9)];
      final next = GetNextLesson()(lessons, mondayMorning);
      expect(next?.lesson.id, 2);
    });

    test('darslar bo\'lmasa — null', () {
      expect(GetNextLesson()([], mondayMorning), isNull);
    });
  });

  group('uz_date', () {
    test('29 daqiqadan keyin', () {
      expect(untilLabel(DateTime(2026, 10, 5, 9, 0), mondayMorning),
          '29 daqiqadan keyin boshlanadi');
    });

    test('sana formati', () {
      expect(fullDate(DateTime(2026, 10, 5)), 'Dushanba, 5-oktabr');
      expect(monthYear(DateTime(2026, 10, 5)), 'Oktabr, 2026');
    });
  });
}