import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline30BoldComfortaa => TextStyle(
    fontSize: 30.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Comfortaa',
    color: appTheme.white_A700,
  );

  TextStyle get headline30BoldMontserratAlternates => TextStyle(
    fontSize: 30.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'MontserratAlternates',
  );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  TextStyle get title20BoldComfortaa => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Comfortaa',
    color: appTheme.white_A700,
  );

  // Label Styles
  // Small text styles for labels, captions, and hints

  TextStyle get label10BoldComfortaa => TextStyle(
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Comfortaa',
    color: appTheme.white_A700,
  );
}
