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
    this.compact = false,
    this.showPetsTab = true,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool compact;
  final bool showPetsTab;

  static const _allDestinationIndices = [0, 1, 2, 3, 4];
  static const _destinationIndicesWithoutPets = [1, 2, 3, 4];

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
    'Conversa',
    'Agenda',
    'Configurações',
  ];

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final media = MediaQuery.of(context);
    final followsFigmaMobileSpacing = media.size.width <= PetsTheme.designWidth;
    final destinations = (showPetsTab
        ? _allDestinationIndices
        : _destinationIndicesWithoutPets);
    final mobileItemGap = (destinations.length == 5 ? 20.0 : 34.0) * s;
    final standardBottomGap = 12 * s;
    final fitsFigmaMobileHeight =
        media.size.width <= PetsTheme.designWidth &&
        media.size.height >= 844 * s;
    final referenceBottomGap = 50 * s;
    final bottomMargin = fitsFigmaMobileHeight
        ? (referenceBottomGap - media.viewPadding.bottom)
              .clamp(standardBottomGap, referenceBottomGap)
              .toDouble()
        : standardBottomGap;
    final navigation = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: VH.mobileContentMaxWidth),
        child: Container(
          width: compact ? double.infinity : null,
          margin: compact
              ? EdgeInsets.zero
              : EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, bottomMargin),
          padding: EdgeInsets.symmetric(
            vertical: compact ? 0 : 10 * s,
            horizontal: 8 * s,
          ),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (50 * s).clamp(48.0, 50.0);
              final fitsFigmaSpacing =
                  followsFigmaMobileSpacing &&
                  itemWidth * destinations.length +
                          mobileItemGap * (destinations.length - 1) <=
                      constraints.maxWidth;
              return Row(
                mainAxisAlignment: fitsFigmaSpacing
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceEvenly,
                children: [
                  for (final destination in destinations.asMap().entries) ...[
                    _VetNavDestination(
                      label: _labels[destination.value],
                      icon: _icons[destination.value],
                      selectedIcon: _selectedIcons[destination.value],
                      selected: destination.value == selectedIndex,
                      highlighted: destination.key == 0,
                      scale: s,
                      onTap: () => onSelected(destination.value),
                    ),
                    if (fitsFigmaSpacing &&
                        destination.key < destinations.length - 1)
                      SizedBox(width: mobileItemGap),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );

    if (compact) {
      return SizedBox(height: (50 * s).clamp(48.0, 50.0), child: navigation);
    }

    return SafeArea(top: false, left: false, right: false, child: navigation);
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
        excludeFromSemantics: true,
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
