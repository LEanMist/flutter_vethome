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
import '../widgets/pet_summary.dart';

class DetalhesPetPage extends StatefulWidget {
  const DetalhesPetPage({required this.pet, super.key});

  final PetModel pet;

  @override
  State<DetalhesPetPage> createState() => _DetalhesPetPageState();
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is FormatException
                  ? e.message
                  : 'Não foi possível abrir a imagem.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _edit() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => EditarPetPage(pet: pet, modal: true),
    );
    if (!mounted) return;
    if (result is PetModel) {
      setState(() => pet = result);
    } else if (result == 'deleted') {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    pet = VetRepository.petById(pet.id) ?? pet;
    final next = proximoAgendamento(VetRepository.realAppointments(pet.id));
    final summary = PetSummary(
      pet: pet,
      size: PetSummarySize.detailed,
      onEdit: _edit,
      onPhoto: _photo,
    );
    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            VetRepository.selectedPetId = pet.id;
            Navigator.pushNamed(context, '/servicos');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: VetColors.brown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
          ),
          child: const Text('Nova Consulta'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _recordButton('Saúde', Icons.favorite_outline, '/saude'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _recordButton(
                'Vacinação',
                Icons.vaccines_outlined,
                '/vacinacao',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _appointment(next),
      ],
    );
    return VetPageScaffold(
      title: 'Detalhes',
      pet: pet,
      contentMaxWidth: 1120,
      children: [
        VetResponsiveLayout(
          mobile: Column(
            children: [summary, const SizedBox(height: 12), actions],
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

  Widget _recordButton(String label, IconData icon, String route) =>
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 12),
          minimumSize: const Size.fromHeight(48),
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
  );
}
