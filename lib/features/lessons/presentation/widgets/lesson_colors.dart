import 'package:flutter/painting.dart';

const _palette = [
  Color(0xFF2563EB), // ko'k
  Color(0xFF22C55E), // yashil
  Color(0xFF8B5CF6), // binafsha
  Color(0xFFF59E0B), // to'q sariq
  Color(0xFFEC4899), // pushti
  Color(0xFF14B8A6), // firuza
];

/// Fan + sinf bo'yicha barqaror rang.
Color lessonColor(String subject, String className) {
  var h = 0;
  for (final c in '${subject.trim()}|${className.trim()}'.toLowerCase().codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return _palette[h % _palette.length];
}
