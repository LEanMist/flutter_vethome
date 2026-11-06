import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

import '../data/vet_repository.dart';
import '../pages/pets_page.dart';
import '../theme.dart';
import '../widgets/pet_summary.dart';
import '../widgets/pets/pet_avatar.dart';
import '../widgets/vet_choice_pill.dart';
import '../widgets/pets/pet_card_widget.dart';
import '../widgets.dart';
import '../widgets/vet/vet_page_scaffold.dart';

String servicoAtual = 'Consulta Geral';

class EscolhaPetScreen extends StatelessWidget {
  const EscolhaPetScreen({super.key});
  @override
  Widget build(BuildContext context) {
    if (VetRepository.pets.isEmpty) return const PetsPage();
    return VHPage(
      tab: '/escolhaPet',
      children: [
        const VHHeader('Escolha seu Pet'),
        Padding(
          padding: const EdgeInsets.all(22),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 900;
              final width = desktop
                  ? (constraints.maxWidth - 22) / 2
                  : constraints.maxWidth;
              return Wrap(
                key: ValueKey(
                  desktop
                      ? 'pet-choice-desktop-grid'
                      : 'pet-choice-mobile-list',
                ),
                spacing: 22,
                runSpacing: 18,
                children: [
                  for (final pet in VetRepository.pets)
                    SizedBox(
                      width: width,
                      child: PetCardWidget(
                        pet: pet,
                        onTap: () {
                          VetRepository.selectedPetId = pet.id;
                          Navigator.pushNamed(context, '/servicos');
                        },
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
}

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});
  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  final Set<String> _expanded = {'Exames', 'Vacinas'};
  final Set<String> _selected = <String>{};

  void _toggleCategory(String name) => setState(() {
    if (!_expanded.remove(name)) _expanded.add(name);
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
    servicoAtual = combined;
    Navigator.pushNamed(
      context,
      '/convenio',
      arguments: {'petId': petId, 'service': combined},
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
    final pet = VetRepository.selectedPet;
    if (pet == null) return const PetsPage();
    final desktop = MediaQuery.sizeOf(context).width >= VH.desktopBreakpoint;
    final species = switch (pet.species?.trim().toLowerCase()) {
      'cachorro' || 'cão' => 'CÃO',
      'gato' => 'GATO',
      final value when value != null && value.isNotEmpty => value.toUpperCase(),
      _ => 'PET',
    };
    return VHPage(
      tab: '/servicos',
      children: [
        desktop ? const VHHeader('Serviços') : _servicesHeader(pet, species),
        Padding(
          padding: EdgeInsets.fromLTRB(
            desktop ? 20 : 0,
            desktop ? 20 : 28,
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
                        _continueButton(pet.id, topPadding: 9),
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
                      _continueButton(pet.id),
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
          if (Navigator.of(context).canPop())
            Positioned(
              top: 8,
              left: 10,
              child: IconButton(
                tooltip: 'Voltar',
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
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
  Widget _servicePill(String name) => Row(
    children: [
      Expanded(
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: VH.softGradient,
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
                height: 59,
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
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: VH.bodyFontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
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
      SizedBox(
        width: 42,
        height: 48,
        child: IconButton(
          tooltip: name,
          onPressed: () => _toggleCategory(name),
          icon: _expanded.contains(name)
              ? const Icon(Icons.keyboard_arrow_down, color: VH.foreground)
              : const VetChevron(),
        ),
      ),
    ],
  );

  Widget _category(
    dynamic pet,
    MapEntry<String, List<String>> entry,
  ) => SizedBox(
    width: 306,
    child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.sizeOf(context).width < VH.compactBreakpoint
            ? (entry.key == 'Microchipagem' ? 22 : 20)
            : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: entry.key,
            expanded: _expanded.contains(entry.key),
            onTap: () => _toggleCategory(entry.key),
            child: ExcludeSemantics(child: _servicePill(entry.key)),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            alignment: Alignment.topLeft,
            child: !_expanded.contains(entry.key)
                ? const SizedBox(width: 228)
                : ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(25),
                    ),
                    child: Material(
                      color: VH.secondary.withValues(alpha: .25),
                      child: SizedBox(
                        width: 228,
                        child: Column(
                          children: [
                            for (final option in entry.value)
                              Semantics(
                                button: true,
                                selected: _selected.contains(option),
                                child: InkWell(
                                  onTap: () => _toggleService(option),
                                  overlayColor: WidgetStateProperty.resolveWith(
                                    VH.interactionOverlay,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight:
                                          MediaQuery.sizeOf(context).width <
                                              VH.compactBreakpoint
                                          ? 33
                                          : 48,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              option,
                                              style: const TextStyle(
                                                color: VH.foreground,
                                                fontFamily: VH.bodyFontFamily,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 15,
                                            height: 15,
                                            decoration: BoxDecoration(
                                              color: _selected.contains(option)
                                                  ? VH.primary.withValues(
                                                      alpha: .65,
                                                    )
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: VH.primary,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                        ],
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
          ),
        ],
      ),
    ),
  );
}

class ConvenioScreen extends StatelessWidget {
  const ConvenioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final values = args is Map ? args : const {};
    final pet = values['petId'] is String
        ? VetRepository.petById(values['petId'] as String)
        : VetRepository.selectedPet;
    if (pet == null) return const PetsPage();
    final service = values['service'] as String? ?? servicoAtual;
    return VHPage(
      tab: '/convenio',
      children: [
        // Figma 4010:387: cabeçalho de 157 px com aba da espécie (somente mobile).
        VetResponsiveLayout(
          breakpoint: VH.compactBreakpoint,
          mobile: _figmaHeader(context, pet),
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
                  // O Figma deixa esse intervalo livre antes do primeiro plano.
                  const SizedBox(height: 132),
                  // Alinha o primeiro plano a y≈342 no frame 2783:840.
                  const SizedBox(height: 55),
                  for (final plan in const ['PetLove', 'DogLife', 'Particular'])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: _figmaPlan(context, pet.id, service, plan),
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
                        'Serviço: $service',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(children: _plans(context, pet.id, service)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _figmaHeader(BuildContext context, dynamic pet) {
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
            if (Navigator.of(context).canPop())
              Positioned(
                top: 8,
                left: 10,
                child: IconButton(
                  tooltip: 'Voltar',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, color: VH.onSecondary),
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
  /// setas duplas fora da pílula (x≈287). Mesma rota/argumentos de [_plans].
  Widget _figmaPlan(
    BuildContext context,
    String petId,
    String service,
    String plan,
  ) {
    void open() => Navigator.pushNamed(
      context,
      '/nova-consulta',
      arguments: {'petId': petId, 'service': service, 'plan': plan},
    );
    final radius = BorderRadius.horizontal(
      right: Radius.circular(plan == 'DogLife' ? 25 : 29.5),
    );
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
                      padding: const EdgeInsets.fromLTRB(15, 10, 12, 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: VetPictogram(plan),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              plan == 'DogLife' ? 'Doglife' : plan,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: VH.bodyFontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
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
      ],
    );
  }

  List<Widget> _plans(BuildContext context, String petId, String service) => [
    for (final plan in ['PetLove', 'DogLife', 'Particular'])
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: VetChoicePill(
          label: plan,
          icon: VetPictogram(plan),
          onTap: () => Navigator.pushNamed(
            context,
            '/nova-consulta',
            arguments: {'petId': petId, 'service': service, 'plan': plan},
          ),
        ),
      ),
  ];
}
