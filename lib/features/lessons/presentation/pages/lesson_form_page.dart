import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/uz_date.dart';
import '../../domain/entities/lesson.dart';
import '../cubit/lessons_cubit.dart';

class LessonFormPage extends StatefulWidget {
  const LessonFormPage({super.key, this.lesson});
  final Lesson? lesson;

  static Future<void> open(BuildContext context, [Lesson? lesson]) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => LessonFormPage(lesson: lesson)));

  @override
  State<LessonFormPage> createState() => _LessonFormPageState();
}

class _LessonFormPageState extends State<LessonFormPage> {
  static const _reminders = [5, 15, 30];
  static const _durations = [45, 60, 90];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subject;
  late final TextEditingController _class;
  late final TextEditingController _room;
  late int _weekday;
  late TimeOfDay _time;
  late int _duration;
  late int _remind;
  late bool _repeat;
  late bool _enabled;

  bool get _editing => widget.lesson != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lesson;
    _subject = TextEditingController(text: l?.subject);
    _class = TextEditingController(text: l?.className);
    _room = TextEditingController(text: l?.room);
    _weekday = l?.weekday ?? DateTime.now().weekday;
    _time = TimeOfDay(hour: l?.hour ?? 9, minute: l?.minute ?? 0);
    _duration = l?.durationMinutes ?? 45;
    _remind = l?.remindBefore ?? 15;
    _repeat = l?.repeatWeekly ?? true;
    _enabled = l?.enabled ?? true;
  }

  @override
  void dispose() {
    _subject.dispose();
    _class.dispose();
    _room.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t != null) setState(() => _time = t);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final id = widget.lesson?.id ?? now.millisecondsSinceEpoch % 2147483647;
    context.read<LessonsCubit>().save(Lesson(
          id: id,
          subject: _subject.text.trim(),
          className: _class.text.trim(),
          room: _room.text.trim(),
          weekday: _weekday,
          hour: _time.hour,
          minute: _time.minute,
          durationMinutes: _duration,
          remindBefore: _remind,
          repeatWeekly: _repeat,
          onceDate: _repeat
              ? null
              : Lesson.firstOccurrenceDate(_weekday, _time.hour, _time.minute, now),
          enabled: _enabled,
        ));
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Darsni o\'chirasizmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Yo\'q')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Ha')),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<LessonsCubit>().remove(widget.lesson!.id);
      Navigator.of(context).pop();
    }
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'To\'ldiring' : null;

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 14),
        child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.text)),
      );

  Widget _chips(List<int> values, int selected, String Function(int) text, ValueChanged<int> on) {
    return Wrap(
      spacing: 10,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(text(v)),
            selected: selected == v,
            showCheckmark: false,
            onSelected: (_) => on(v),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.background,
            side: BorderSide.none,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected == v ? Colors.white : AppColors.dark,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Darsni tahrirlash' : 'Dars qo\'shish'),
        actions: [
          if (_editing)
            IconButton(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  _label('Fan nomi'),
                  TextFormField(
                      controller: _subject,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Masalan, Matematika'),
                      validator: _required),
                  _label('Sinf'),
                  TextFormField(
                      controller: _class,
                      decoration: const InputDecoration(hintText: 'Masalan, 9-A'),
                      validator: _required),
                  _label('Xona'),
                  TextFormField(
                      controller: _room,
                      decoration: const InputDecoration(hintText: 'Masalan, 12-xona')),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _label('Kun'),
                          DropdownButtonFormField<int>(
                            value: _weekday,
                            isExpanded: true,
                            items: [
                              for (var d = 1; d <= 7; d++)
                                DropdownMenuItem(value: d, child: Text(weekdayName(d))),
                            ],
                            onChanged: (v) => setState(() => _weekday = v ?? _weekday),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _label('Vaqti'),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _pickTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.access_time, size: 20)),
                              child: Text('${two(_time.hour)}:${two(_time.minute)}'),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                  _label('Davomiyligi'),
                  _chips(_durations, _duration, (v) => '$v daqiqa', (v) => setState(() => _duration = v)),
                  _label('Necha daqiqa oldin eslatilsin?'),
                  _chips(_reminders, _remind, (v) => '$v daqiqa', (v) => setState(() => _remind = v)),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.repeat, color: AppColors.primary),
                        title: const Text('Har hafta takrorlash', style: TextStyle(fontSize: 14)),
                        value: _repeat,
                        onChanged: (v) => setState(() => _repeat = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary:
                            const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                        title: const Text('Eslatma yoqilgan', style: TextStyle(fontSize: 14)),
                        value: _enabled,
                        onChanged: (v) => setState(() => _enabled = v),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: FilledButton(onPressed: _submit, child: const Text('Saqlash')),
            ),
          ),
        ],
      ),
    );
  }
}
