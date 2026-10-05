import 'package:flutter/material.dart';

import '../theme.dart';
import '../theme/vet_colors.dart';
import 'pets/pets_theme.dart';

class VetBottomNav extends StatelessWidget {
  const VetBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const List<String> _icons = [
    'assets/imagens/figma/pets.png',
    'assets/imagens/figma/frame-53.png',
    'assets/imagens/figma/frame-52.png',
    'assets/imagens/figma/frame-50.png',
    'assets/imagens/figma/frame-49-2.png',
  ];

  static const List<String> _selectedIcons = [
    'assets/imagens/figma/pets-6.png',
    'assets/imagens/figma/frame-51-2.png',
    'assets/imagens/figma/frame-52-5.png',
    'assets/imagens/figma/frame-52-3.png',
    'assets/imagens/figma/frame-49.png',
  ];

  static const List<String> _labels = [
    'Pets',
    'Perfil',
    'Whatsapp',
    'Agenda',
    'Configurações',
  ];

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Container(
        margin: EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, 12 * s),
        padding: EdgeInsets.symmetric(vertical: 10 * s, horizontal: 8 * s),
        decoration: BoxDecoration(
          color: VH.secondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(25 * s),
          boxShadow: const [
            BoxShadow(
              color: VetColors.shadowDark,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < _icons.length; i++)
              InkWell(
                onTap: () => onSelected(i),
                customBorder: const CircleBorder(),
                child: Semantics(
                  button: true,
                  selected: i == selectedIndex,
                  label: _labels[i],
                  child: i == 0
                      ? Container(
                          width: 50 * s,
                          height: 50 * s,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: i == selectedIndex
                                ? VH.secondary
                                : VH.background,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: VetColors.shadowDark,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            i == selectedIndex ? _selectedIcons[i] : _icons[i],
                            width: 36 * s,
                            height: 36 * s,
                          ),
                        )
                      : Image.asset(
                          i == selectedIndex ? _selectedIcons[i] : _icons[i],
                          width: 50 * s,
                          height: 50 * s,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
