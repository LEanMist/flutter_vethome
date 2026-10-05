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

class VacinacaoPage extends StatelessWidget {
  const VacinacaoPage({required this.pet, super.key});

  final PetModel pet;

  static (Color, IconData, String) _visual(VacinaStatus st) => switch (st) {
    VacinaStatus.emDia => (VetTones.success, Icons.check_circle, 'Em dia'),
    VacinaStatus.vencendo => (
      VetTones.warning,
      Icons.schedule,
      'Vence em breve',
    ),
    VacinaStatus.atrasada => (VetTones.danger, Icons.error, 'Atrasada'),
  };

  @override
  Widget build(BuildContext context) {
    final vacinas = VetRepository.vacinas(pet.id);

    return VetPageScaffold(
      title: 'Carteira de vacinação',
      pet: pet,
      selectedIndex: 0,
      children: [
        PetSummary(pet: pet, size: PetSummarySize.medium),
        Text(
          '${vacinas.where((v) => v.status == VacinaStatus.emDia).length} em dia · ${vacinas.where((v) => v.status != VacinaStatus.emDia).length} ${vacinas.where((v) => v.status != VacinaStatus.emDia).length == 1 ? 'precisa' : 'precisam'} de atenção',
        ),
        const DemoBadge(),
        const VetSectionTitle('Vacinas'),
        if (vacinas.isEmpty) const Text('Nenhuma vacina exibida'),
        for (final v in vacinas) _VacinaCard(v, _visual(v.status)),
      ],
    );
  }
}

class _VacinaCard extends StatelessWidget {
  const _VacinaCard(this.v, this.visual);
  final Vacina v;
  final (Color, IconData, String) visual;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final (cor, icone, label) = visual;

    return VetCard(
      flat: true,
      color: VetColors.rose.withValues(alpha: .24),
      child: Row(
        children: [
          Container(
            width: 42 * s,
            height: 42 * s,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Icon(icone, color: cor, size: 22 * s),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.nome,
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: VetColors.brown,
                  ),
                ),
                Text(
                  'Aplicada: ${fmtData(v.aplicada)}\nPróxima: ${fmtData(v.proxima)}',
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: VetColors.brown.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 6),
                StatusChip(label, cor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
