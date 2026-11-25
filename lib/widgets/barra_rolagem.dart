import 'package:flutter/material.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';

class BarraRolagem extends StatelessWidget {
  const BarraRolagem({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        overscroll: false,
        scrollbars: false,
      ),
      child: ScrollbarTheme(
        data: const ScrollbarThemeData(
          thumbColor: WidgetStatePropertyAll(VetCores.marrom),
        ),
        child: Scrollbar(
          controller: controller,
          thumbVisibility: true,
          interactive: true,
          thickness: 4,
          radius: const Radius.circular(4),
          child: child,
        ),
      ),
    );
  }
}
