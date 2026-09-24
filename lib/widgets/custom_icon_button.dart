import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/// A customizable circular icon button with shadow support.
///
/// Supports configurable icon path, background color, padding, size,
/// border radius, and tap callback. Designed to match design variants
/// with shadow effect and circular shape.
///
/// Arguments:
/// - [imagePath]: Path to the SVG/PNG icon asset (required)
/// - [onTap]: Callback triggered on button tap
/// - [backgroundColor]: Background fill color of the button
/// - [buttonSize]: Overall width and height of the button
/// - [padding]: Inner padding around the icon
/// - [borderRadius]: Corner radius of the button
/// - [margin]: Outer margin around the button
class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    required this.imagePath,
    this.onTap,
    this.backgroundColor,
    this.buttonSize,
    this.padding,
    this.borderRadius,
    this.margin,
  }) : super(key: key);

  /// Path to the icon image (SVG or PNG)
  final String imagePath;

  /// Callback triggered when the button is tapped
  final VoidCallback? onTap;

  /// Background color of the circular button
  final Color? backgroundColor;

  /// Overall size (width and height) of the button
  final double? buttonSize;

  /// Inner padding around the icon
  final EdgeInsetsGeometry? padding;

  /// Border radius for the circular shape
  final double? borderRadius;

  /// Outer margin around the button
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final double resolvedSize = buttonSize ?? 66.h;
    final double resolvedRadius = borderRadius ?? 32.h;
    final Color resolvedBgColor = backgroundColor ?? appTheme.red_100;
    final EdgeInsetsGeometry resolvedPadding = padding ?? EdgeInsets.all(8.h);

    return Container(
      margin: margin,
      child: Material(
        color: appTheme.transparentCustom,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(resolvedRadius),
          child: Ink(
            width: resolvedSize,
            height: resolvedSize,
            decoration: BoxDecoration(
              color: resolvedBgColor,
              borderRadius: BorderRadius.circular(resolvedRadius),
              boxShadow: [
                BoxShadow(
                  color: appTheme.black_900_3f,
                  offset: Offset(2.h, 2.h),
                  blurRadius: 2.h,
                ),
              ],
            ),
            child: Padding(
              padding: resolvedPadding,
              child: CustomImageView(imagePath: imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
