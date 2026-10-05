import 'package:flutter/material.dart';

import 'pets/pets_theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, this.color, {super.key, this.dense = false});

  final String label;
  final Color color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (dense ? 7 : 10) * s,
        vertical: (dense ? 3 : 5) * s,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: (dense ? 10 : 11) * s,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
