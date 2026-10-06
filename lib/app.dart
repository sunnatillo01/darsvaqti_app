import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/lessons/presentation/cubit/lessons_cubit.dart';
import 'features/lessons/presentation/pages/lesson_form_page.dart';
import 'features/lessons/presentation/pages/main_shell.dart';

class DarsVaqtiApp extends StatefulWidget {
  const DarsVaqtiApp({super.key});

  @override
  State<DarsVaqtiApp> createState() => _DarsVaqtiAppState();
}

class _DarsVaqtiAppState extends State<DarsVaqtiApp> {
  final _navKey = GlobalKey<NavigatorState>();
  late final LessonsCubit _cubit = sl<LessonsCubit>();
  StreamSubscription<String>? _tapSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final notifications = sl<NotificationService>();
    _tapSub = notifications.onTap.listen(_openLesson);
    await _cubit.start();
    final launch = await notifications.getLaunchPayload(); // ilova yopiq paytda bosilgan
    if (launch != null) _openLesson(launch);
  }

  void _openLesson(String payload) {
    final id = int.tryParse(payload);
    final lesson = id == null ? null : _cubit.byId(id);
    if (lesson != null) {
      _navKey.currentState
          ?.push(MaterialPageRoute(builder: (_) => LessonFormPage(lesson: lesson)));
    }
  }

  @override
  void dispose() {
    _tapSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: MaterialApp(
        navigatorKey: _navKey,
        title: 'DarsVaqti',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MainShell(),
      ),
    );
  }
}
