import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/lesson.dart';
import 'lesson_colors.dart';

const _cardShadow = [
  BoxShadow(color: Color(0x0F0F172A), blurRadius: 10, offset: Offset(0, 3)),
];

/// "Bugungi darslar" ro'yxati uchun qator.
class TodayLessonTile extends StatelessWidget {
  const TodayLessonTile({super.key, required this.lesson, required this.onTap});
  final Lesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = lessonColor(lesson.subject, lesson.className);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: _cardShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              width: 4,
              height: 42,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 46,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(lesson.timeLabel,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text(lesson.endLabel,
                    style: const TextStyle(fontSize: 11, color: AppColors.text)),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(lesson.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(lesson.className,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.text)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: AppColors.text),
          ]),
        ),
      ),
    );
  }
}

/// "Haftalik jadval" kartasi: rangli chiziq, vaqt oralig'i, qo'ng'iroq belgisi.
class ScheduleLessonCard extends StatelessWidget {
  const ScheduleLessonCard({super.key, required this.lesson, required this.onTap});
  final Lesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = lessonColor(lesson.subject, lesson.className);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: _cardShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              width: 4,
              height: 56,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${lesson.timeLabel} – ${lesson.endLabel}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                const SizedBox(height: 2),
                Text(lesson.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(lesson.placeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.text)),
              ]),
            ),
            Icon(
              lesson.enabled ? Icons.notifications_active : Icons.notifications_off_outlined,
              size: 20,
              color: lesson.enabled ? AppColors.reminder : AppColors.text,
            ),
          ]),
        ),
      ),
    );
  }
}
