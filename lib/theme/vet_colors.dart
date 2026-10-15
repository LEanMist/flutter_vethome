// lib/theme/vet_colors.dart
// Paleta do VetHome.

import 'package:flutter/material.dart';

class VetColors {
  VetColors._();

  static const Color pink = Color(0xFFFAD3D5); // FAD3D5 (fundo, botões)
  static const Color rose = Color(0xFFC08081); // C08081 (header, cards)
  static const Color brown = Color(0xFF68442E); // 68442E (ícones, textos)

  // Cores e transparências dos nós do Figma Education.
  static const Color roseOverlay25 = Color.fromRGBO(192, 128, 129, .25);
  static const Color roseOverlay50 = Color.fromRGBO(192, 128, 129, .5);
  static const Color pinkOverlay50 = Color.fromRGBO(250, 211, 213, .5);
  static const Color brownSecondary = Color.fromRGBO(104, 68, 46, .75);
  static const Color profileOutline = Color(0xFFB18B81);
  static const Color chatComposerBackground = Color(0xFFEBBEC0);
  static const Color shadowDark = Color.fromRGBO(0, 0, 0, .25);

  // Realce existente, sem equivalente confirmado no Figma.
  static const Color shadowLight = Color(0x99FFFFFF);
}
