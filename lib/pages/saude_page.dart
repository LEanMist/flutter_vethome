import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../theme/vet_colors.dart';
import '../theme/vet_tones.dart';
import '../widgets/pet_summary.dart';
import '../widgets/demo_badge.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/status_chip.dart';
import '../widgets/vet_card.dart';
import '../widgets/vet_page_scaffold.dart';

class SaudePage extends StatelessWidget {
  const SaudePage({required this.pet, super.key});

  final PetModel pet;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final currentPet = VetRepository.petById(pet.id) ?? pet;
    final historico = VetRepository.consultas(pet.id);
    final vacinas = VetRepository.vacinas(pet.id);

    final vermif = historico
        .where((c) => c.tipo == 'Vermifugação')
        .map((c) => fmtDiaMes(c.data))
        .firstOrNull;
    final emDia = vacinasEmDia(vacinas);

    return VetPageScaffold(
      title: 'Saúde',
      pet: currentPet,
      selectedIndex: 0,
      children: [
        PetSummary(pet: currentPet, size: PetSummarySize.medium),
        const VetSectionTitle('Resumo de saúde'),
        const DemoBadge(),
        Text(
          VetRepository.realVaccines(pet.id).isNotEmpty
              ? 'Vermifugação e histórico.'
              : 'Vacinação, vermifugação e histórico.',
          style: const TextStyle(fontSize: 12),
        ),
        Row(
          children: [
            Expanded(
              child: _MiniStatus(
                icon: emDia ? Icons.check_circle : Icons.warning_amber,
                title: 'Vacinação',
                value:
                    '${vacinas.where((v) => v.status == VacinaStatus.emDia).length}/${vacinas.length} em dia',
                color: emDia ? VetTones.success : VetTones.warning,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _MiniStatus(
                icon: Icons.monitor_weight,
                title: 'Peso',
                value: currentPet.weightKg == null
                    ? 'Não informado'
                    : fmtPeso(currentPet.weightKg!),
                color: VetTones.warning,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _MiniStatus(
                icon: Icons.medical_services,
                title: 'Vermifugação',
                value: vermif ?? '—',
                color: VetTones.info,
              ),
            ),
          ],
        ),
        const VetSectionTitle('Histórico de atendimentos'),
        for (final c in historico) _ConsultaCard(c),
      ],
    );
  }
}

class _MiniStatus extends StatelessWidget {
  const _MiniStatus({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    return VetCard(
      flat: true,
      color: VetColors.rose.withValues(alpha: .2),
      padding: EdgeInsets.symmetric(vertical: 10 * s, horizontal: 6 * s),
      child: Column(
        children: [
          Icon(icon, color: VetColors.brown, size: 18 * s),
          SizedBox(height: 6 * s),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11 * s, color: VetColors.brown),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
                color: VetColors.brown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultaCard extends StatelessWidget {
  const _ConsultaCard(this.c);
  final Consulta c;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    return VetCard(
      flat: true,
      color: VetColors.rose.withValues(alpha: .16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                fmtData(c.data),
                style: TextStyle(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w700,
                  color: VetColors.brown,
                ),
              ),
              const Spacer(),
              const StatusChip('Concluído', VetTones.success, dense: true),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            c.tipo,
            style: TextStyle(
              fontSize: 16 * s,
              fontWeight: FontWeight.w700,
              color: VetColors.brown,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            'Veterinário: ${c.veterinario}',
            style: TextStyle(fontSize: 12 * s, color: VetColors.brown),
          ),
          SizedBox(height: 8 * s),
          Text(
            c.descricao,
            style: TextStyle(
              fontSize: 12 * s,
              color: VetColors.brown.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
