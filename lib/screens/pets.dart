import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
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
        const VHHeader('Pets', face: 'ω'),
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
                    petAtual = i;
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
    final pet = pets[petAtual];
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
        PetInfo(pets[petAtual], editable: true),
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
                    petAtual = i;
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
    final cao = pets[petAtual].isDog;
    void convenio([String? service]) {
      if (service != null) servicoAtual = service;
      Navigator.pushNamed(context, '/convenio');
    }

    return VHPage(
      tab: '/pets',
      children: [
        VHHeader('Serviços', sub: cao ? 'CÃO' : 'GATO'),
        const SizedBox(height: 24),
        SidePill(
          Icons.medical_services,
          'Exames',
          onTap: () => setState(() => aberto = !aberto),
          extra: Icon(aberto ? Icons.expand_less : Icons.expand_more, size: 18),
        ),
        if (aberto)
          Container(
            margin: const EdgeInsets.only(left: 44, top: 8, right: 44),
            padding: const EdgeInsets.all(8),
            decoration: insetBox(color: VH.card, radius: 12),
            child: Column(
              children: [
                for (final exame in ['Hemograma', 'Creatinina', 'Urina'])
                  ListTile(
                    dense: true,
                    title: Text(exame, textAlign: TextAlign.center),
                    onTap: () => convenio(exame),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        SidePill(Icons.vaccines, 'Vacinas', onTap: () => convenio('Vacinação')),
        const SizedBox(height: 16),
        SidePill(
          Icons.memory,
          'Microchipagem',
          onTap: () => convenio('Microchipagem'),
        ),
        const SizedBox(height: 16),
        SidePill(
          Icons.description,
          'Atestados',
          onTap: () => convenio('Atestado'),
        ),
        const SizedBox(height: 16),
        SidePill(
          Icons.schedule,
          'Ver agenda',
          onTap: () => Navigator.pushReplacementNamed(context, '/agenda'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class ConvenioScreen extends StatelessWidget {
  const ConvenioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cao = pets[petAtual].isDog;
    void agendar(String plan) {
      convenioAtual = plan;
      Navigator.pushNamed(
        context,
        '/nova-consulta',
        arguments: {
          'pet': VetRepository.pets[petAtual],
          'service': servicoAtual,
          'plan': convenioAtual,
        },
      );
    }

    return VHPage(
      tab: '/pets',
      children: [
        VHHeader('Convênio', sub: cao ? 'CÃO' : 'GATO'),
        const SizedBox(height: 28),
        SidePill(Icons.favorite, 'PetLove', onTap: () => agendar('PetLove')),
        const SizedBox(height: 16),
        SidePill(
          Icons.health_and_safety,
          'Doglife',
          onTap: () => agendar('Doglife'),
        ),
        const SizedBox(height: 16),
        SidePill(
          Icons.person,
          'Particular',
          onTap: () => agendar('Particular'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
