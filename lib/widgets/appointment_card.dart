import 'package:flutter/material.dart';
import '../core/utils/formatters.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../data/vet_repository.dart';
import '../theme/vet_colors.dart';
import '../theme/vet_tones.dart';
import 'pet_avatar.dart';
import 'status_chip.dart';
import 'demo_badge.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.pet,
    required this.event,
    this.demo = false,
    this.next = false,
    this.onTap,
  });
  final PetModel pet;
  final Agendamento event;
  final bool demo, next;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final current = VetRepository.petById(pet.id) ?? pet;
    final confirmed = event.status == StatusAgendamento.confirmado;
    return Material(
      color: VetColors.rose.withValues(alpha: next ? .28 : .18),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (next) ...[
                const Text(
                  'Próximo agendamento',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (next) ...[
                    PetAvatar(
                      image: current.imagePath,
                      species: current.species,
                      photoBase64: current.photoBase64,
                      size: 38,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      event.tipo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: VetColors.brown,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    confirmed ? 'Confirmado' : 'Pendente',
                    confirmed ? VetTones.success : VetTones.warning,
                    dense: true,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                current.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: VetColors.brown,
                ),
              ),
              Text(
                '${fmtData(event.data)} · ${fmtHorario(event.data, event.endDate)}',
                style: const TextStyle(color: VetColors.brown),
              ),
              const SizedBox(height: 5),
              Text(
                'Veterinário: ${event.veterinario}',
                style: TextStyle(
                  fontSize: 12,
                  color: VetColors.brown.withValues(alpha: .8),
                ),
              ),
              Text(
                'Local/convênio: ${event.local}',
                style: TextStyle(
                  fontSize: 12,
                  color: VetColors.brown.withValues(alpha: .8),
                ),
              ),
              if (demo) ...[
                const SizedBox(height: 6),
                const DemoBadge(label: 'Demonstração'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
