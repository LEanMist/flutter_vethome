import 'package:flutter/material.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../widgets/pet_summary.dart';
import '../widgets/appointment_card.dart';
import '../widgets/vet_page_scaffold.dart';
import '../widgets/vet_card.dart';

class AgendamentosPage extends StatelessWidget {
  const AgendamentosPage({super.key, required this.pet});
  final PetModel pet;
  @override
  Widget build(BuildContext context) {
    final real = VetRepository.realAppointments(pet.id);
    final events = [...VetRepository.agendamentos(pet.id)]
      ..sort((a, b) => a.data.compareTo(b.data));
    final next = proximoAgendamento(real);
    return VetPageScaffold(
      title: 'Agendamentos',
      pet: pet,
      selectedIndex: 3,
      children: [
        PetSummary(pet: pet, size: PetSummarySize.medium),
        if (next == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Nenhum agendamento futuro'),
          )
        else
          AppointmentCard(
            pet: pet,
            event: next,
            next: true,
            onTap: () =>
                Navigator.pushNamed(context, '/agenda', arguments: next.data),
          ),
        const VetSectionTitle('Histórico de agendamentos'),
        if (events.isEmpty) const Text('Nenhum agendamento'),
        for (final event in events)
          AppointmentCard(pet: pet, event: event, demo: !real.contains(event)),
      ],
    );
  }
}
