import 'package:flutter/material.dart';

import '../core/utils/vet_nav.dart';
import '../models/pet_model.dart';
import '../theme/vet_colors.dart';
import 'pets/pets_theme.dart';
import 'vet_bottom_nav.dart';
import 'vet_header.dart';

/// Esqueleto único das telas internas: header + corpo rolável + barra inferior.
class VetPageScaffold extends StatelessWidget {
  const VetPageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.pet,
    this.selectedIndex = 0,
    this.isTabRoot = false,
    this.showBack = true,
    this.headerBottom,
  });

  final String title;
  final List<Widget> children;
  final PetModel? pet;
  final int selectedIndex;

  /// true quando a tela É a aba (ex.: Agenda); tocar na própria aba não faz nada.
  final bool isTabRoot;
  final bool showBack;
  final Widget? headerBottom;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);

    return Scaffold(
      backgroundColor: VetColors.pink,
      body: Column(
        children: [
          VetHeader(title: title, showBack: showBack, bottom: headerBottom),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    if (i > 0) SizedBox(height: 12 * s),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: VetBottomNav(
              selectedIndex: selectedIndex,
              onSelected: (i) => vetNavigate(
                context,
                i,
                pet: pet,
                selected: selectedIndex,
                isTabRoot: isTabRoot,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
