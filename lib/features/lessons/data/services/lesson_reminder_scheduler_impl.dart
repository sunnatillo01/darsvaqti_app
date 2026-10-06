import '../../../../core/notifications/notification_service.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/services/lesson_reminder_scheduler.dart';

class LessonReminderSchedulerImpl implements LessonReminderScheduler {
  LessonReminderSchedulerImpl(this._notifications);
  final NotificationService _notifications;

  @override
  Future<bool> requestPermission() => _notifications.requestPermission();

  @override
  Future<void> schedule(Lesson l) async {
    const title = 'Dars yaqinlashmoqda';
    final room = l.room.isEmpty ? '' : ' • ${l.room}';
    final body = '${l.className}, ${l.subject}$room boshlanadi. '
        '${l.remindBefore} daqiqa qoldi.';

    if (l.repeatWeekly) {
      // Dars vaqtidan `remindBefore` daqiqa oldin; kun o'tib ketsa oldingi kunga suriladi.
      var minutes = l.minutesOfDay - l.remindBefore;
      var day = l.weekday;
      if (minutes < 0) {
        minutes += 24 * 60;
        day = day == 1 ? 7 : day - 1;
      }
      await _notifications.scheduleWeekly(
        id: l.id,
        title: title,
        body: body,
        weekday: day,
        hour: minutes ~/ 60,
        minute: minutes % 60,
        payload: l.id.toString(),
      );
      return;
    }

    final now = DateTime.now();
    final start = l.nextStart(now);
    final at = start?.subtract(Duration(minutes: l.remindBefore));
    if (at == null || !at.isAfter(now)) {
      await _notifications.cancel(l.id);
      return;
    }
    await _notifications.scheduleOnce(
      id: l.id,
      title: title,
      body: body,
      at: at,
      payload: l.id.toString(),
    );
  }

  @override
  Future<void> cancel(int lessonId) => _notifications.cancel(lessonId);

  @override
  Future<void> rescheduleAll(List<Lesson> lessons) async {
    await _notifications.cancelAll();
    for (final l in lessons.where((e) => e.enabled)) {
      await schedule(l);
    }
  }

  @override
  Future<void> showTest() => _notifications.showNow(
        id: 0,
        title: 'Dars yaqinlashmoqda',
        body: '9-A sinf, Matematika • 12-xona boshlanadi. 15 daqiqa qoldi.',
      );
}
