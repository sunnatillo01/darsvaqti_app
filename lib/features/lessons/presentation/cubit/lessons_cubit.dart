import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/lesson.dart';
import '../../domain/usecases/lesson_usecases.dart';

part 'lessons_state.dart';

class LessonsCubit extends Cubit<LessonsState> {
  LessonsCubit({
    required this.getLessons,
    required this.saveLesson,
    required this.deleteLesson,
    required this.rescheduleAll,
    required this.requestPermission,
    required this.showTest,
    required this.getNextLesson,
  }) : super(const LessonsState());

  final GetLessons getLessons;
  final SaveLesson saveLesson;
  final DeleteLesson deleteLesson;
  final RescheduleAllLessons rescheduleAll;
  final RequestNotificationPermission requestPermission;
  final ShowTestNotification showTest;
  final GetNextLesson getNextLesson;

 Future<void> start() async {
  await _reload(); // ekran darhol ochiladi

  try {
    final granted = await requestPermission();
    await rescheduleAll();
    if (!granted) {
      emit(state.copyWith(
          message: 'Bildirishnomalarga ruxsat berilmagan. Sozlamalardan yoqing.'));
    }
   } catch (e) {
    emit(state.copyWith(message: 'Eslatma xatosi: $e'));
  }
}

  Future<void> reschedule() async {
    await rescheduleAll();
    emit(state.copyWith(message: 'Eslatmalar yangilandi'));
  }

  Future<void> _reload({String? message}) async {
    try {
      final list = await getLessons();
      emit(state.copyWith(status: LessonsStatus.ready, lessons: list, message: message));
    } catch (_) {
      emit(state.copyWith(status: LessonsStatus.failure, message: 'Xatolik yuz berdi'));
    }
  }

  Future<void> save(Lesson lesson) async {
  try {
    await saveLesson(lesson);
    await _reload(message: 'Saqlandi');
  } catch (e) {
    await _reload(message: 'Eslatma xatosi: $e');
  }
}

  Future<void> remove(int id) async {
    await deleteLesson(id);
    await _reload(message: 'O\'chirildi');
  }

  Future<void> toggle(Lesson lesson) => save(lesson.copyWith(enabled: !lesson.enabled));

  Future<bool> askPermission() => requestPermission();

  Future<void> sendTest() async {
    final ok = await requestPermission();
    if (ok) {
      await showTest();
    } else {
      emit(state.copyWith(message: 'Bildirishnomalarga ruxsat berilmagan'));
    }
  }

  NextLesson? nextLesson(DateTime now) => getNextLesson(state.lessons, now);

  Lesson? byId(int id) {
    for (final l in state.lessons) {
      if (l.id == id) return l;
    }
    return null;
  }
}
