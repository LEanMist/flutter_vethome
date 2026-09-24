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

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title22BoldComfortaa => TextStyle(
    fontSize: 22.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Comfortaa',
    color: appTheme.gray_800,
  );

  TextStyle get title20RegularRoboto => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  TextStyle get title18BoldComfortaa => TextStyle(
    fontSize: 18.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Comfortaa',
    color: appTheme.gray_800,
  );

  TextStyle get title16Comfortaa => TextStyle(
    fontSize: 16.fSize,
    fontFamily: 'Comfortaa',
    color: appTheme.gray_800,
  );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14Comfortaa =>
      TextStyle(fontSize: 14.fSize, fontFamily: 'Comfortaa');

  // Other Styles
  // Miscellaneous text styles without specified font size

  TextStyle get bodyTextComfortaa =>
      TextStyle(fontFamily: 'Comfortaa', color: appTheme.gray_800);
}
