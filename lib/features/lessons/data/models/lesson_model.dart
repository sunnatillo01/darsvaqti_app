import '../../domain/entities/lesson.dart';

class LessonModel {
  static Lesson fromJson(Map<String, dynamic> j) => Lesson(
        id: j['id'] as int,
        subject: j['subject'] as String,
        className: j['className'] as String,
        weekday: j['weekday'] as int,
        hour: j['hour'] as int,
        minute: j['minute'] as int,
        room: (j['room'] as String?) ?? '',
        durationMinutes: (j['durationMinutes'] as int?) ?? 45,
        remindBefore: (j['remindBefore'] as int?) ?? 15,
        repeatWeekly: (j['repeatWeekly'] as bool?) ?? true,
        onceDate: j['onceDate'] == null ? null : DateTime.parse(j['onceDate'] as String),
        enabled: (j['enabled'] as bool?) ?? true,
      );

  static Map<String, dynamic> toJson(Lesson l) => {
        'id': l.id,
        'subject': l.subject,
        'className': l.className,
        'weekday': l.weekday,
        'hour': l.hour,
        'minute': l.minute,
        'room': l.room,
        'durationMinutes': l.durationMinutes,
        'remindBefore': l.remindBefore,
        'repeatWeekly': l.repeatWeekly,
        'onceDate': l.onceDate?.toIso8601String(),
        'enabled': l.enabled,
      };
}
