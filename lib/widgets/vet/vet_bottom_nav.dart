import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

import '../../theme.dart';
import '../../theme/vet_colors.dart';
import '../pets/pets_theme.dart';

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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: VH.mobileContentMaxWidth),
          child: Container(
            margin: EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, 12 * s),
            padding: EdgeInsets.symmetric(vertical: 10 * s, horizontal: 8 * s),
            decoration: inset_shadow.BoxDecoration(
              color: VH.secondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(25 * s),
              boxShadow: const [
                inset_shadow.BoxShadow(
                  color: VetColors.shadowDark,
                  offset: Offset(2, 2),
                  blurRadius: 2,
                  inset: true,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < _icons.length; i++)
                  _VetNavDestination(
                    label: _labels[i],
                    icon: _icons[i],
                    selectedIcon: _selectedIcons[i],
                    selected: i == selectedIndex,
                    highlighted: i == 0,
                    scale: s,
                    onTap: () => onSelected(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VetNavDestination extends StatefulWidget {
  const _VetNavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.highlighted,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final String icon;
  final String selectedIcon;
  final bool selected;
  final bool highlighted;
  final double scale;
  final VoidCallback onTap;

  @override
  State<_VetNavDestination> createState() => _VetNavDestinationState();
}

class _VetNavDestinationState extends State<_VetNavDestination> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dimension = (50 * widget.scale).clamp(48.0, 50.0);
    final overlay = _pressed
        ? VH.interactionOverlay({WidgetState.pressed})
        : _focused
        ? VH.interactionOverlay({WidgetState.focused})
        : _hovered
        ? VH.interactionOverlay({WidgetState.hovered})
        : Colors.transparent;
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      child: Tooltip(
        message: widget.label,
        child: SizedBox.square(
          dimension: dimension,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: widget.onTap,
              onHover: (value) => setState(() => _hovered = value),
              onFocusChange: (value) => setState(() => _focused = value),
              onHighlightChanged: (value) => setState(() => _pressed = value),
              customBorder: const CircleBorder(),
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              child: Container(
                foregroundDecoration: BoxDecoration(
                  color: overlay,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: widget.highlighted
                      ? Container(
                          width: 50 * widget.scale,
                          height: 50 * widget.scale,
                          alignment: Alignment.center,
                          decoration: widget.selected
                              ? inset_shadow.BoxDecoration(
                                  color: VetColors.roseOverlay50,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    inset_shadow.BoxShadow(
                                      color: VetColors.shadowDark,
                                      offset: Offset(2, 2),
                                      blurRadius: 2,
                                      inset: true,
                                    ),
                                  ],
                                )
                              : const BoxDecoration(
                                  color: VetColors.pink,
                                  shape: BoxShape.circle,
                                ),
                          child: ExcludeSemantics(
                            child: Image.asset(
                              widget.selected
                                  ? widget.selectedIcon
                                  : widget.icon,
                              width: 35 * widget.scale,
                              height: 35 * widget.scale,
                            ),
                          ),
                        )
                      : ExcludeSemantics(
                          child: Image.asset(
                            widget.selected ? widget.selectedIcon : widget.icon,
                            width: 50 * widget.scale,
                            height: 50 * widget.scale,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
