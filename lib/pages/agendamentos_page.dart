import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointment_detail_dialog.dart';
import '../widgets/pet_summary.dart';
import '../widgets/vet/vet_card.dart';
import '../widgets/vet/vet_page_scaffold.dart';

class AgendamentosPage extends StatefulWidget {
  const AgendamentosPage({super.key, required this.pet});

  final PetModel pet;

  @override
  State<AgendamentosPage> createState() => _AgendamentosPageState();
}

class _AgendamentosPageState extends State<AgendamentosPage> {
  Future<void> _openAppointmentDetails(Agendamento appointment) async {
    final deleteRequested = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppointmentDetailDialog(
        pet: widget.pet,
        appointment: appointment,
        onDelete: () => Navigator.pop(dialogContext, true),
      ),
    );
    if (!mounted || deleteRequested != true) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir consulta?'),
        content: Text(
          'Remover ${appointment.tipo} de ${widget.pet.name} em '
          '${fmtData(appointment.data)} deste dispositivo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    try {
      final removed = VetRepository.removeAgendamento(
        widget.pet.id,
        appointment,
      );
      if (!removed) {
        _showMessage('Esta consulta já não está salva.');
        return;
      }
      setState(() {});
      final saved = await VetRepository.flush();
      if (!mounted) return;
      _showMessage(
        saved
            ? 'Consulta removida.'
            : 'Consulta removida nesta sessão. Não foi possível salvar localmente.',
      );
    } on PersistenceBlockedException {
      if (!mounted) return;
      _showMessage(
        'Armazenamento local bloqueado. A consulta não foi removida.',
      );
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Widget _appointmentList({
    required String listKey,
    required List<Agendamento> events,
    required List<Agendamento> real,
  }) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 900;
      final width = desktop
          ? (constraints.maxWidth - 16) / 2
          : constraints.maxWidth;
      return Wrap(
        key: ValueKey(listKey),
        spacing: 16,
        runSpacing: 12,
        children: [
          for (final event in events)
            SizedBox(
              key: ValueKey(
                'appointment-card-${event.data.microsecondsSinceEpoch}-${event.tipo}',
              ),
              width: width,
              child: AppointmentCard(
                pet: widget.pet,
                event: event,
                demo: !real.contains(event),
                onTap: real.contains(event)
                    ? () => _openAppointmentDetails(event)
                    : null,
              ),
            ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final real = VetRepository.realAppointments(widget.pet.id);
    final events = [...VetRepository.agendamentos(widget.pet.id)]
      ..sort((a, b) => a.data.compareTo(b.data));
    final next = proximoAgendamento(real);
    final now = DateTime.now();
    final future = events.where((event) => event.data.isAfter(now)).toList();
    final history = events.where((event) => !event.data.isAfter(now)).toList();
    final otherFuture = future
        .where((event) => !identical(event, next))
        .toList();

    return VetPageScaffold(
      title: 'Agendamentos',
      pet: widget.pet,
      selectedIndex: 3,
      contentMaxWidth: 1120,
      children: [
        PetSummary(pet: widget.pet, size: PetSummarySize.medium),
        if (next == null && otherFuture.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Nenhum agendamento futuro'),
          )
        else if (next != null)
          AppointmentCard(
            pet: widget.pet,
            event: next,
            next: true,
            onTap: () =>
                Navigator.pushNamed(context, '/agenda', arguments: next.data),
          ),
        if (otherFuture.isNotEmpty) ...[
          Semantics(
            key: const ValueKey('appointments-upcoming-section-heading'),
            header: true,
            child: VetSectionTitle(
              next == null
                  ? 'Agendamentos futuros'
                  : 'Outros agendamentos futuros',
            ),
          ),
          _appointmentList(
            listKey: 'appointments-upcoming-list',
            events: otherFuture,
            real: real,
          ),
        ],
        Semantics(
          key: ValueKey('appointments-history-section-heading'),
          header: true,
          child: VetSectionTitle('Histórico de agendamentos'),
        ),
        if (history.isEmpty)
          const Text('Nenhum agendamento anterior')
        else
          _appointmentList(
            listKey: 'appointments-history-list',
            events: history,
            real: real,
          ),
      ],
    );
  }
}
