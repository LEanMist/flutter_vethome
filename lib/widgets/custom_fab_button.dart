import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/// A customizable Floating Action Button component.
///
/// [onPressed] - Callback triggered when the button is tapped.
/// [imagePath] - Path to the SVG/image asset displayed inside the FAB.
/// [backgroundColor] - Background color of the FAB.
/// [buttonSize] - Size (width and height) of the FAB.
/// [borderRadius] - Border radius of the FAB.
class CustomFabButton extends StatelessWidget {
  const CustomFabButton({
    Key? key,
    required this.onPressed,
    this.imagePath,
    this.backgroundColor,
    this.buttonSize,
    this.borderRadius,
  }) : super(key: key);

  /// Callback triggered when the FAB is tapped
  final VoidCallback onPressed;

  /// Path to the SVG/image asset displayed inside the FAB
  final String? imagePath;

  /// Background color of the FAB
  final Color? backgroundColor;

  /// Size (width and height) of the FAB
  final double? buttonSize;

  /// Border radius of the FAB
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final double resolvedSize = buttonSize ?? 66.h;
    final double resolvedBorderRadius = borderRadius ?? 32.h;
    final Color resolvedBackgroundColor = backgroundColor ?? appTheme.red_100;

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: resolvedBackgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(resolvedBorderRadius),
        ),
        child: imagePath != null
            ? CustomImageView(
                imagePath: imagePath,
                height: resolvedSize * 0.55,
                width: resolvedSize * 0.55,
                fit: BoxFit.contain,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
