import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/uz_date.dart';
import '../cubit/lessons_cubit.dart';
import '../widgets/gradient_header_layout.dart';
import '../widgets/lesson_widgets.dart';
import '../widgets/next_lesson_card.dart';
import 'lesson_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onOpenReminders});
  final VoidCallback onOpenReminders;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // "29 daqiqadan keyin" matni yangilanib turishi uchun.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LessonsCubit>();
    return BlocBuilder<LessonsCubit, LessonsState>(
      builder: (context, state) {
        if (state.status == LessonsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == LessonsStatus.failure) {
          return Center(
              child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
                  onPressed: cubit.start,
                  child: const Text('Qayta urinish')));
        }

        final now = DateTime.now();
        final today = state.lessons.where((l) => l.occursOn(now)).toList()
          ..sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));
        final next = cubit.nextLesson(now);

        return Scaffold(
          backgroundColor: Colors.white,
          body: GradientHeaderLayout(
            gradientHeight: 150,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Salom, ustoz!',
                          style: TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(fullDate(now),
                          style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12)),
                    ]),
                  ),
                  InkWell(
                    onTap: widget.onOpenReminders,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Stack(children: [
                        const Icon(Icons.notifications_none_rounded,
                            color: Colors.white, size: 26),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                                color: AppColors.reminder, shape: BoxShape.circle),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 22),
              if (next != null)
                NextLessonCard(
                  next: next,
                  now: now,
                  onTap: () => LessonFormPage.open(context, next.lesson),
                )
              else
                _EmptyCard(onAdd: () => LessonFormPage.open(context)),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  const Expanded(
                    child: Text('Bugungi darslar',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  Text('${today.length} ta',
                      style: const TextStyle(fontSize: 12, color: AppColors.text)),
                ]),
              ),
              const SizedBox(height: 6),
              if (today.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Text('Bugun darslar yo\'q 🎉',
                      style: TextStyle(color: AppColors.text, fontSize: 13)),
                ),
              for (final l in today)
                TodayLessonTile(lesson: l, onTap: () => LessonFormPage.open(context, l)),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x1F0F172A), blurRadius: 24, offset: Offset(0, 10)),
          ],
        ),
        child: Column(children: [
          const Text('Yaqin darslar yo\'q',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Birinchi darsingizni qo\'shing',
              style: TextStyle(fontSize: 12, color: AppColors.text)),
          const SizedBox(height: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Dars qo\'shish'),
          ),
        ]),
      );
}
