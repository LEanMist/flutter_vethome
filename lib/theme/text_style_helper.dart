import 'package:flutter/material.dart';
import '../service/utils/app_export.dart';
import '../theme.dart';

class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }


  TextStyle get headline30BoldComfortaa => TextStyle(
    fontSize: 30.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: VH.headingFontFamily,
    color: appTheme.white_A700,
  );

  TextStyle get headline30BoldMontserratAlternates => TextStyle(
    fontSize: 30.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: VH.bodyFontFamily,
  );

  TextStyle get title20RegularRoboto => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  TextStyle get title20BoldComfortaa => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: VH.headingFontFamily,
    color: appTheme.white_A700,
  );

  TextStyle get label10BoldComfortaa => TextStyle(
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: VH.headingFontFamily,
    color: appTheme.white_A700,
  );
}
