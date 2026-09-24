import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/// CustomFab - A customizable Floating Action Button component
///
/// This widget renders a styled FAB with support for custom background color,
/// icon image, size, and tap callback. It is designed to be reusable and
/// responsive using SizeUtils extensions.
///
/// Arguments:
/// - [imagePath]: Path to the SVG/image asset to display inside the FAB
/// - [onTap]: Callback triggered when the FAB is tapped
/// - [backgroundColor]: Background color of the FAB
/// - [buttonSize]: Diameter of the FAB button
/// - [borderRadius]: Border radius of the FAB
class CustomFab extends StatelessWidget {
  const CustomFab({
    Key? key,
    this.imagePath,
    this.onTap,
    this.backgroundColor,
    this.buttonSize,
    this.borderRadius,
  }) : super(key: key);

  /// Path to the icon/image displayed inside the FAB
  final String? imagePath;

  /// Callback triggered when the FAB is tapped
  final VoidCallback? onTap;

  /// Background color of the FAB button
  final Color? backgroundColor;

  /// Diameter (width and height) of the FAB
  final double? buttonSize;

  /// Border radius of the FAB
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final double resolvedSize = buttonSize ?? 66.h;
    final double resolvedBorderRadius = borderRadius ?? 32.h;
    final Color resolvedBackgroundColor = backgroundColor ?? appTheme.red_100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: resolvedSize,
        height: resolvedSize,
        decoration: BoxDecoration(
          color: resolvedBackgroundColor,
          borderRadius: BorderRadius.circular(resolvedBorderRadius),
        ),
        child: Center(
          child: imagePath != null && imagePath!.isNotEmpty
              ? CustomImageView(
                  imagePath: imagePath!,
                  height: resolvedSize * 0.6,
                  width: resolvedSize * 0.6,
                  fit: BoxFit.contain,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
