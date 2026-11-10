// lib/theme/vet_colors.dart
// Paleta do VetHome.

import 'package:flutter/material.dart';

class VetColors {
  VetColors._();

  static const Color pink = Color(0xFFFAD3D5); // FAD3D5 (fundo, botões)
  static const Color rose = Color(0xFFC08081); // C08081 (header, cards)
  static const Color brown = Color(0xFF68442E); // 68442E (ícones, textos)
  // Contraste de 4,24:1 no fundo rosa composto do botão principal da Home.
  static const Color homePetControl = brown;
  // Contraste >= 4.5:1 para valores sobre o cartão rosa de Endereços.
  static const Color brownOnRoseCard = Color(0xFF603D28);
  // Contraste >= 4.5:1 sobre superfícies e gradientes rosa claros.
  static const Color brownOnRose = Color(0xFF573820);
  // Contraste >= 4.5:1 sobre o rosa sólido do calendário (#C08081).
  static const Color calendarTextOnRose = Color(0xFF352216);
  // Tinta escura usada para manter contraste em temas claros.
  static const Color contrastInk = Color(0xFF1A1210);
  static const Color chatMessageText = brownOnRose;

  /// Ajusta uma cor de texto até atingir o contraste pedido sobre a superfície.
  /// A cor se move em direção ao preto ou branco que oferece maior contraste,
  /// preservando o matiz sempre que possível.
  static Color textColorOn(
    Color foreground,
    Color background, {
    double minimumContrast = 4.5,
  }) {
    if (_contrastRatio(foreground, background) >= minimumContrast) {
      return foreground;
    }

    final endpoint =
        _contrastRatio(Colors.black, background) >=
            _contrastRatio(Colors.white, background)
        ? Colors.black
        : Colors.white;
    var lower = 0.0;
    var upper = 1.0;
    for (var iteration = 0; iteration < 20; iteration++) {
      final middle = (lower + upper) / 2;
      final candidate = Color.lerp(foreground, endpoint, middle)!;
      if (_contrastRatio(candidate, background) >= minimumContrast) {
        upper = middle;
      } else {
        lower = middle;
      }
    }
    return Color.lerp(foreground, endpoint, upper)!;
  }

  /// Escolhe branco ou tinta escura para elementos sobre uma cor sólida.
  static Color foregroundOn(Color background) {
    final darkContrast = _contrastRatio(contrastInk, background);
    final whiteContrast = _contrastRatio(Colors.white, background);
    return whiteContrast >= darkContrast ? Colors.white : contrastInk;
  }

  static double _contrastRatio(Color foreground, Color background) {
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    final lighter = foregroundLuminance > backgroundLuminance
        ? foregroundLuminance
        : backgroundLuminance;
    final darker = foregroundLuminance > backgroundLuminance
        ? backgroundLuminance
        : foregroundLuminance;
    return (lighter + .05) / (darker + .05);
  }

  // Cores e transparências dos nós do Figma Education.
  static const Color roseOverlay25 = Color.fromRGBO(192, 128, 129, .25);
  static const Color roseOverlay50 = Color.fromRGBO(192, 128, 129, .5);
  // O Figma usa 50%; .68 mantém o marrom e dá contraste 4.68:1 com texto branco.
  static const Color chatSentBubble = Color.fromRGBO(104, 68, 46, .68);
  static const Color pinkOverlay50 = Color.fromRGBO(250, 211, 213, .5);
  static const Color brownSecondary = Color.fromRGBO(104, 68, 46, .75);
  static const Color profileOutline = Color(0xFFB18B81);
  static const Color chatComposerBackground = Color(0xFFEBBEC0);
  static const Color petChoicePanel = Color(0xFFECBEC0);
  static const Color shadowDark = Color.fromRGBO(0, 0, 0, .25);

  // Realce existente, sem equivalente confirmado no Figma.
  static const Color shadowLight = Color(0x99FFFFFF);
}
