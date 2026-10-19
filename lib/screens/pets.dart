import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../pages/pets_page.dart';
import '../theme.dart';
import '../widgets/pet_summary.dart';
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
    return VHPage(
      tab: '/servicos',
      children: [
        const VHHeader('Serviços'),
        Padding(
          padding: const EdgeInsets.all(20),
          child: VetResponsiveLayout(
            mobile: Column(
              children: [
                PetSummary(pet: pet),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                ...categories.entries.map((entry) => _category(pet, entry)),
              ],
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

  Widget _category(dynamic pet, MapEntry<String, List<String>> entry) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: VH.controlShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Material(
              color: VH.secondary.withValues(alpha: .25),
              child: Column(
                children: [
                  Ink(
                    decoration: BoxDecoration(gradient: VH.softGradient),
                    child: ListTile(
                      minTileHeight: 59,
                      leading: SizedBox(
                        width: 30,
                        height: 30,
                        child: VetPictogram(entry.key),
                      ),
                      title: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      trailing: AnimatedRotation(
                        turns: open == entry.key ? .5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: const Icon(
                          Icons.expand_more,
                          color: VH.foreground,
                        ),
                      ),
                      onTap: () => setState(
                        () => open = open == entry.key ? null : entry.key,
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 240),
                    alignment: Alignment.topCenter,
                    child: open != entry.key
                        ? const SizedBox(width: double.infinity)
                        : Column(
                            children: [
                              for (final option in entry.value) ...[
                                const Divider(height: 1, thickness: .5),
                                ListTile(
                                  minTileHeight: 48,
                                  dense: true,
                                  title: Text(option),
                                  trailing: const VetChevron(),
                                  selected: servicoAtual == option,
                                  hoverColor: VH.secondary.withValues(
                                    alpha: .15,
                                  ),
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
                                ),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
        const VHHeader('Convênio'),
        Padding(
          padding: const EdgeInsets.all(20),
          child: VetResponsiveLayout(
            mobile: Column(
              children: [
                PetSummary(pet: pet),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                ..._plans(context, pet.id, service),
              ],
            ),
            desktop: Row(
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
