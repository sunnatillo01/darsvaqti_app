import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/uz_date.dart';
import '../cubit/lessons_cubit.dart';
import '../widgets/gradient_header_layout.dart';
import '../widgets/lesson_widgets.dart';
import 'lesson_form_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _selected = _today();

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LessonsCubit>();
    return BlocBuilder<LessonsCubit, LessonsState>(
      builder: (context, state) {
        final now = DateTime.now();
        final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        final all = List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));
        // Yakshanba faqat dars bo'lsa (yoki bugun bo'lsa) ko'rsatiladi.
        final days = all
            .where((d) =>
                d.weekday < 7 ||
                sameDay(d, _selected) ||
                state.lessons.any((l) => l.occursOn(d)))
            .toList();

        final lessons = state.lessons.where((l) => l.occursOn(_selected)).toList()
          ..sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));

        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () => LessonFormPage.open(context),
            child: const Icon(Icons.add),
          ),
          body: GradientHeaderLayout(
            gradientHeight: 170,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Haftalik jadval',
                      style: TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(monthYear(now),
                      style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12)),
                ]),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1F0F172A), blurRadius: 24, offset: Offset(0, 10)),
                  ],
                ),
                child: Row(children: [
                  for (final d in days)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _selected = d),
                        child: _DayChip(date: d, selected: sameDay(d, _selected)),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(fullDate(_selected),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              if (state.status == LessonsStatus.loading)
                const Padding(
                    padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
              else if (lessons.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text('Bu kunda dars yo\'q',
                      style: TextStyle(color: AppColors.text, fontSize: 13)),
                ),
              for (final l in lessons)
                Dismissible(
                  key: ValueKey('sch_${l.id}_${_selected.millisecondsSinceEpoch}'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async =>
                      await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Darsni o\'chirasizmi?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text('Yo\'q')),
                            TextButton(
                                onPressed: () => Navigator.pop(c, true), child: const Text('Ha')),
                          ],
                        ),
                      ) ??
                      false,
                  onDismissed: (_) => cubit.remove(l.id),
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.redAccent, borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ScheduleLessonCard(
                      lesson: l, onTap: () => LessonFormPage.open(context, l)),
                ),
              const SizedBox(height: 70), // FAB uchun joy
            ],
          ),
        );
      },
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.date, required this.selected});
  final DateTime date;
  final bool selected;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text(weekdayShort(date.weekday),
              style: TextStyle(
                  fontSize: 11, color: selected ? Colors.white70 : AppColors.text)),
          const SizedBox(height: 4),
          Text('${date.day}',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.dark)),
        ]),
      );
}
