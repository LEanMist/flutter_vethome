import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../data/vet_repository.dart';
import '../models/vet_models.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets.dart';

/// Complete weeks starting on Sunday, including adjacent months.
List<DateTime> calendarMonthDays(DateTime month) {
  final first = DateTime(month.year, month.month);
  final offset = first.weekday % 7;
  // Six complete weeks keep the calendar height stable during navigation.
  const cells = 42;
  return List.generate(
    cells,
    (i) => DateTime(month.year, month.month, 1 - offset + i),
  );
}

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

  static const meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    final calendarDays = calendarMonthDays(_mes);
    final consultasDoDia = [
      for (final pet in VetRepository.pets)
        for (final agendamento in VetRepository.agendamentos(pet.id))
          if (_sameDay(agendamento.data, _selecionado))
            (
              name: pet.name,
              agendamento: agendamento,
              demo: !VetRepository.realAppointments(
                pet.id,
              ).contains(agendamento),
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
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                key: const ValueKey('agenda-calendar'),
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: VH.secondary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            tooltip: 'Mês anterior',
                            onPressed: () => _changeMonth(-1),
                            icon: const Icon(
                              Icons.chevron_left,
                              color: VH.onSecondary,
                            ),
                          ),
                          Text(
                            '${meses[_mes.month - 1]} ${_mes.year}',
                            style: const TextStyle(
                              color: VH.foreground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Próximo mês',
                            onPressed: () => _changeMonth(1),
                            icon: const Icon(
                              Icons.chevron_right,
                              color: VH.onSecondary,
                            ),
                          ),
                        ],
                      ),
                      GridView.count(
                        crossAxisCount: 7,
                        mainAxisExtent: 37,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final weekday in [
                            'Dom',
                            'Seg',
                            'Ter',
                            'Qua',
                            'Qui',
                            'Sex',
                            'Sáb',
                          ])
                            Center(
                              child: Text(
                                weekday,
                                style: const TextStyle(
                                  color: VH.foreground,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          for (final date in calendarDays)
                            GestureDetector(
                              key: ValueKey(
                                'calendar-${date.year}-${date.month}-${date.day}',
                              ),
                              onTap: () => setState(() {
                                _selecionado = date;
                                _mes = DateTime(date.year, date.month);
                              }),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _sameDay(date, _selecionado)
                                          ? VH.background
                                          : Colors.transparent,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${date.day}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: VH.foreground.withValues(
                                            alpha: date.month == _mes.month
                                                ? 1
                                                : .3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_isDemoDate(date) ||
                                      _hasAppointment(date))
                                    const Positioned(
                                      bottom: 1,
                                      child: CircleAvatar(
                                        radius: 2,
                                        backgroundColor: VH.onSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 32,
              right: 32,
              child: Center(
                child: Container(
                  width: 258,
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
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/escolhaPet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: VH.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nova Consulta'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: Column(
              children: [
                if (consultasDoDia.isEmpty)
                  if (!_isDemoDate(_selecionado))
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 22),
                      child: Text(
                        'Não há consultas neste dia.',
                        style: TextStyle(color: VH.foreground),
                      ),
                    ),
                for (final item in consultasDoDia)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: VH.secondary,
                        borderRadius: BorderRadius.circular(18),
                        border: Border(
                          bottom: BorderSide(
                            color: VH.foreground.withValues(alpha: .25),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.agendamento.tipo,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  fmtHorario(
                                    item.agendamento.data,
                                    item.agendamento.endDate,
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${item.demo ? 'Demonstração · ' : ''}${item.name} · ${item.agendamento.local}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
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
