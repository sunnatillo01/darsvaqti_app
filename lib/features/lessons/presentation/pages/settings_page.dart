import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/lessons_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LessonsCubit>();
    Widget tile(IconData icon, String title, String sub, VoidCallback onTap) => ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.background,
            child: Icon(icon, color: AppColors.primary),
          ),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.text)),
          onTap: onTap,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          tile(Icons.notifications_outlined, 'Bildirishnomaga ruxsat',
              'Ruxsat so\'rash / holatni tekshirish', () async {
            final ok = await cubit.askPermission();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Ruxsat berilgan ✅' : 'Ruxsat berilmagan. Telefon sozlamalaridan yoqing.')));
            }
          }),
          tile(Icons.send_outlined, 'Test bildirishnoma', 'Hoziroq namunani yuborish', cubit.sendTest),
          tile(Icons.sync, 'Eslatmalarni yangilash', 'Barcha eslatmalarni qayta rejalashtirish',
              cubit.reschedule),
          tile(Icons.info_outline, 'Ilova haqida', 'DarsVaqti 1.0.0', () {
            showAboutDialog(
              context: context,
              applicationName: 'DarsVaqti',
              applicationVersion: '1.0.0',
              children: const [Text('Ustozlar uchun dars jadvali va eslatma ilovasi.')],
            );
          }),
        ],
      ),
    );
  }
}
