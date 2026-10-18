import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../data/vet_repository.dart';
import '../../theme.dart';
import '../../widgets.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _mes = DateTime(2026, 1);
  DateTime _selecionado = DateTime(2026, 1, 13);

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
    final firstOffset = DateTime(_mes.year, _mes.month, 1).weekday % 7;
    final daysInMonth = DateTime(_mes.year, _mes.month + 1, 0).day;
    final consultasDoDia = [
      for (final pet in VetRepository.pets)
        for (final agendamento in VetRepository.agendamentos(pet.name))
          if (_sameDay(agendamento.data, _selecionado))
            (pet: pet, agendamento: agendamento),
    ]..sort((a, b) => a.agendamento.data.compareTo(b.agendamento.data));

    return VHPage(
      tab: '/agenda',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: VH.secondary,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: VH.raise,
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
                        color: VH.onSecondary,
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
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 7,
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
                            color: VH.onSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    for (var i = 0; i < firstOffset; i++) const SizedBox(),
                    for (var date = 1; date <= daysInMonth; date++)
                      GestureDetector(
                        onTap: () => setState(
                          () => _selecionado = DateTime(
                            _mes.year,
                            _mes.month,
                            date,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    date == _selecionado.day &&
                                        _mes.year == _selecionado.year &&
                                        _mes.month == _selecionado.month
                                    ? VH.background
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  '$date',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        date == _selecionado.day &&
                                            _mes.year == _selecionado.year &&
                                            _mes.month == _selecionado.month
                                        ? VH.foreground
                                        : VH.onSecondary,
                                  ),
                                ),
                              ),
                            ),
                            if (_isDemoDate(
                                  DateTime(_mes.year, _mes.month, date),
                                ) ||
                                _hasAppointment(
                                  DateTime(_mes.year, _mes.month, date),
                                ))
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
        Container(
          margin: const EdgeInsets.only(top: 16),
          alignment: Alignment.center,
          child: Container(
            width: 250,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: VH.accent.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: VH.secondary, width: 3),
            ),
            child: Text(
              '${_selecionado.day} - '
              '${_weekdayNames[_selecionado.weekday % 7]}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            children: [
              if (_isDemoDate(_selecionado))
                for (final consulta in const [
                  (hora: '10:00', tipo: 'Hemograma'),
                  (hora: '13:00', tipo: 'Urina'),
                  (hora: '16:00', tipo: 'Creatinina'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: VH.card,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: VH.raise,
                      ),
                      child: Row(
                        children: [
                          Text(
                            consulta.hora,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  consulta.tipo,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Fernando · VetHome',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(int.parse(consulta.hora.substring(0, 2)) + 1).toString().padLeft(2, '0')}:00',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (consultasDoDia.isEmpty)
                if (!_isDemoDate(_selecionado))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: Text('Não há consultas neste dia.'),
                  ),
              for (final item in consultasDoDia)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: VH.card,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: VH.raise,
                    ),
                    child: Row(
                      children: [
                        Text(
                          fmtHora(item.agendamento.data),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 14),
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
                                '${item.pet.name} · ${item.agendamento.local}',
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
        const SizedBox(height: 8),
        Center(
          child: PillButton(
            label: 'Nova Consulta',
            onTap: () => Navigator.pushNamed(context, '/escolhaPet'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  static const _weekdayNames = [
    'Domingo',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
  ];

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDemoDate(DateTime date) =>
      date.year == 2026 && date.month == 1 && date.day == 13;

  bool _hasAppointment(DateTime date) => VetRepository.pets.any(
        (pet) => VetRepository.agendamentos(
          pet.name,
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