import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';
import '../services/lesson_reminder_scheduler.dart';

class GetLessons {
  GetLessons(this._repo);
  final LessonRepository _repo;

  Future<List<Lesson>> call() async {
    final list = await _repo.getAll();
    list.sort((a, b) => a.weekday != b.weekday
        ? a.weekday.compareTo(b.weekday)
        : a.minutesOfDay.compareTo(b.minutesOfDay));
    return list;
  }
}

/// Saqlaydi va eslatmani yangilaydi (o'chiq bo'lsa bekor qiladi).
class SaveLesson {
  SaveLesson(this._repo, this._scheduler);
  final LessonRepository _repo;
  final LessonReminderScheduler _scheduler;

  Future<void> call(Lesson lesson) async {
    await _repo.save(lesson);
    if (lesson.enabled) {
      await _scheduler.schedule(lesson);
    } else {
      await _scheduler.cancel(lesson.id);
    }
  }
}

class DeleteLesson {
  DeleteLesson(this._repo, this._scheduler);
  final LessonRepository _repo;
  final LessonReminderScheduler _scheduler;

  Future<void> call(int id) async {
    await _repo.delete(id);
    await _scheduler.cancel(id);
  }
}

/// Ilova ochilganda barcha eslatmalarni qayta rejalashtiradi.
class RescheduleAllLessons {
  RescheduleAllLessons(this._repo, this._scheduler);
  final LessonRepository _repo;
  final LessonReminderScheduler _scheduler;

  Future<void> call() async => _scheduler.rescheduleAll(await _repo.getAll());
}

class RequestNotificationPermission {
  RequestNotificationPermission(this._scheduler);
  final LessonReminderScheduler _scheduler;
  Future<bool> call() => _scheduler.requestPermission();
}

class ShowTestNotification {
  ShowTestNotification(this._scheduler);
  final LessonReminderScheduler _scheduler;
  Future<void> call() => _scheduler.showTest();
}

/// "Eng yaqin dars" — sof mantiq, hech narsaga bog'liq emas.
class GetNextLesson {
  NextLesson? call(List<Lesson> lessons, DateTime now) {
    NextLesson? best;
    for (final l in lessons) {
      final s = l.nextStart(now);
      if (s == null) continue;
      if (best == null || s.isBefore(best.start)) best = NextLesson(l, s);
    }
    return best;
  }
}
