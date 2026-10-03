import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/vet_colors.dart';

class VH {
  VH._();

  static final ValueNotifier<Color> themeSeed = ValueNotifier(VetColors.brown);

  static const String headingFontFamily = 'Comfortaa';
  static const String bodyFontFamily = 'MontserratAlternates';

  static const Color background = VetColors.pink;
  static const Color card = Color(0xFFFFEEEE);
  static const Color muted = Color(0xFFF4C4C6);
  static const Color secondary = VetColors.rose;
  static const Color primary = VetColors.brown;
  static const Color accent = Color(0xFFD99A9B);
  static const Color foreground = VetColors.brown;
  static const Color onSecondary = Colors.white;
  static const Color mutedText = Color(0xFF8F7777);
  static const Color shadowSubtle = Color(0x22683F40);
  static const Color shadowSoft = Color(0x33683F40);

  static const double fieldHeight = 56;
  static const double headerHeight = 125;
  static const double radiusSmall = 10;
  static const double radiusCard = 20;
  static const double radiusLarge = 24;
  static const double radiusXLarge = 30;
  static const double radiusPill = 999;

  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(radiusCard),
  );
  static const BorderRadius headerBorderRadius = BorderRadius.vertical(
    bottom: Radius.circular(radiusLarge),
  );
  static const BorderRadius headerInsetBorderRadius = BorderRadius.vertical(
    top: Radius.circular(radiusXLarge),
    bottom: Radius.circular(radiusSmall),
  );
  static const BorderRadius pillBorderRadius = BorderRadius.all(
    Radius.circular(radiusPill),
  );
  static const BorderRadius sidePillBorderRadius = BorderRadius.horizontal(
    right: Radius.circular(radiusXLarge),
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [secondary, background],
  );

  static const List<BoxShadow> raise = [
    BoxShadow(color: shadowSoft, offset: Offset(3, 4), blurRadius: 8),
    BoxShadow(
      color: VetColors.shadowLight,
      offset: Offset(-2, -2),
      blurRadius: 6,
    ),
  ];
}

class VetTheme {
  VetTheme._();

  static ThemeData light(Color primaryColor) {
    final generatedScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      brightness: Brightness.light,
    );
    final colorScheme = generatedScheme.copyWith(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: VH.secondary,
      onSecondary: VH.onSecondary,
      onSurface: VH.foreground,
      outline: VH.secondary,
    );
    final baseTheme = ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: VH.background,
      useMaterial3: true,
    );
    final bodyTextTheme = GoogleFonts.montserratAlternatesTextTheme(
      baseTheme.textTheme,
    ).apply(bodyColor: VH.foreground, displayColor: VH.foreground);
    final headingTextTheme = GoogleFonts.comfortaaTextTheme(
      bodyTextTheme,
    ).apply(bodyColor: VH.foreground, displayColor: VH.foreground);

    return baseTheme.copyWith(
      textTheme: bodyTextTheme.copyWith(
        displayLarge: headingTextTheme.displayLarge,
        displayMedium: headingTextTheme.displayMedium,
        displaySmall: headingTextTheme.displaySmall,
        headlineLarge: headingTextTheme.headlineLarge,
        headlineMedium: headingTextTheme.headlineMedium,
        headlineSmall: headingTextTheme.headlineSmall,
        titleLarge: headingTextTheme.titleLarge,
      ),
    );
  }
}
