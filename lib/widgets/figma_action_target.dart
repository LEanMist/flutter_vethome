import 'package:flutter/material.dart';

/// Amplia a área de toque de um botão compacto do Figma sem redimensioná-lo.
class FigmaActionTarget extends StatelessWidget {
  const FigmaActionTarget({
    super.key,
    required this.width,
    required this.label,
    required this.onPressed,
    required this.child,
    this.height = 48,
  });

  final double width;
  final double height;
  final String label;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: Semantics(
      container: true,
      button: true,
      enabled: onPressed != null,
      label: label,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            excludeFromSemantics: true,
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ExcludeFocus(child: IgnorePointer(child: child)),
            ),
          ),
        ),
      ),
    ),
  );
}
