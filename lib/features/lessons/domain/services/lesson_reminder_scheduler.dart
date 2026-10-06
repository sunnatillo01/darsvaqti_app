import '../entities/lesson.dart';

abstract class LessonReminderScheduler {
  Future<bool> requestPermission();
  Future<void> schedule(Lesson lesson);
  Future<void> cancel(int lessonId);
  Future<void> rescheduleAll(List<Lesson> lessons);
  Future<void> showTest();
}
