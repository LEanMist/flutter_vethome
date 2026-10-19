import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/vet_colors.dart';

class VH {
  VH._();

  static final ValueNotifier<Color> themeSeed = ValueNotifier(VetColors.brown);

  static const String headingFontFamily = 'Comfortaa';
  static const String bodyFontFamily = 'MontserratAlternates';

  static const Color background = VetColors.pink;
  static const Color card = VetColors.roseOverlay50;
  static const Color muted = VetColors.roseOverlay25;
  static const Color secondary = VetColors.rose;
  static const Color primary = VetColors.brown;
  static const Color accent = Color(0xFFD99A9B);
  static const Color foreground = VetColors.brown;
  static const Color onSecondary = Colors.white;
  static const Color shadowSubtle = VetColors.shadowDark;
  static const Color shadowSoft = VetColors.shadowDark;

  static const double headerHeight = 125;
  static const double radiusSmall = 10;
  static const double radiusCard = 20;
  static const double radiusLarge = 24;
  static const double radiusXLarge = 30;
  static const double radiusPill = 999;

  // Limites compartilhados para as composições responsivas. As telas antigas
  // continuam compactas por padrão; telas aprovadas para desktop podem optar
  // pela largura ampla sem duplicar breakpoints.
  static const double compactBreakpoint = 600;
  static const double desktopBreakpoint = 900;
  static const double mobileContentMaxWidth = 600;
  static const double desktopContentMaxWidth = 1120;
  static const double desktopShellMaxWidth = 1200;

  static double pagePaddingFor(double width) {
    if (width >= desktopBreakpoint) return 32;
    if (width >= compactBreakpoint) return 24;
    return 16;
  }

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

  static TextStyle get figmaFieldValueStyle => GoogleFonts.comfortaa(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: foreground,
  );

  static TextStyle get figmaFieldLabelStyle => GoogleFonts.montserratAlternates(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: foreground,
  );

  static const TextStyle figmaButtonTextStyle = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: onSecondary,
  );

  static const List<BoxShadow> raise = [
    BoxShadow(color: shadowSoft, offset: Offset(2, 2), blurRadius: 2),
  ];

  static const List<BoxShadow> controlShadow = [
    BoxShadow(color: shadowSubtle, offset: Offset(2, 2), blurRadius: 2),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: shadowSubtle, offset: Offset(2, 2), blurRadius: 2),
  ];

  static Color? interactionOverlay(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return Colors.transparent;
    if (states.contains(WidgetState.pressed)) return muted;
    if (states.contains(WidgetState.focused)) return muted;
    if (states.contains(WidgetState.hovered)) {
      return secondary.withValues(alpha: .14);
    }
    return null;
  }
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
      surface: VH.background,
      onSurface: VH.foreground,
      outline: VH.secondary,
    );
    final baseTheme = ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: VH.background,
      useMaterial3: true,
      focusColor: VH.muted,
      hoverColor: VH.secondary.withValues(alpha: .14),
      splashColor: VH.muted,
      highlightColor: Colors.transparent,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VH.secondary.withValues(alpha: .12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: VH.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: VH.foreground, width: 2),
        ),
      ),
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
