import 'package:flutter/material.dart';

import '../../theme.dart';

class RegistrationActionsFooter extends StatelessWidget {
  const RegistrationActionsFooter({super.key, required this.child});

  static const contentSpacing = 24.0;

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: VH.secondary.withValues(alpha: .35)),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: child,
    ),
  );
}
