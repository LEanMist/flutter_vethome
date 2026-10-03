import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../pages/pets_page.dart';
import '../theme.dart';
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
      tab: '/agenda',
      children: [
        const VHHeader('Escolha seu Pet'),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            children: [
              for (var i = 0; i < pets.length; i++)
                PetRow(
                  pets[i],
                  onTap: () {
                    VetRepository.selectedPetIndex = i;
                    Navigator.pushNamed(context, '/servicos');
                  },
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
  bool aberto = true;

  @override
  Widget build(BuildContext context) {
    final pet = VetRepository.selectedPet;
    if (pet == null) return const PetsPage();
    final cao = !(pet.species?.toLowerCase().contains('gato') ?? false);
    void convenio([String? service]) {
      if (service != null) servicoAtual = service;
      Navigator.pushNamed(context, '/convenio');
    }

    return VHPage(
      tab: '/pets',
      children: [
        VHHeader('Serviços', bottom: _PetTypeTag(isDog: cao)),
        const SizedBox(height: 122),
        SidePill(
          Icons.medical_services,
          'Exames',
          onTap: () => setState(() => aberto = !aberto),
          extra: Icon(
            aberto ? Icons.expand_less : Icons.expand_more,
            size: 18,
            color: Colors.white,
          ),
        ),
        if (aberto)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 210,
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: VH.background.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33683F40),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (final exame in ['Hemograma', 'Creatinina', 'Urina'])
                    SizedBox(
                      height: 25,
                      child: InkWell(
                        onTap: () => convenio(exame),
                        child: Center(
                          child: Text(
                            exame,
                            style: const TextStyle(
                              fontSize: 12,
                              color: VH.foreground,
                              fontFamily: 'MontserratAlternates',
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 38),
        SidePill(Icons.vaccines, 'Vacinas', onTap: () => convenio('Vacinação')),
        const SizedBox(height: 39),
        SidePill(
          Icons.memory,
          'Microchipagem',
          onTap: () => convenio('Microchipagem'),
        ),
        const SizedBox(height: 39),
        SidePill(
          Icons.description,
          'Atestados',
          onTap: () => convenio('Atestado'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class ConvenioScreen extends StatefulWidget {
  const ConvenioScreen({super.key});

  @override
  State<ConvenioScreen> createState() => _ConvenioScreenState();
}

class _ConvenioScreenState extends State<ConvenioScreen> {
  String _selectedPlan = convenioAtual;

  @override
  Widget build(BuildContext context) {
    final pet = VetRepository.selectedPet;
    if (pet == null) return const PetsPage();
    final cao = !(pet.species?.toLowerCase().contains('gato') ?? false);
    const plans = [
      (name: 'PetLove', icon: Icons.favorite_outline),
      (name: 'Doglife', icon: Icons.health_and_safety_outlined),
      (name: 'Particular', icon: Icons.person_outline),
    ];
    void agendar() {
      convenioAtual = _selectedPlan;
      Navigator.pushNamed(
        context,
        '/nova-consulta',
        arguments: {'pet': pet, 'service': servicoAtual, 'plan': _selectedPlan},
      );
    }

    return VHPage(
      tab: '/pets',
      children: [
        VHHeader('Convênio', bottom: _PetTypeTag(isDog: cao)),
        const SizedBox(height: 185),
        for (var i = 0; i < plans.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == plans.length - 1 ? 14 : 60),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => setState(() => _selectedPlan = plans[i].name),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(30),
                ),
                child: Ink(
                  width: 254,
                  height: 59,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [VH.secondary, VH.background],
                    ),
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(i == 0 ? 50 : 25),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33683F40),
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 15),
                      Icon(plans[i].icon, color: Colors.white, size: 29),
                      const SizedBox(width: 17),
                      Expanded(
                        child: Text(
                          plans[i].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'MontserratAlternates',
                          ),
                        ),
                      ),
                      Icon(
                        _selectedPlan == plans[i].name
                            ? Icons.radio_button_checked
                            : Icons.chevron_right,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: agendar,
              style: ElevatedButton.styleFrom(
                backgroundColor: VH.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: const StadiumBorder(),
              ),
              child: const Text('Continuar'),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _PetTypeTag extends StatelessWidget {
  const _PetTypeTag({required this.isDog});

  final bool isDog;

  @override
  Widget build(BuildContext context) {
    if (isDog) {
      return Image.asset(
        'assets/imagens/figma/frame-20.png',
        width: 173,
        height: 52,
        fit: BoxFit.contain,
      );
    }

    return Container(
      width: 173,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: VH.background.withValues(alpha: 0.55),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
          bottom: Radius.circular(10),
        ),
      ),
      child: const Text(
        'GATO',
        style: TextStyle(
          color: VH.foreground,
          fontFamily: 'Comfortaa',
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
