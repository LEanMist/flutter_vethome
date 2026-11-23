import 'package:flutter/material.dart';

import '../../theme.dart';

class RegistrationFieldIcon extends StatelessWidget {
  const RegistrationFieldIcon({
    super.key,
    required this.diameter,
    required this.child,
  });

  final double diameter;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: diameter,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: VH.background,
        shape: BoxShape.circle,
        border: Border.all(color: VH.secondary, width: 3),
      ),
      child: Center(child: child),
    ),
  );
}
