import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/// A customizable icon button widget with shadow and rounded corners.
///
/// Supports variable icon, background color, padding, and tap callback.
/// All dimensions are responsive using SizeUtils extensions.
///
/// Arguments:
/// - [imagePath]: Path to the icon image (SVG or PNG)
/// - [onTap]: Callback triggered when button is tapped
/// - [backgroundColor]: Background color of the button
/// - [padding]: Inner padding of the button
/// - [width]: Width of the button (default 66)
/// - [height]: Height of the button (default 66)
/// - [borderRadius]: Border radius of the button (default 32)
class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    required this.imagePath,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  /// Path to the icon image (SVG or PNG)
  final String imagePath;

  /// Callback triggered when button is tapped
  final VoidCallback? onTap;

  /// Background color of the button
  final Color? backgroundColor;

  /// Inner padding of the button
  final EdgeInsetsGeometry? padding;

  /// Width of the button
  final double? width;

  /// Height of the button
  final double? height;

  /// Border radius of the button
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final double resolvedWidth = width ?? 66.h;
    final double resolvedHeight = height ?? 66.h;
    final double resolvedBorderRadius = borderRadius ?? 32.h;
    final Color resolvedBackgroundColor =
        backgroundColor ?? appTheme.color7FC080;
    final EdgeInsetsGeometry resolvedPadding = padding ?? EdgeInsets.all(8.h);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: resolvedWidth,
        height: resolvedHeight,
        decoration: BoxDecoration(
          color: resolvedBackgroundColor,
          borderRadius: BorderRadius.circular(resolvedBorderRadius),
          boxShadow: [
            BoxShadow(
              color: appTheme.black_900_3f,
              offset: Offset(2.h, 2.h),
              blurRadius: 2.h,
            ),
          ],
        ),
        padding: resolvedPadding,
        child: CustomImageView(imagePath: imagePath, fit: BoxFit.contain),
      ),
    );
  }
}
