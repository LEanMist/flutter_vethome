import 'package:flutter/material.dart';

import 'theme/vet_colors.dart';

class VH {
  VH._();

  static final ValueNotifier<Color> themeSeed = ValueNotifier(VetColors.brown);

  static const Color background = VetColors.pink;
  static const Color card = Color(0xFFFFEEEE);
  static const Color muted = Color(0xFFF4C4C6);
  static const Color secondary = VetColors.rose;
  static const Color primary = VetColors.brown;
  static const Color accent = Color(0xFFD99A9B);
  static const Color foreground = VetColors.brown;
  static const Color onSecondary = Colors.white;
  static const Color mutedText = Color(0xFF8F7777);

  static const List<BoxShadow> raise = [
    BoxShadow(color: Color(0x33683F40), offset: Offset(3, 4), blurRadius: 8),
    BoxShadow(color: Color(0x99FFFFFF), offset: Offset(-2, -2), blurRadius: 6),
  ];
}
