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
  String? open = 'Exames';
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
        VHHeader(
          'Serviços',
          bottom: desktop
              ? null
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      species,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: VH.headingFontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
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
        Padding(
          padding: EdgeInsets.fromLTRB(
            desktop ? 20 : 0,
            desktop ? 20 : 32,
            desktop ? 20 : 0,
            20,
          ),
          child: VetResponsiveLayout(
            breakpoint: VH.compactBreakpoint,
            mobile: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PetSummary(pet: pet),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(),
                  ),
                  const SizedBox(height: 12),
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
                    children: categories.entries
                        .map((entry) => _category(pet, entry))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _category(
    dynamic pet,
    MapEntry<String, List<String>> entry,
  ) => SizedBox(
    width: 306,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: entry.key,
            expanded: open == entry.key,
            onTap: () =>
                setState(() => open = open == entry.key ? null : entry.key),
            child: ExcludeSemantics(
              child: VetChoicePill(
                label: entry.key,
                icon: VetPictogram(entry.key),
                expanded: open == entry.key,
                onTap: () =>
                    setState(() => open = open == entry.key ? null : entry.key),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            alignment: Alignment.topLeft,
            child: open != entry.key
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
                                selected: servicoAtual == option,
                                child: InkWell(
                                  onTap: () {
                                    setState(() => servicoAtual = option);
                                    Navigator.pushNamed(
                                      context,
                                      '/convenio',
                                      arguments: {
                                        'petId': pet.id,
                                        'service': option,
                                      },
                                    );
                                  },
                                  overlayColor: WidgetStateProperty.resolveWith(
                                    VH.interactionOverlay,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: 48,
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
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: servicoAtual == option
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
                  // Mantém o resumo do pet na faixa de 116 px antes do 1º plano.
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 116),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: PetSummary(pet: pet),
                    ),
                  ),
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
                              plan,
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
            icon: const SizedBox(
              width: 22,
              height: 29,
              child: FittedBox(child: VetChevron()),
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
