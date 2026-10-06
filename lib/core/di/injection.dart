import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/lessons/data/datasources/lesson_local_data_source.dart';
import '../../features/lessons/data/repositories/lesson_repository_impl.dart';
import '../../features/lessons/data/services/lesson_reminder_scheduler_impl.dart';
import '../../features/lessons/domain/repositories/lesson_repository.dart';
import '../../features/lessons/domain/services/lesson_reminder_scheduler.dart';
import '../../features/lessons/domain/usecases/lesson_usecases.dart';
import '../../features/lessons/presentation/cubit/lessons_cubit.dart';
import '../notifications/local_notification_service.dart';
import '../notifications/notification_service.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  final notifications = LocalNotificationService(FlutterLocalNotificationsPlugin());
  await notifications.init();
  sl.registerSingleton<NotificationService>(notifications);

  sl.registerLazySingleton<LessonLocalDataSource>(() => LessonLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<LessonRepository>(() => LessonRepositoryImpl(sl()));
  sl.registerLazySingleton<LessonReminderScheduler>(() => LessonReminderSchedulerImpl(sl()));

  sl.registerLazySingleton(() => GetLessons(sl()));
  sl.registerLazySingleton(() => SaveLesson(sl(), sl()));
  sl.registerLazySingleton(() => DeleteLesson(sl(), sl()));
  sl.registerLazySingleton(() => RescheduleAllLessons(sl(), sl()));
  sl.registerLazySingleton(() => RequestNotificationPermission(sl()));
  sl.registerLazySingleton(() => ShowTestNotification(sl()));
  sl.registerLazySingleton(() => GetNextLesson());

  sl.registerLazySingleton(() => LessonsCubit(
        getLessons: sl(),
        saveLesson: sl(),
        deleteLesson: sl(),
        rescheduleAll: sl(),
        requestPermission: sl(),
        showTest: sl(),
        getNextLesson: sl(),
      ));
}
