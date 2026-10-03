import 'package:flutter/material.dart';

import '../theme/vet_colors.dart';
import '../theme/vet_tones.dart';
import 'pets/pets_theme.dart';

/// Card neumórfico (sombra escura + clara), no estilo das telas do Figma.
class VetCard extends StatelessWidget {
  const VetCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final BorderRadius r = BorderRadius.circular(20 * s);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? VetTones.card,
        borderRadius: r,
        boxShadow: const [
          BoxShadow(
            color: VetColors.shadowDark,
            offset: Offset(3, 3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: VetColors.shadowLight,
            offset: Offset(-3, -3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: r,
        child: InkWell(
          borderRadius: r,
          onTap: onTap,
          child: Padding(
            padding: padding ?? EdgeInsets.all(14 * s),
            child: child,
          ),
        ),
      ),
    );
  }
}

class VetSectionTitle extends StatelessWidget {
  const VetSectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    return Padding(
      padding: EdgeInsets.only(top: 6 * s, bottom: 2 * s),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20 * s,
          fontWeight: FontWeight.w700,
          fontFamily: PetsTheme.fontComfortaa,
          color: VetColors.brown,
        ),
      ),
    );
  }
}
