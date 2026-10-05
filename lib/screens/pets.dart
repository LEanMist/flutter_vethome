import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../pages/pets_page.dart';
import '../theme.dart';
import '../widgets/pet_summary.dart';
import '../widgets/vet_choice_pill.dart';
import '../widgets/pets/pet_card_widget.dart';
import '../widgets.dart';

String servicoAtual = 'Consulta Geral';
String convenioAtual = 'Particular';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VHPage(
      tab: '/pets',
      children: [
        const VHHeader('Pets'),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          constraints: const BoxConstraints(minHeight: 240),
          padding: const EdgeInsets.all(16),
          decoration: insetBox(color: VH.muted),
          child: Column(
            children: [
              for (var i = 0; i < pets.length; i++)
                PetRow(
                  pets[i],
                  onTap: () {
                    VetRepository.selectedPetIndex = i;
                    Navigator.pushNamed(context, '/pet');
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: PillButton(
            onTap: () => Navigator.pushNamed(context, '/cadastroPet'),
            child: const Icon(Icons.add),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class PetInfo extends StatelessWidget {
  const PetInfo(this.pet, {super.key, this.editable = false});

  final Pet pet;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VH.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: VH.raise,
      ),
      child: Column(
        children: [
          if (editable) ...[
            VHField('Nome do Pet', Icons.person, value: pet.name),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: VHField(
                  'Gênero/Sexo',
                  Icons.person_outline,
                  value: pet.sex,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: VHField('Peso', Icons.scale, value: pet.weight)),
            ],
          ),
          const SizedBox(height: 12),
          VHField('Data de Nascimento', Icons.cake, value: pet.birth),
          const SizedBox(height: 12),
          VHField('Raça', Icons.pets, value: pet.breed),
        ],
      ),
    );
  }
}

class PetScreen extends StatelessWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pet = pets[VetRepository.selectedPetIndex];
    return VHPage(
      tab: '/pets',
      children: [
        const VHHeader('Pet'),
        VHBadge(pet.isDog ? 'pet-badge' : 'user-badge', pet.name),
        PetInfo(pet),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 12,
            children: [
              PillButton(
                label: 'Editar',
                color: VH.card,
                textColor: VH.foreground,
                onTap: () => Navigator.pushNamed(context, '/editPet'),
              ),
              PillButton(
                label: 'Nova Consulta',
                onTap: () => Navigator.pushNamed(context, '/servicos'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EditPetScreen extends StatelessWidget {
  const EditPetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VHPage(
      tab: '/pets',
      children: [
        const VHHeader('Editar Pet'),
        PetInfo(pets[VetRepository.selectedPetIndex], editable: true),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Align(
            alignment: Alignment.centerRight,
            child: PillButton(
              label: 'Salvar',
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }
}

class EscolhaPetScreen extends StatelessWidget {
  const EscolhaPetScreen({super.key});
  @override
  Widget build(BuildContext context) {
    if (VetRepository.pets.isEmpty) return const PetsPage();
    return VHPage(
      tab: '/escolhaPet',
      children: [
        const VHHeader('Escolha seu Pet'),
        Container(
          margin: const EdgeInsets.all(22),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFECBEC0),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              for (final pet in VetRepository.pets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: PetCardWidget(
                    pet: pet,
                    onTap: () {
                      VetRepository.selectedPetId = pet.id;
                      Navigator.pushNamed(context, '/servicos');
                    },
                  ),
                ),
            ],
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
          child: PetSummary(pet: pet),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(),
        ),
        for (final entry in categories.entries)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              children: [
                Material(
                  color: VH.secondary.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(22),
                  clipBehavior: Clip.antiAlias,
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
              ],
            ),
          ),
      ],
    );
  }
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
          child: PetSummary(pet: pet),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(),
        ),
        for (final plan in ['PetLove', 'DogLife', 'Particular'])
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: VetChoicePill(
              label: plan,
              icon: VetPictogram(plan),
              onTap: () {
                convenioAtual = plan;
                Navigator.pushNamed(
                  context,
                  '/nova-consulta',
                  arguments: {
                    'petId': pet.id,
                    'service': service,
                    'plan': plan,
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
