import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../theme/vet_colors.dart';
import '../theme/vet_tones.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/status_chip.dart';
import '../widgets/vet_card.dart';
import '../widgets/vet_page_scaffold.dart';

/// Aba "Agenda" da barra inferior (índice 3).
class AgendamentosPage extends StatelessWidget {
  const AgendamentosPage({required this.pet, super.key});

  final PetModel pet;

  static (Color, String) _status(StatusAgendamento st) => switch (st) {
    StatusAgendamento.confirmado => (VetTones.success, 'Confirmado'),
    StatusAgendamento.pendente => (VetTones.warning, 'Pendente'),
  };

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final lista = [...VetRepository.agendamentos(pet.id)]
      ..sort((a, b) => a.data.compareTo(b.data));
    final proximo = proximoAgendamento(lista);

    return VetPageScaffold(
      title: 'Agenda',
      pet: pet,
      selectedIndex: 3,
      isTabRoot: true,
      children: [
        VetCard(
          child: Row(
            children: [
              PetAvatar(image: pet.imagePath, size: 60),
              SizedBox(width: 12 * s),
              Expanded(
                child: proximo == null
                    ? Text(
                        'Nenhum agendamento futuro',
                        style: TextStyle(
                          fontSize: 14 * s,
                          color: VetColors.brown,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Próximo agendamento',
                            style: TextStyle(
                              fontSize: 12 * s,
                              color: VetColors.brown.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            '${fmtDiaMes(proximo.data)} · ${fmtHora(proximo.data)}',
                            style: TextStyle(
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w700,
                              color: VetColors.brown,
                            ),
                          ),
                        ],
                      ),
              ),
              if (proximo != null) ...[
                SizedBox(width: 8 * s),
                StatusChip(
                  _status(proximo.status).$2,
                  _status(proximo.status).$1,
                ),
              ],
            ],
          ),
        ),
        const VetSectionTitle('Todos'),
        for (final a in lista) _EventoCard(a, _status(a.status)),
      ],
    );
  }
}

class _EventoCard extends StatelessWidget {
  const _EventoCard(this.a, this.status);
  final Agendamento a;
  final (Color, String) status;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final TextStyle detalhe = TextStyle(
      color: VetColors.brown.withValues(alpha: 0.8),
      fontSize: 12 * s,
    );

    return VetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  a.tipo,
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: VetColors.brown,
                  ),
                ),
              ),
              StatusChip(status.$2, status.$1),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            '${fmtData(a.data)} · ${fmtHora(a.data)}',
            style: detalhe.copyWith(fontSize: 13 * s),
          ),
          SizedBox(height: 4 * s),
          Text('Veterinário: ${a.veterinario}', style: detalhe),
          Text('Local: ${a.local}', style: detalhe),
        ],
      ),
    );
  }
}
