part of 'lessons_cubit.dart';

enum LessonsStatus { loading, ready, failure }

class LessonsState extends Equatable {
  const LessonsState({
    this.status = LessonsStatus.loading,
    this.lessons = const [],
    this.message,
  });

  final LessonsStatus status;
  final List<Lesson> lessons;
  final String? message; // snackbar uchun xabar

  LessonsState copyWith({LessonsStatus? status, List<Lesson>? lessons, String? message}) =>
      LessonsState(
        status: status ?? this.status,
        lessons: lessons ?? this.lessons,
        message: message,
      );

  @override
  List<Object?> get props => [status, lessons, message];
}
