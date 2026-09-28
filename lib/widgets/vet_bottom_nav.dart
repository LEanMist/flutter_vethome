import 'package:flutter/material.dart';

import '../theme/vet_colors.dart';
import 'pets/pets_theme.dart';

class VetBottomNav extends StatelessWidget {
  const VetBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onSelected,
  }) : super(key: key);

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const List<IconData> _icons = [
    Icons.pets,
    Icons.person,
    Icons.phone,
    Icons.calendar_month,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final double bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, 12 * s + bottom),
      padding: EdgeInsets.symmetric(vertical: 8 * s, horizontal: 8 * s),
      decoration: BoxDecoration(
        color: VetColors.rose.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24 * s),
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
            GestureDetector(
              onTap: () => onSelected(i),
              child: Container(
                width: 46 * s,
                height: 46 * s,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == selectedIndex ? VetColors.rose : VetColors.pink,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: VetColors.shadowDark,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: VetColors.shadowLight,
                      offset: Offset(-2, -2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _icons[i],
                  size: 26 * s,
                  color: i == selectedIndex ? Colors.white : VetColors.brown,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
