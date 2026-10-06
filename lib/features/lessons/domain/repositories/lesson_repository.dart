import '../entities/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getAll();
  Future<void> save(Lesson lesson);
  Future<void> delete(int id);
}
