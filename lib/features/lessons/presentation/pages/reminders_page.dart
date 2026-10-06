import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/uz_date.dart';
import '../cubit/lessons_cubit.dart';
import 'lesson_form_page.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LessonsCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Eslatmalar'), centerTitle: false),
      body: BlocBuilder<LessonsCubit, LessonsState>(
        builder: (context, state) {
          final now = DateTime.now();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.reminderSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  const Icon(Icons.notifications_active, color: Color(0xFFB45309)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Eslatmalar to\'g\'ri ishlashini tekshiring',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  TextButton(onPressed: cubit.sendTest, child: const Text('Test')),
                ]),
              ),
              const SizedBox(height: 16),
              if (state.lessons.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                      child: Text('Hali eslatma yo\'q',
                          style: TextStyle(color: AppColors.text))),
                ),
              for (final l in state.lessons)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    onTap: () => LessonFormPage.open(context, l),
                    title: Text('${l.subject} • ${l.className}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      () {
                        final s = l.nextStart(now);
                        final when = s == null
                            ? 'O\'tib ketgan'
                            : '${weekdayName(s.weekday)} ${l.timeLabel}';
                        return '$when • ${l.remindBefore} daqiqa oldin'
                            '${l.repeatWeekly ? ' • har hafta' : ''}';
                      }(),
                      style: const TextStyle(fontSize: 11, color: AppColors.text),
                    ),
                    trailing: Switch(value: l.enabled, onChanged: (_) => cubit.toggle(l)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
