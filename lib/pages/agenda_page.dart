import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../data/vet_repository.dart';
import '../models/vet_models.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets.dart';
import '../widgets/vet_calendar.dart';

List<DateTime> calendarMonthDays(DateTime month) =>
    VetCalendar.monthDays(month);

typedef _AgendaItem = ({String name, Agendamento agendamento, bool demo});

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key, this.initialDate});
  final DateTime? initialDate;
  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late DateTime _mes;
  late DateTime _selecionado;

  @override
  void initState() {
    super.initState();
    _selecionado = widget.initialDate ?? DateTime.now();
    _mes = DateTime(_selecionado.year, _selecionado.month);
  }

  @override
  Widget build(BuildContext context) {
    final consultasDoDia = <_AgendaItem>[
      for (final pet in VetRepository.pets)
        for (final appointment in VetRepository.agendamentos(pet.id))
          if (_sameDay(appointment.data, _selecionado))
            (
              name: pet.name,
              agendamento: appointment,
              demo: !VetRepository.realAppointments(
                pet.id,
              ).contains(appointment),
            ),
      if (_isDemoDate(_selecionado))
        for (final example in const [
          (hour: 10, type: 'Hemograma'),
          (hour: 13, type: 'Urina'),
          (hour: 16, type: 'Creatinina'),
        ])
          (
            name: 'VetHome',
            demo: true,
            agendamento: Agendamento(
              data: DateTime(2026, 1, 13, example.hour),
              endDate: DateTime(2026, 1, 13, example.hour + 1),
              tipo: example.type,
              veterinario: 'Demonstração',
              local: 'VetHome',
              status: StatusAgendamento.pendente,
            ),
          ),
    ]..sort((a, b) => a.agendamento.data.compareTo(b.agendamento.data));

    return VHPage(
      tab: '/agenda',
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= VH.desktopBreakpoint) {
                return Row(
                  key: const ValueKey('agenda-desktop-layout'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _calendarPanel()),
                    const SizedBox(width: 32),
                    Expanded(child: _appointments(consultasDoDia)),
                  ],
                );
              }
              return Column(
                key: const ValueKey('agenda-mobile-layout'),
                children: [
                  _calendarPanel(),
                  const SizedBox(height: 16),
                  _appointments(consultasDoDia),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _calendarPanel() => Column(
    children: [
      SizedBox(
        key: const ValueKey('agenda-calendar'),
        child: VetCalendar(
          month: _mes,
          selected: _selecionado,
          onPreviousMonth: () => _changeMonth(-1),
          onNextMonth: () => _changeMonth(1),
          onSelected: (date) => setState(() {
            _selecionado = date;
            _mes = DateTime(date.year, date.month);
          }),
          hasIndicator: (date) => _isDemoDate(date) || _hasAppointment(date),
        ),
      ),
      Transform.translate(
        offset: const Offset(0, -10),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 258),
          height: 41,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: VetColors.pinkOverlay50,
            border: Border.all(color: VH.secondary),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '${_selecionado.day} - ${_weekdayNames[_selecionado.weekday % 7]}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
  );

  Widget _appointments(List<_AgendaItem> appointments) {
    final button = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/escolhaPet'),
        style: ElevatedButton.styleFrom(
          backgroundColor: VH.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
        ),
        child: const Text('Nova Consulta'),
      ),
    );
    return Column(
      key: const ValueKey('agenda-timeline'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (appointments.isEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'Não há consultas neste dia.',
              textAlign: TextAlign.center,
              style: TextStyle(color: VH.foreground),
            ),
          ),
          button,
        ] else ...[
          for (final item in appointments)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 54,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        fmtHora(item.agendamento.data),
                        style: const TextStyle(
                          color: VH.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: VH.secondary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: VH.controlShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.agendamento.tipo,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            fmtHorario(
                              item.agendamento.data,
                              item.agendamento.endDate,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${item.demo ? 'Demonstração · ' : ''}${item.name} · ${item.agendamento.local}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          button,
        ],
      ],
    );
  }

  static const _weekdayNames = [
    'Domingo',
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  bool _isDemoDate(DateTime date) =>
      date.year == 2026 && date.month == 1 && date.day == 13;
  bool _hasAppointment(DateTime date) => VetRepository.pets.any(
    (pet) => VetRepository.agendamentos(
      pet.id,
    ).any((appointment) => _sameDay(appointment.data, date)),
  );

  void _changeMonth(int amount) {
    setState(() {
      _mes = DateTime(_mes.year, _mes.month + amount);
      final lastDay = DateTime(_mes.year, _mes.month + 1, 0).day;
      _selecionado = DateTime(
        _mes.year,
        _mes.month,
        _selecionado.day.clamp(1, lastDay),
      );
    });
  }
}
