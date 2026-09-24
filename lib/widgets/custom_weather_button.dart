import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// CustomWeatherButton is a stylized button component with custom border radius,
/// background color, shadow, and Montserrat Alternates typography.
///
/// Parameters:
/// - [text]: The label text displayed on the button.
/// - [onTap]: Callback triggered when the button is tapped.
/// - [width]: The width of the button (required).
/// - [textColor]: The color of the button text.
/// - [backgroundColor]: The background color of the button.
class CustomWeatherButton extends StatelessWidget {
  const CustomWeatherButton({
    Key? key,
    required this.width,
    this.text,
    this.onTap,
    this.textColor,
    this.backgroundColor,
  }) : super(key: key);

  /// The width of the button (required for proper sizing)
  final double width;

  /// The label text displayed on the button
  final String? text;

  /// Callback triggered when the button is tapped
  final VoidCallback? onTap;

  /// The color of the button text
  final Color? textColor;

  /// The background color of the button
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackgroundColor =
        backgroundColor ?? appTheme.color33C080;
    final Color resolvedTextColor = textColor ?? appTheme.white_A700;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 30.h),
        margin: EdgeInsets.symmetric(horizontal: 82.h),
        decoration: BoxDecoration(
          color: resolvedBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.h),
            topRight: Radius.circular(28.h),
            bottomLeft: Radius.circular(10.h),
            bottomRight: Radius.circular(10.h),
          ),
          boxShadow: [
            BoxShadow(
              color: appTheme.black_900_3f,
              offset: Offset(2.h, 2.h),
              blurRadius: 2.h,
            ),
          ],
        ),
        child: Text(
          text ?? '°  w  °',
          style: TextStyleHelper.instance.headline30BoldMontserratAlternates
              .copyWith(color: resolvedTextColor, height: 37 / 30),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
