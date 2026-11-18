import 'package:flutter/material.dart';

import '../../theme/vet_colors.dart';
import '../pets/pets_theme.dart';

class GabrielaBottomNav extends StatelessWidget {
  const GabrielaBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _icons = [
    'frame-53.png',
    'frame-52.png',
    'frame-50.png',
    'frame-49-2.png',
  ];
  static const _selectedIcons = [
    'frame-51-2.png',
    'frame-52-5.png',
    'frame-52-3.png',
    'frame-49.png',
  ];
  static const _labels = ['Perfil', 'WhatsApp', 'Agenda', 'Configurações'];

  @override
  Widget build(BuildContext context) {
    final s = PetsTheme.scaleOf(context);
    return Container(
      margin: EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, 10 * s),
      padding: EdgeInsets.symmetric(vertical: 9 * s, horizontal: 4 * s),
      decoration: BoxDecoration(
        color: VetColors.rose.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(25 * s),
        boxShadow: const [
          BoxShadow(
            color: VetColors.shadowDark,
            offset: Offset(2, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < _icons.length; i++)
            Semantics(
              button: true,
              selected: i == selectedIndex,
              label: _labels[i],
              child: InkResponse(
                onTap: () => onSelected(i),
                radius: 32 * s,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5 * s),
                  child: Image.asset(
                    'assets/imagens/figma/${i == selectedIndex ? _selectedIcons[i] : _icons[i]}',
                    width: 48 * s,
                    height: 48 * s,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
