import 'package:flutter/material.dart';
import '../theme/vet_colors.dart';

class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key, this.label = 'Dados demonstrativos'});
  final String label;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: VetColors.rose.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: VetColors.brown),
      ),
    ),
  );
}
