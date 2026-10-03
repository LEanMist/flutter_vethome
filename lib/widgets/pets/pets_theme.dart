// lib/widgets/pets/pets_theme.dart
// Constantes de tema standalone da PETS_PAGE.
// Sem dependência de app_export, ThemeHelper ou qualquer arquivo do projeto.

import 'package:flutter/material.dart';

/// Cores, fontes, escala e caminhos de assets usados pela PETS_PAGE.
class PetsTheme {
  PetsTheme._();

  // ── Cores ───────────────────────────────────────────────────────────────
  static const Color whiteA700 = Color(0xFFFFFFFF);
  static const Color red300 = Color(0xFFC08081);
  static const Color black900_3f = Color(0x3F000000);
  static const Color red100 = Color(0xFFFAD3D5);
  static const Color color33C080 = Color(0x33C08081);
  static const Color color3FC080 = Color(0x3FC08081);
  static const Color color7FC080 = Color(0x7FC08081);

  // ── Fontes ──────────────────────────────────────────────────────────────
  // Os nomes precisam ser IGUAIS aos `family:` declarados no pubspec.yaml.
  static const String fontComfortaa = 'Comfortaa';
  static const String fontMontserratAlternates = 'MontserratAlternates';

  // ── Escala responsiva ───────────────────────────────────────────────────
  static const double designWidth = 390.0;

  /// Fator de escala baseado na largura da tela (design de 390px).
  /// Limitado para o layout não ficar minúsculo/gigante em telas extremas.
  static double scaleOf(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return (width / designWidth).clamp(0.8, 1.4).toDouble();
  }

  // ── Caminhos de assets ──────────────────────────────────────────────────
  static const String _base = 'assets/imagens/pets/';

  static const String imgCachorroegatoPng = '${_base}img_cachorroegato_png.png';
  static const String imgCachorroegatoPng36x32 =
      '${_base}img_cachorroegato_png_36x32.png';
  static const String imgFrame48 = '${_base}img_frame_48.png';
  static const String imgFrame48WhiteA700 =
      '${_base}img_frame_48_white_a700.svg';
  static const String imgFrame49 = '${_base}img_frame_49.svg';
  static const String imgFrame50 = '${_base}img_frame_50.svg';
  static const String imgFrame51 = '${_base}img_frame_51.svg';
  static const String imgImage2 = '${_base}img_image_2.png';
  static const String imgVethomePng5 = '${_base}img_vethome_png_5.png';
  static const String imgImageNotFound = '${_base}image_not_found.png';
}
