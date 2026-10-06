import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/uz_date.dart';
import '../../domain/entities/lesson.dart';

class NextLessonCard extends StatelessWidget {
  const NextLessonCard({super.key, required this.next, required this.now, required this.onTap});

  final NextLesson next;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = next.lesson;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x1F0F172A), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.reminder,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Eng yaqin dars',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.dark)),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on_outlined, size: 15, color: AppColors.text),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(l.placeLabel,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: AppColors.text)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(l.timeLabel,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      Text('${l.endLabel} gacha',
                          style: const TextStyle(fontSize: 11, color: AppColors.text)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.reminderSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFFB45309)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(untilLabel(next.start, now),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF92400E))),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
