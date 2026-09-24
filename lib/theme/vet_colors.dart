// lib/theme/vet_colors.dart
// Paleta do VetHome.

import 'package:flutter/material.dart';

class VetColors {
  VetColors._();

  static const Color gray = Color(0xFFD9D9D9); // D9D9D9
  static const Color pink = Color(0xFFF9D2D3); // F9D2D3 (fundo, botões)
  static const Color rose = Color(0xFFC08081); // C08081 (header, cards)
  static const Color brown = Color(0xFF68442E); // 68442E (ícones, textos)

  // Derivadas da paleta (para o efeito neumórfico)
  static const Color roseDark = Color(0xFFA96C6D); // aba do "° w °"
  static const Color shadowDark = Color(0x55683F40);
  static const Color shadowLight = Color(0x99FFFFFF);
}
