import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class LessonLocalDataSource {
  Future<List<Map<String, dynamic>>> read();
  Future<void> write(List<Map<String, dynamic>> items);
}

class LessonLocalDataSourceImpl implements LessonLocalDataSource {
  LessonLocalDataSourceImpl(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'darsvaqti_lessons_v1';

  @override
  Future<List<Map<String, dynamic>>> read() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> write(List<Map<String, dynamic>> items) =>
      _prefs.setString(_key, jsonEncode(items));
}
