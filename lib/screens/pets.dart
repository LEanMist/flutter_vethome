import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

import '../core/utils/vet_nav.dart';
import '../data/vet_repository.dart';
import '../pages/pets_page.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets/pet_summary.dart';
import '../widgets/pets/pet_avatar.dart';
import '../widgets/vet_choice_pill.dart';
import '../widgets/pets/pet_card_widget.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets.dart';
import '../widgets/vet/vet_page_scaffold.dart';

Future<void> openPetChoiceDialog(BuildContext context) async {
  if (VetRepository.pets.isEmpty) {
    await Navigator.pushNamed(context, '/pets');
    return;
  }

  final result = await showDialog<Object?>(
    context: context,
    builder: (dialogContext) => EscolhaPetScreen(
      compact: true,
      onPetSelected: (id) => Navigator.pop(dialogContext, id),
      onRouteSelected: (index) =>
          Navigator.pop(dialogContext, _PetChoiceNavigation(index)),
    ),
  );
  if (!context.mounted || result == null) return;
  if (result is _PetChoiceNavigation) {
    vetNavigate(context, result.destination, selected: 3, isTabRoot: true);
    return;
  }
  if (result is! String) return;

  VetRepository.selectedPetId = result;
  Navigator.pushNamed(context, '/servicos');
}

class _PetChoiceNavigation {
  const _PetChoiceNavigation(this.destination);

  final int destination;
}

class EscolhaPetScreen extends StatefulWidget {
  const EscolhaPetScreen({
    super.key,
    this.compact = false,
    this.onPetSelected,
    this.onRouteSelected,
  });

  final bool compact;
  final ValueChanged<String>? onPetSelected;
  final ValueChanged<int>? onRouteSelected;

  @override
  State<EscolhaPetScreen> createState() => _EscolhaPetScreenState();
}

class _EscolhaPetScreenState extends State<EscolhaPetScreen> {
  final ScrollController _petsController = ScrollController();

  @override
  void dispose() {
    _petsController.dispose();
    super.dispose();
  }

  void _scrollPets(double delta) {
    if (!_petsController.hasClients) return;
    final position = _petsController.position;
    _petsController.animateTo(
      (position.pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  bool _canScrollPets({required bool up}) {
    if (VetRepository.pets.length <= 4) return false;
    if (!_petsController.hasClients ||
        !_petsController.position.hasContentDimensions) {
      return !up;
    }
    final position = _petsController.position;
    return up ? position.extentBefore > 0.5 : position.extentAfter > 0.5;
  }

  @override
  Widget build(BuildContext context) {
    if (VetRepository.pets.isEmpty) return const PetsPage();

    if (widget.compact) {
      final size = MediaQuery.sizeOf(context);
      final scale = math.min(
        1.0,
        math.min(size.width / 390, size.height / 408),
      );
      return Dialog(
        key: const ValueKey('pet-choice-dialog'),
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          width: 390 * scale,
          height: 408 * scale,
          child: _mobilePanel(context, scale),
        ),
      );
    }

    final desktop = MediaQuery.sizeOf(context).width >= 900;
    if (desktop) {
      return VHPage(
        tab: '/escolhaPet',
        children: [
          const VHHeader('Escolha seu Pet'),
          Padding(
            padding: const EdgeInsets.all(22),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 22) / 2;
                return Wrap(
                  key: const ValueKey('pet-choice-desktop-grid'),
                  spacing: 22,
                  runSpacing: 18,
                  children: [
                    for (final pet in VetRepository.pets)
                      SizedBox(
                        width: width,
                        child: PetCardWidget(
                          pet: pet,
                          nameColor: VetColors.brownOnRose,
                          onTap: () => _selectPet(context, pet.id),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    }

    return VHPage(
      tab: '/escolhaPet',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final scale = (constraints.maxWidth / 390).clamp(0.8, 1.0);
            return Center(child: _mobilePanel(context, scale));
          },
        ),
      ],
    );
  }

  void _selectPet(BuildContext context, String petId) {
    final onPetSelected = widget.onPetSelected;
    if (onPetSelected != null) {
      onPetSelected(petId);
      return;
    }
    VetRepository.selectedPetId = petId;
    Navigator.pushNamed(context, '/servicos');
  }

  Widget _mobilePanel(BuildContext context, double scale) => SizedBox(
    key: const ValueKey('pet-choice-panel'),
    width: 390 * scale,
    height: 408 * scale,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(25 * scale),
      child: ColoredBox(
        color: VetColors.petChoicePanel,
        child: Stack(
          children: [
            if (widget.compact)
              Positioned(
                right: 4 * scale,
                top: 54 * scale,
                child: VetRouteMenuButton(
                  key: const ValueKey('pet-choice-route-menu'),
                  onSelected: (index) {
                    final onRouteSelected = widget.onRouteSelected;
                    if (onRouteSelected != null) {
                      onRouteSelected(index);
                    } else {
                      Navigator.pop(context, _PetChoiceNavigation(index));
                    }
                  },
                ),
              ),
            Positioned(
              top: 37 * scale,
              left: 37 * scale,
              width: 316 * scale,
              child: Text(
                'Escolha seu Pet',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: PetsTheme.fontComfortaa,
                  fontSize: 35 * scale,
                  fontWeight: FontWeight.w700,
                  color: VetColors.brownSecondary,
                ),
              ),
            ),
            Positioned(
              top: 110 * scale,
              left: 28 * scale,
              width: 275 * scale,
              height: 262 * scale,
              child: ListView.separated(
                key: const ValueKey('pet-choice-mobile-list'),
                controller: _petsController,
                padding: EdgeInsets.zero,
                itemCount: VetRepository.pets.length,
                separatorBuilder: (_, _) => SizedBox(height: 18 * scale),
                itemBuilder: (context, index) {
                  final pet = VetRepository.pets[index];
                  return SizedBox(
                    width: 275 * scale,
                    height: 52 * scale,
                    child: PetCardWidget(
                      key: ValueKey('pet-choice-${pet.id}'),
                      pet: pet,
                      // Dark text keeps AA contrast over the Figma rose pill.
                      nameColor: VetColors.brownOnRose,
                      onTap: () => _selectPet(context, pet.id),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 330 * scale,
              top: 130 * scale,
              width: 48 * scale,
              height: 48 * scale,
              child: AnimatedBuilder(
                animation: _petsController,
                builder: (context, _) => IconButton(
                  tooltip: 'Rolar pets para cima',
                  onPressed: _canScrollPets(up: true)
                      ? () => _scrollPets(-70 * scale)
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: 48 * scale,
                    height: 48 * scale,
                  ),
                  color: VetColors.brown,
                  disabledColor: VetColors.brown,
                  iconSize: 30 * scale,
                  icon: const Icon(Icons.keyboard_arrow_up),
                ),
              ),
            ),
            Positioned(
              left: 330 * scale,
              top: 300 * scale,
              width: 48 * scale,
              height: 48 * scale,
              child: AnimatedBuilder(
                animation: _petsController,
                builder: (context, _) => IconButton(
                  tooltip: 'Rolar pets para baixo',
                  onPressed: _canScrollPets(up: false)
                      ? () => _scrollPets(70 * scale)
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: 48 * scale,
                    height: 48 * scale,
                  ),
                  color: VetColors.brown,
                  disabledColor: VetColors.brown,
                  iconSize: 30 * scale,
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});
  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  final Set<String> _expanded = {'Exames', 'Vacinas'};
  final Set<String> _interactedCategories = <String>{};
  final Set<String> _selected = <String>{};
  String? _desktopExpandedCategory = 'Exames';

  static const _selectedServiceMarker =
      'assets/imagens/figma/services-checkbox-selected.svg';
  static const _unselectedServiceMarker =
      'assets/imagens/figma/services-checkbox-unselected.svg';

  bool _isCategoryExpanded(String name) {
    if (MediaQuery.sizeOf(context).width < VH.desktopBreakpoint) {
      return _expanded.contains(name);
    }
    return _desktopExpandedCategory == name && _expanded.contains(name);
  }

  void _toggleCategory(String name) => setState(() {
    _interactedCategories.add(name);
    final desktop = MediaQuery.sizeOf(context).width >= VH.desktopBreakpoint;
    if (desktop) {
      if (_desktopExpandedCategory == name && _expanded.contains(name)) {
        _desktopExpandedCategory = null;
        _expanded.remove(name);
      } else {
        _desktopExpandedCategory = name;
        _expanded.add(name);
      }
    } else if (!_expanded.remove(name)) {
      _expanded.add(name);
      _desktopExpandedCategory = name;
    } else if (_desktopExpandedCategory == name) {
      _desktopExpandedCategory = _expanded.isEmpty ? null : _expanded.first;
    }
  });

  void _toggleService(String name) => setState(() {
    if (!_selected.remove(name)) _selected.add(name);
  });

  void _continueToPlan(String petId) {
    if (_selected.isEmpty) return;
    final ordered = [
      for (final group in categories.values)
        for (final service in group)
          if (_selected.contains(service)) service,
    ];
    final combined = ordered.join(' + ');
    Navigator.pushNamed(
      context,
      '/convenio',
      arguments: {'petId': petId, 'service': combined},
    );
  }

  Future<bool> _confirmLeavingServices(int destinationIndex) async {
    if (_selected.isEmpty) return true;
    return vetConfirmLeavingForm(
      context,
      title: 'Descartar serviços?',
      message:
          'Os serviços ${_selected.join(', ')} ainda não foram enviados. '
          'Se sair agora, você perderá essa seleção.',
    );
  }

  static const categories = <String, List<String>>{
    'Exames': ['Hemograma', 'Creatinina', 'Urina'],
    'Vacinas': ['V8', 'V10', 'Antirrábica'],
    'Microchipagem': ['Microchipagem'],
    'Atestados': ['Atestado'],
  };
  @override
  Widget build(BuildContext context) {
    final routeArguments = ModalRoute.of(context)?.settings.arguments;
    final routePetId = routeArguments is Map ? routeArguments['petId'] : null;
    final pet = routePetId is String
        ? VetRepository.petById(routePetId)
        : VetRepository.selectedPet;
    if (pet == null) return const PetsPage();
    final media = MediaQuery.of(context);
    final desktop = media.size.width >= VH.desktopBreakpoint;
    final availableHeight =
        media.size.height - media.padding.top - media.viewInsets.bottom;
    // The Figma button ends at y=775 and the compact bottom navigation is 50 px.
    final shortViewport = availableHeight < 825;
    final species = switch (pet.species?.trim().toLowerCase()) {
      'cachorro' || 'cão' => 'CÃO',
      'gato' => 'GATO',
      final value when value != null && value.isNotEmpty => value.toUpperCase(),
      _ => 'PET',
    };
    return VHPage(
      tab: '/servicos',
      compactBottomNav: true,
      onBeforeNavigate: _confirmLeavingServices,
      footer: shortViewport
          ? SafeArea(top: false, child: _continueButton(pet.id, topPadding: 8))
          : null,
      children: [
        desktop ? const VHHeader('Serviços') : _servicesHeader(pet, species),
        Padding(
          padding: EdgeInsets.fromLTRB(
            desktop ? 20 : 0,
            desktop ? 20 : 25,
            desktop ? 20 : 0,
            20,
          ),
          child: VetResponsiveLayout(
            breakpoint: VH.compactBreakpoint,
            mobile: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  const SizedBox(height: 8),
                  Align(
                    alignment: constraints.maxWidth > 390
                        ? Alignment.topCenter
                        : Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...categories.entries.map(
                          (entry) => _category(pet, entry),
                        ),
                        if (!shortViewport)
                          _continueButton(pet.id, topPadding: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            desktop: Row(
              key: const ValueKey('services-desktop-layout'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: PetSummary(pet: pet)),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    children: [
                      ...categories.entries.map(
                        (entry) => _category(pet, entry),
                      ),
                      if (!shortViewport) _continueButton(pet.id),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _servicesHeader(dynamic pet, String species) => SizedBox(
    height: 157,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: VH.secondary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 37,
            left: 40,
            right: 40,
            child: Text(
              'Serviços',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: VH.headingFontFamily,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 173,
                height: 59,
                decoration: inset_shadow.BoxDecoration(
                  color: VH.secondary.withValues(alpha: .2),
                  borderRadius: VH.headerInsetBorderRadius,
                  boxShadow: const [
                    inset_shadow.BoxShadow(
                      color: VH.shadowSubtle,
                      offset: Offset(2, 2),
                      blurRadius: 2,
                      inset: true,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        species,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: VH.bodyFontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    PetAvatar(
                      image: pet.imagePath,
                      photoBase64: pet.photoBase64,
                      species: pet.species,
                      size: 32,
                      listSilhouette: true,
                      silhouetteColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _continueButton(String petId, {double topPadding = 16}) => Padding(
    padding: EdgeInsets.only(top: topPadding, bottom: 16),
    child: Center(
      child: SizedBox(
        width: 157,
        height: 57,
        child: ElevatedButton(
          key: const ValueKey('services-continue'),
          onPressed: _selected.isEmpty ? null : () => _continueToPlan(petId),
          style: ElevatedButton.styleFrom(
            backgroundColor: VH.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: VH.primary.withValues(alpha: .45),
            shape: const StadiumBorder(),
          ),
          child: const Text(
            'Continuar',
            style: TextStyle(
              fontFamily: VH.headingFontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    ),
  );

  // Ajuste exclusivo de Serviços: categoria Montserrat Alternates 20 px,
  // sem alterar VetChoicePill utilizado pelas outras telas.
  Widget _servicePill(
    String name, {
    required VoidCallback onTap,
    VoidCallback? arrowOnTap,
    bool selected = false,
  }) {
    if (MediaQuery.sizeOf(context).width >= VH.desktopBreakpoint) {
      return _desktopServicePill(name);
    }

    final visual = _ServiceCategoryVisual.forName(name);
    final dynamicArrow = _interactedCategories.contains(name)
        ? _isCategoryExpanded(name)
              ? _ServiceCategoryArrow.down
              : _ServiceCategoryArrow.right
        : visual.arrow;
    final borderRadius = visual.borderRadius;
    final gradient = LinearGradient(
      begin: Alignment(-1, -visual.gradientAlignmentY),
      end: Alignment(1, visual.gradientAlignmentY),
      colors: const [VH.secondary, VH.background],
      stops: visual.gradientStops,
    );
    return SizedBox(
      key: ValueKey('services-category-row-$name'),
      width: 320,
      height: 59,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: visual.left,
            top: 0,
            width: visual.width,
            height: 59,
            child: Material(
              color: Colors.transparent,
              child: Ink(
                key: ValueKey('services-pill-$name'),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: borderRadius,
                  boxShadow: VH.controlShadow,
                ),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: borderRadius,
                  overlayColor: WidgetStateProperty.resolveWith(
                    VH.interactionOverlay,
                  ),
                  child: SizedBox(
                    height: 59,
                    child: Stack(
                      children: [
                        Positioned(
                          left: visual.iconLeft,
                          top: visual.iconTop,
                          width: visual.iconWidth,
                          height: visual.iconHeight,
                          child: SizedBox(
                            key: ValueKey('services-category-icon-$name'),
                            child: VetPictogram(name),
                          ),
                        ),
                        Positioned(
                          left: visual.labelLeft,
                          top: 18,
                          child: Text(
                            name,
                            key: ValueKey('services-category-label-$name'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: VH.bodyFontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: VetColors.chatMessageText,
                            ),
                          ),
                        ),
                        if (visual.arrow != _ServiceCategoryArrow.doubleRight)
                          Positioned(
                            left: visual.arrowLeft,
                            top: visual.arrowTop,
                            width: visual.arrowWidth,
                            height: visual.arrowHeight,
                            child: IgnorePointer(
                              child: RotatedBox(
                                key: ValueKey(
                                  'services-category-arrow-rotation-$name',
                                ),
                                quarterTurns:
                                    dynamicArrow == _ServiceCategoryArrow.down
                                    ? 1
                                    : 0,
                                child: SvgPicture.asset(
                                  visual.arrow == _ServiceCategoryArrow.down
                                      ? 'assets/imagens/figma/services-chevron-down.svg'
                                      : 'assets/imagens/figma/services-chevron-right.svg',
                                  key: ValueKey(
                                    'services-category-arrow-$name',
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (visual.arrow == _ServiceCategoryArrow.doubleRight)
            Positioned(
              left: 274,
              top: 8.5,
              width: 48,
              height: 48,
              child: ExcludeFocus(
                child: IconButton(
                  key: ValueKey('services-category-arrow-$name'),
                  tooltip: name,
                  onPressed: arrowOnTap ?? () => _toggleCategory(name),
                  padding: EdgeInsets.zero,
                  icon: RotatedBox(
                    quarterTurns:
                        _interactedCategories.contains(name) &&
                            _isCategoryExpanded(name)
                        ? 1
                        : 0,
                    child: selected
                        ? SvgPicture.asset(
                            _selectedServiceMarker,
                            key: ValueKey('services-category-checkbox-$name'),
                            width: 16,
                            height: 16,
                          )
                        : Image.asset(
                            'assets/imagens/figma/convenio-chevron.png',
                            key: ValueKey('services-category-chevron-$name'),
                            width: 17,
                            height: 19,
                            excludeFromSemantics: true,
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _desktopServicePill(String name) => LayoutBuilder(
    builder: (context, constraints) {
      final selected = _categoryHasSelection(name);
      final textScaler = MediaQuery.textScalerOf(context);
      final scaledFontSize = textScaler.scale(20);
      const labelStyle = TextStyle(
        fontFamily: VH.bodyFontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: VetColors.chatMessageText,
      );
      final labelWidth =
          constraints.maxWidth - 48 - 16 - 8 - 30 - 12 - (selected ? 24 : 0);
      final singleLinePainter = TextPainter(
        text: TextSpan(text: name, style: labelStyle),
        textDirection: Directionality.of(context),
        textScaler: textScaler,
        maxLines: 1,
      )..layout(maxWidth: labelWidth);
      final needsWrap =
          scaledFontSize > 20.5 && singleLinePainter.didExceedMaxLines;
      final int? maxLines = needsWrap ? null : 1;
      final displayName = needsWrap
          ? switch (name) {
              'Microchipagem' => 'Micro\nchip\nagem',
              'Atestados' => 'Ate\nstados',
              _ => name,
            }
          : name;
      final labelPainter = TextPainter(
        text: TextSpan(text: displayName, style: labelStyle),
        textDirection: Directionality.of(context),
        textScaler: textScaler,
        maxLines: maxLines,
      )..layout(maxWidth: labelWidth);
      final pillHeight = labelPainter.height + 24 > 59
          ? labelPainter.height + 24
          : 59.0;

      return Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(-1.005, 0.876),
                    end: Alignment(1.005, -0.876),
                    colors: [VH.secondary, VH.background],
                  ),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: VH.controlShadow,
                ),
                child: InkWell(
                  onTap: () => _toggleCategory(name),
                  borderRadius: BorderRadius.circular(100),
                  overlayColor: WidgetStateProperty.resolveWith(
                    VH.interactionOverlay,
                  ),
                  child: SizedBox(
                    height: pillHeight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: VetPictogram(name),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              displayName,
                              key: ValueKey('services-category-label-$name'),
                              maxLines: maxLines,
                              overflow: maxLines == null
                                  ? null
                                  : TextOverflow.ellipsis,
                              style: labelStyle,
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 8),
                            SvgPicture.asset(
                              _selectedServiceMarker,
                              key: ValueKey('services-category-checkbox-$name'),
                              width: 16,
                              height: 16,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: ExcludeFocus(
              child: IconButton(
                key: ValueKey('services-category-arrow-$name'),
                tooltip: name,
                onPressed: () => _toggleCategory(name),
                icon: Transform.translate(
                  offset: const Offset(3, 0),
                  child: _isCategoryExpanded(name)
                      ? const Icon(
                          Icons.keyboard_arrow_down,
                          color: VH.foreground,
                        )
                      : const VetChevron(),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  bool _categoryHasSelection(String name) =>
      categories[name]?.any(_selected.contains) ?? false;

  Widget _category(dynamic pet, MapEntry<String, List<String>> entry) {
    final mobile = MediaQuery.sizeOf(context).width < VH.desktopBreakpoint;
    final directChoice =
        mobile && (entry.key == 'Microchipagem' || entry.key == 'Atestados');
    final selectedServices = entry.value
        .where(_selected.contains)
        .toList(growable: false);
    final categoryAction = directChoice
        ? () => _toggleService(entry.value.single)
        : () => _toggleCategory(entry.key);
    return SizedBox(
      width: MediaQuery.sizeOf(context).width >= VH.desktopBreakpoint
          ? 306
          : 320,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.sizeOf(context).width < VH.compactBreakpoint
              ? switch (entry.key) {
                  'Exames' || 'Vacinas' => 18,
                  'Microchipagem' => 22,
                  _ => 20,
                }
              : MediaQuery.sizeOf(context).width >= VH.desktopBreakpoint
              ? 4
              : 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              key: ValueKey('services-category-semantics-${entry.key}'),
              button: !directChoice,
              label: entry.key,
              hint: selectedServices.isEmpty
                  ? null
                  : 'Selecionados: ${selectedServices.join(', ')}',
              checked: directChoice
                  ? _selected.contains(entry.value.single)
                  : null,
              expanded: directChoice ? null : _isCategoryExpanded(entry.key),
              onTap: categoryAction,
              child: ExcludeSemantics(
                child: _servicePill(
                  entry.key,
                  onTap: categoryAction,
                  arrowOnTap: directChoice
                      ? categoryAction
                      : () => _toggleCategory(entry.key),
                  selected:
                      directChoice && _selected.contains(entry.value.single),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              alignment: Alignment.topLeft,
              child: directChoice || !_isCategoryExpanded(entry.key)
                  ? const SizedBox(width: 228)
                  : ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(25),
                      ),
                      child: Material(
                        color: VH.secondary.withValues(alpha: .25),
                        child: Stack(
                          key: ValueKey('services-options-${entry.key}'),
                          children: [
                            SizedBox(
                              width: 228,
                              child: Column(
                                children: [
                                  for (final option in entry.value)
                                    Semantics(
                                      label: option,
                                      checked: _selected.contains(option),
                                      onTap: () => _toggleService(option),
                                      child: InkWell(
                                        excludeFromSemantics: true,
                                        onTap: () => _toggleService(option),
                                        overlayColor:
                                            WidgetStateProperty.resolveWith(
                                              VH.interactionOverlay,
                                            ),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight:
                                                MediaQuery.sizeOf(
                                                      context,
                                                    ).width <
                                                    VH.compactBreakpoint
                                                ? 101 / 3
                                                : MediaQuery.sizeOf(
                                                        context,
                                                      ).width >=
                                                      VH.desktopBreakpoint
                                                ? 44
                                                : 48,
                                          ),
                                          child: ExcludeSemantics(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      option,
                                                      style: const TextStyle(
                                                        color: VH.foreground,
                                                        fontFamily:
                                                            VH.bodyFontFamily,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  Transform.translate(
                                                    offset:
                                                        MediaQuery.sizeOf(
                                                              context,
                                                            ).width <
                                                            VH.desktopBreakpoint
                                                        ? const Offset(-18, 0)
                                                        : Offset.zero,
                                                    child: SvgPicture.asset(
                                                      _selected.contains(option)
                                                          ? _selectedServiceMarker
                                                          : _unselectedServiceMarker,
                                                      key: ValueKey(
                                                        'services-checkbox-$option',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (MediaQuery.sizeOf(context).width <
                                VH.desktopBreakpoint)
                              Positioned(
                                key: ValueKey(
                                  'services-options-indicator-${entry.key}',
                                ),
                                right: 11.3,
                                top: 25.5,
                                width: 3,
                                height: 28,
                                child: ExcludeSemantics(
                                  child: IgnorePointer(
                                    child: RotatedBox(
                                      quarterTurns: 1,
                                      child: SvgPicture.asset(
                                        'assets/imagens/figma/services-options-indicator.svg',
                                        width: 28,
                                        height: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ServiceCategoryArrow { down, right, doubleRight }

class _ServiceCategoryVisual {
  const _ServiceCategoryVisual({
    required this.left,
    required this.width,
    required this.iconLeft,
    required this.iconTop,
    required this.iconWidth,
    required this.iconHeight,
    required this.labelLeft,
    required this.gradientAlignmentY,
    required this.borderRadius,
    required this.arrow,
    this.arrowLeft = 0,
    this.arrowTop = 0,
    this.arrowWidth = 0,
    this.arrowHeight = 0,
    this.gradientStops,
  });

  final double left;
  final double width;
  final double iconLeft;
  final double iconTop;
  final double iconWidth;
  final double iconHeight;
  final double labelLeft;
  final double gradientAlignmentY;
  final BorderRadius borderRadius;
  final _ServiceCategoryArrow arrow;
  final double arrowLeft;
  final double arrowTop;
  final double arrowWidth;
  final double arrowHeight;
  final List<double>? gradientStops;

  static _ServiceCategoryVisual forName(String name) => switch (name) {
    'Exames' => const _ServiceCategoryVisual(
      left: 0,
      width: 263,
      iconLeft: 15,
      iconTop: 19,
      iconWidth: 30,
      iconHeight: 30,
      labelLeft: 61,
      gradientAlignmentY: 1.07212,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(800),
        bottomRight: Radius.circular(400),
      ),
      arrow: _ServiceCategoryArrow.down,
      arrowLeft: 240.075,
      arrowTop: 25.996,
      arrowWidth: 19.698,
      arrowHeight: 11.124,
    ),
    'Vacinas' => const _ServiceCategoryVisual(
      left: 0,
      width: 263,
      iconLeft: 16.669,
      iconTop: 15,
      iconWidth: 31.181,
      iconHeight: 30,
      labelLeft: 62,
      gradientAlignmentY: 0.0756,
      gradientStops: [0.0019273, 0.99814],
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
      arrow: _ServiceCategoryArrow.right,
      arrowLeft: 226.345,
      arrowTop: 21.735,
      arrowWidth: 8.008,
      arrowHeight: 16.63,
    ),
    'Microchipagem' => const _ServiceCategoryVisual(
      left: -1,
      width: 263,
      iconLeft: 14,
      iconTop: 14,
      iconWidth: 30,
      iconHeight: 30,
      labelLeft: 61,
      gradientAlignmentY: 0.0756,
      gradientStops: [0.0019273, 0.99814],
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
      arrow: _ServiceCategoryArrow.doubleRight,
    ),
    'Atestados' => const _ServiceCategoryVisual(
      left: -5,
      width: 267,
      iconLeft: 13,
      iconTop: 14,
      iconWidth: 32,
      iconHeight: 32,
      labelLeft: 61,
      gradientAlignmentY: -0.8813,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(400),
        bottomRight: Radius.circular(800),
      ),
      arrow: _ServiceCategoryArrow.doubleRight,
    ),
    _ => throw ArgumentError.value(name, 'name', 'Categoria desconhecida'),
  };
}

class ConvenioScreen extends StatelessWidget {
  const ConvenioScreen({super.key, this.service});

  static const _planTitleStyle = TextStyle(
    fontFamily: VH.bodyFontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: VetColors.brownOnRose,
  );

  /// Service received from the completed selection flow or an explicit caller.
  final String? service;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final values = args is Map ? args : const {};
    final pet = values['petId'] is String
        ? VetRepository.petById(values['petId'] as String)
        : VetRepository.selectedPet;
    if (pet == null) return const PetsPage();
    final routeService = service ?? values['service'];
    final selectedService = routeService is String ? routeService.trim() : '';
    final media = MediaQuery.of(context);
    const navigationHeight = 50.0;
    const headerHeight = 157.0;
    const initialGap = 185.0;
    const planGap = 60.0;
    final referenceGaps = initialGap + planGap + planGap;
    final compactLargeTextPlans =
        media.size.height <= 640 && media.textScaler.scale(20) >= 36;
    final allowPlanTitleWrap = media.textScaler.scale(20) > 20.5;
    final planVerticalPadding = compactLargeTextPlans ? 5.0 : 10.0;
    final effectivePlanTitleStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.merge(_planTitleStyle);
    double planCardHeight(String label) {
      final labelLayout = TextPainter(
        text: TextSpan(text: label, style: effectivePlanTitleStyle),
        textDirection: Directionality.of(context),
        textScaler: media.textScaler,
      );
      const labelWidth = 254.0 - 15 - 12 - 30 - 18;
      double measuredTextHeight;
      if (allowPlanTitleWrap) {
        labelLayout.layout(maxWidth: labelWidth);
        measuredTextHeight = labelLayout.height;
      } else {
        labelLayout.layout();
        final fitScale = math.min(1.0, labelWidth / labelLayout.width);
        measuredTextHeight = labelLayout.height * fitScale;
      }
      final height = math.max(
        59.0,
        measuredTextHeight + planVerticalPadding * 2,
      );
      labelLayout.dispose();
      return height;
    }

    final plansHeight = [
      planCardHeight('PetLove'),
      planCardHeight('Doglife'),
      planCardHeight('Particular'),
    ].fold<double>(0, (total, height) => total + height);
    final availableGaps =
        media.size.height -
        media.padding.top -
        media.viewInsets.bottom -
        navigationHeight -
        headerHeight -
        plansHeight;
    final mobileSpacingScale = (availableGaps / referenceGaps)
        .clamp(0.0, 1.0)
        .toDouble();
    return VHPage(
      tab: '/convenio',
      compactBottomNav: true,
      onBeforeNavigate: (destinationIndex) => selectedService.isEmpty
          ? Future.value(true)
          : vetConfirmLeavingForm(
              context,
              title: 'Sair do agendamento?',
              message:
                  'O serviço $selectedService ainda não foi enviado. '
                  'Se sair agora, ele não seguirá para a consulta.',
            ),
      children: [
        // Figma 2783:840: cabeçalho de 157 px com aba da espécie (mobile).
        VetResponsiveLayout(
          breakpoint: VH.compactBreakpoint,
          mobile: _figmaHeader(pet),
          desktop: const VHHeader('Convênio'),
        ),
        VetResponsiveLayout(
          breakpoint: VH.compactBreakpoint,
          mobile: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CONVENIO_PAGE (2783:840), em "Telas para Entregar":
                  // três opções em y=342, 461 e 580, sem opção sem rótulo.
                  SizedBox(height: initialGap * mobileSpacingScale),
                  _figmaPlan(
                    context,
                    pet.id,
                    selectedService,
                    'PetLove',
                    verticalPadding: planVerticalPadding,
                  ),
                  SizedBox(height: planGap * mobileSpacingScale),
                  _figmaPlan(
                    context,
                    pet.id,
                    selectedService,
                    'DogLife',
                    verticalPadding: planVerticalPadding,
                  ),
                  SizedBox(height: planGap * mobileSpacingScale),
                  _figmaPlan(
                    context,
                    pet.id,
                    selectedService,
                    'Particular',
                    verticalPadding: planVerticalPadding,
                  ),
                ],
              ),
            ),
          ),
          desktop: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              key: const ValueKey('plans-desktop-layout'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      PetSummary(pet: pet),
                      const SizedBox(height: 12),
                      Text(
                        selectedService.isEmpty
                            ? 'Nenhum serviço selecionado'
                            : 'Serviço: $selectedService',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    children: _plans(context, pet.id, selectedService),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _figmaHeader(dynamic pet) {
    final species = switch (pet.species?.trim().toLowerCase()) {
      'cachorro' || 'cão' => 'CÃO',
      'gato' => 'GATO',
      final value when value != null && value.isNotEmpty => value.toUpperCase(),
      _ => 'PET',
    };
    return SizedBox(
      height: 157,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: VH.secondary,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(VH.radiusXLarge),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 37,
              left: 50,
              right: 50,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Convênio',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: VH.onSecondary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: VH.headingFontFamily,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: 173,
                  height: 59,
                  child: DecoratedBox(
                    decoration: inset_shadow.BoxDecoration(
                      color: VH.secondary.withValues(alpha: .2),
                      borderRadius: VH.headerInsetBorderRadius,
                      boxShadow: const [
                        inset_shadow.BoxShadow(
                          color: VH.shadowSubtle,
                          offset: Offset(2, 2),
                          blurRadius: 2,
                          inset: true,
                        ),
                      ],
                    ),
                    child: Semantics(
                      label: 'Pet selecionado: ${pet.name}, espécie $species',
                      child: ExcludeSemantics(
                        child: Stack(
                          children: [
                            Positioned(
                              left: 8,
                              width: 110,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    species,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: VH.bodyFontFamily,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 117,
                              top: 12,
                              width: 32,
                              height: 36,
                              child: PetAvatar(
                                image: pet.imagePath,
                                photoBase64: pet.photoBase64,
                                species: pet.species,
                                size: 32,
                                listSilhouette: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pílula do Figma: 254×59 colada à borda esquerda, gradiente rosa→fundo e
  /// setas duplas fora da pílula. Mesma rota/argumentos de [_plans].
  Widget _figmaPlan(
    BuildContext context,
    String petId,
    String service,
    String plan, {
    required double verticalPadding,
  }) {
    void open() => _openPlan(context, petId, service, plan);
    final allowPlanTitleWrap =
        MediaQuery.of(context).textScaler.scale(20) > 20.5;
    final radius = switch (plan) {
      'PetLove' => const BorderRadius.only(
        topRight: Radius.circular(800),
        bottomRight: Radius.circular(400),
      ),
      'Particular' => const BorderRadius.only(
        topRight: Radius.circular(400),
        bottomRight: Radius.circular(800),
      ),
      'DogLife' => const BorderRadius.horizontal(right: Radius.circular(25)),
      _ => const BorderRadius.horizontal(right: Radius.circular(29.5)),
    };
    final (begin, end) = switch (plan) {
      'PetLove' => (const Alignment(-1, -.995), const Alignment(1, .995)),
      'Particular' => (const Alignment(-1, .995), const Alignment(1, -.995)),
      _ => (Alignment.centerLeft, Alignment.centerRight),
    };
    return Row(
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 254),
            child: Material(
              color: Colors.transparent,
              child: Ink(
                key: ValueKey('convenio-plan-pill-$plan'),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    colors: const [VH.secondary, VH.background],
                  ),
                  borderRadius: radius,
                  boxShadow: VH.controlShadow,
                ),
                child: InkWell(
                  onTap: open,
                  borderRadius: radius,
                  mouseCursor: SystemMouseCursors.click,
                  overlayColor: WidgetStateProperty.resolveWith(
                    VH.interactionOverlay,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 59),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        15,
                        verticalPadding,
                        12,
                        verticalPadding,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: VetPictogram(plan),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: allowPlanTitleWrap
                                ? Text(
                                    plan == 'DogLife' ? 'Doglife' : plan,
                                    style: _planTitleStyle,
                                  )
                                : FittedBox(
                                    alignment: Alignment.centerLeft,
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      plan == 'DogLife' ? 'Doglife' : plan,
                                      style: _planTitleStyle,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 9.5),
        SizedBox(
          width: 48,
          height: 59,
          child: ExcludeFocus(
            child: ExcludeSemantics(
              child: IconButton(
                tooltip: plan,
                padding: EdgeInsets.zero,
                onPressed: open,
                icon: SizedBox(
                  width: 22,
                  height: 29,
                  child: Center(
                    child: Image.asset(
                      'assets/imagens/figma/convenio-chevron.png',
                      width: 17,
                      height: 19,
                      fit: BoxFit.fill,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openPlan(
    BuildContext context,
    String petId,
    String service,
    String plan,
  ) {
    if (service.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Selecione pelo menos um serviço antes de continuar.',
            ),
            action: SnackBarAction(
              label: 'Selecionar serviços',
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                '/servicos',
                arguments: {'petId': petId},
              ),
            ),
          ),
        );
      return;
    }
    Navigator.pushNamed(
      context,
      '/nova-consulta',
      arguments: {'petId': petId, 'service': service, 'plan': plan},
    );
  }

  List<Widget> _plans(BuildContext context, String petId, String service) => [
    for (final plan in ['PetLove', 'DogLife', 'Particular'])
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: VetChoicePill(
          label: plan,
          icon: VetPictogram(plan),
          onTap: () => _openPlan(context, petId, service, plan),
        ),
      ),
  ];
}
