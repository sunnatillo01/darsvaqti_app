import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_local_data_source.dart';
import '../models/lesson_model.dart';

class LessonRepositoryImpl implements LessonRepository {
  LessonRepositoryImpl(this._ds);
  final LessonLocalDataSource _ds;

  @override
  Future<List<Lesson>> getAll() async =>
      (await _ds.read()).map(LessonModel.fromJson).toList();

  @override
  Future<void> save(Lesson lesson) async {
    final all = await getAll();
    final i = all.indexWhere((e) => e.id == lesson.id);
    i >= 0 ? all[i] = lesson : all.add(lesson);
    await _ds.write(all.map(LessonModel.toJson).toList());
  }

  @override
  Future<void> delete(int id) async {
    final all = await getAll()..removeWhere((e) => e.id == id);
    await _ds.write(all.map(LessonModel.toJson).toList());
  }
}
