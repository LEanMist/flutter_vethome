import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../core/utils/pet_photo.dart';
import '../core/utils/vet_nav.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../pages/editar_pet_page.dart';
import '../theme/vet_colors.dart';
import '../widgets/vet/vet_card.dart';
import '../widgets/vet/vet_page_scaffold.dart';
import '../widgets/pets/pet_avatar.dart';
import '../widgets/pet_photo_button.dart';
import '../widgets/demo_badge.dart';

class DetalhesPetPage extends StatefulWidget {
  const DetalhesPetPage({required this.pet, super.key});

  final PetModel pet;

  @override
  State<DetalhesPetPage> createState() => _DetalhesPetPageState();
}

class _PetInformationPage extends StatefulWidget {
  const _PetInformationPage({required this.pet, required this.onEdit});

  final PetModel pet;
  final Future<bool> Function() onEdit;

  @override
  State<_PetInformationPage> createState() => _PetInformationPageState();
}

class _PetInformationPageState extends State<_PetInformationPage> {
  Future<void> _edit() async {
    final deleted = await widget.onEdit();
    if (!mounted) return;
    if (deleted) {
      Navigator.pop(context, true);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = VetRepository.petById(widget.pet.id) ?? widget.pet;
    final history = VetRepository.consultas(pet.id);
    Widget datum(String label, String value, IconData icon) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 3),
          Container(
            decoration: BoxDecoration(
              color: VetColors.rose.withValues(alpha: .22),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: VetColors.rose, width: 2),
                    color: VetColors.pink,
                  ),
                  child: Icon(icon, color: VetColors.brown, size: 20),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ],
      ),
    );
    final sex = switch (pet.sex?.trim().toLowerCase()) {
      'm' || 'macho' => 'Macho',
      'f' || 'fêmea' || 'femea' => 'Fêmea',
      null || '' => 'Não informado',
      _ => pet.sex!,
    };
    return VetPageScaffold(
      title: 'Detalhes',
      pet: pet,
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                '/saude',
                arguments: {'petId': pet.id},
              ),
              icon: const Icon(Icons.favorite_outline),
              label: const Text('Saúde'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _edit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar'),
            ),
          ),
        ],
      ),
      footerReserveHeight: 64,
      children: [
        VetCard(
          flat: true,
          color: VetColors.rose.withValues(alpha: .25),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: datum('Gênero/Sexo', sex, Icons.transgender)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: datum(
                      'Peso',
                      pet.weightKg == null
                          ? 'Não informado'
                          : fmtPeso(pet.weightKg!),
                      Icons.monitor_weight_outlined,
                    ),
                  ),
                ],
              ),
              datum(
                'Data de nascimento',
                pet.birthDate == null
                    ? 'Não informada'
                    : fmtData(pet.birthDate!),
                Icons.cake_outlined,
              ),
              datum(
                'Raça',
                pet.breed?.trim().isNotEmpty == true
                    ? pet.breed!
                    : 'Não informada',
                Icons.pets,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: datum(
                      'Espécie',
                      pet.species ?? 'Não informada',
                      Icons.category_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: datum(
                      'Castração',
                      pet.neutered == null
                          ? 'Não informada'
                          : (pet.neutered! ? 'Castrado' : 'Não castrado'),
                      Icons.medical_services_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const VetSectionTitle('Histórico de atendimentos'),
        if (history.any((item) => item.isDemonstration)) const DemoBadge(),
        if (history.isEmpty) const Text('Nenhum atendimento registrado.'),
        for (final item in history)
          VetCard(
            flat: true,
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              title: Text(
                item.tipo,
                style: const TextStyle(
                  color: VetColors.brownOnRose,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${fmtData(item.data)} · ${item.veterinario}${item.isDemonstration ? ' · Exemplo' : ''}',
                style: const TextStyle(
                  color: VetColors.brownOnRose,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DetalhesPetPageState extends State<DetalhesPetPage> {
  late PetModel pet = widget.pet;
  Future<void> _photo() async {
    try {
      final value = await PetPhoto.choose(context);
      if (!mounted || value == null) return;
      final saved = await VetRepository.updatePetPhoto(pet.id, value);
      if (!mounted) return;
      setState(() => pet = VetRepository.petById(pet.id) ?? pet);
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Foto atualizada nesta sessão. Não foi possível salvar localmente.',
            ),
          ),
        );
      }
    } on PersistenceBlockedException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Armazenamento local bloqueado. A foto não foi alterada.',
            ),
          ),
        );
      }
    } on PersistenceClearingException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Armazenamento local está sendo apagado. A foto não foi alterada.',
            ),
          ),
        );
      }
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir a imagem.')),
        );
      }
    }
  }

  Future<bool> _edit() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => EditarPetPage(pet: pet, modal: true),
    );
    if (!mounted) return false;
    if (result is PetModel) {
      setState(() => pet = result);
    } else if (result == 'deleted') {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    pet = VetRepository.petById(pet.id) ?? pet;
    final next = proximoAgendamento(VetRepository.realAppointments(pet.id));
    final summary = Center(
      child: SizedBox(
        width: 220,
        child: VetCard(
          flat: true,
          color: Color.alphaBlend(
            VetColors.rose.withValues(alpha: .25),
            VetColors.pink,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 252),
            child: Column(
              children: [
                Text(
                  pet.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, color: VetColors.brown),
                ),
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    PetAvatar(
                      image: pet.imagePath,
                      photoBase64: pet.photoBase64,
                      species: pet.species,
                      size: 160,
                    ),
                    PetPhotoButton(onPressed: _photo),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 328),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _openDetails,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(53),
                      visualDensity: VisualDensity.standard,
                    ),
                    child: const Text('Detalhes'),
                  ),
                ),
                const SizedBox(width: 44),
                Expanded(
                  child: _recordButton(
                    'Vacinação',
                    Icons.vaccines_outlined,
                    '/vacinacao',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: _appointment(next),
        ),
        const SizedBox(height: 112),
        Center(
          child: SizedBox(
            width: 143,
            child: ElevatedButton(
              onPressed: () {
                VetRepository.selectedPetId = pet.id;
                Navigator.pushNamed(context, '/servicos');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: VetColors.brown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                minimumSize: const Size(143, 54),
                visualDensity: VisualDensity.standard,
              ),
              child: const Text('Nova Consulta'),
            ),
          ),
        ),
      ],
    );
    return VetPageScaffold(
      title: 'Pet',
      pet: pet,
      contentMaxWidth: 1120,
      headerOverlap: 53,
      headerAlignTop: true,
      edgeToEdgeContentOnMobile: true,
      children: [
        VetResponsiveLayout(
          mobile: Column(
            children: [summary, const SizedBox(height: 18), actions],
          ),
          desktop: Row(
            key: const ValueKey('pet-details-desktop-layout'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: summary),
              const SizedBox(width: 28),
              Expanded(child: actions),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openDetails() async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _PetInformationPage(pet: pet, onEdit: _edit),
      ),
    );
    if (!mounted) return;
    if (deleted == true) {
      Navigator.pop(context);
    } else {
      setState(() => pet = VetRepository.petById(pet.id) ?? pet);
    }
  }

  Widget _recordButton(String label, IconData icon, String route) =>
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 12),
          minimumSize: const Size.fromHeight(53),
          visualDensity: VisualDensity.standard,
        ),
        onPressed: () =>
            Navigator.pushNamed(context, route, arguments: {'petId': pet.id}),
        icon: Icon(icon),
        label: Text(label),
      );

  Widget _appointment(Agendamento? next) => VetCard(
    flat: true,
    onTap: next == null
        ? null
        : () => vetNavigate(context, 3, initialDate: next.data),
    color: VetColors.rose.withValues(alpha: .2),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 70),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: VetColors.brown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Próximo agendamento',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(next == null ? 'Nenhum agendamento futuro' : next.tipo),
                if (next != null)
                  Text('${fmtDiaMes(next.data)} · ${fmtHora(next.data)}'),
              ],
            ),
          ),
          if (next != null) const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}
