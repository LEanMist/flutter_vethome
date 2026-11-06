import 'dart:math' as math;

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

    final isMobile = MediaQuery.sizeOf(context).width < VH.desktopBreakpoint;
    final page = VHPage(
      tab: '/agenda',
      children: [
        if (isMobile)
          _mobileAgenda(consultasDoDia)
        else
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              key: const ValueKey('agenda-desktop-layout'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _calendarPanel()),
                const SizedBox(width: 32),
                Expanded(child: _appointments(consultasDoDia)),
              ],
            ),
          ),
      ],
    );
    return isMobile
        ? MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: page,
          )
        : page;
  }

  Widget _mobileAgenda(List<_AgendaItem> appointments) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = (width / 390).clamp(0.8, 1.0).toDouble();
    final actionTop = math.max(
      651.0,
      appointments.length > 3 ? 399.0 + 84.0 * appointments.length : 651.0,
    );
    final contentHeight = math.max(692.0, actionTop + 41) * scale;
    final weekdays = const [
      'Domingo',
      'Segunda Feira',
      'Terça Feira',
      'Quarta Feira',
      'Quinta Feira',
      'Sexta Feira',
      'Sábado',
    ];

    return SizedBox(
      key: const ValueKey('agenda-mobile-layout'),
      width: 390 * scale,
      height: contentHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: VetCalendar(
              agendaPageStyle: true,
              month: _mes,
              selected: _selecionado,
              onPreviousMonth: () => _changeMonth(-1),
              onNextMonth: () => _changeMonth(1),
              onSelected: (date) => setState(() {
                _selecionado = date;
                _mes = DateTime(date.year, date.month);
              }),
            ),
          ),
          Positioned(
            left: 67 * scale,
            top: 323 * scale,
            width: 258 * scale,
            height: 41 * scale,
            child: Container(
              key: const ValueKey('agenda-selected-date'),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: VetColors.pinkOverlay50,
                border: Border.all(color: VetColors.rose, width: 5 * scale),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(100 * scale),
                  bottom: Radius.circular(200 * scale),
                ),
              ),
              child: Text(
                '${_selecionado.day} - ${weekdays[_selecionado.weekday % 7]}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: VH.headingFontFamily,
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.bold,
                  color: VH.foreground,
                ),
              ),
            ),
          ),
          if (appointments.isEmpty)
            Positioned(
              left: 35 * scale,
              right: 35 * scale,
              top: 414 * scale,
              child: Text(
                'Não há consultas neste dia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: VH.bodyFontFamily,
                  fontSize: 14 * scale,
                  color: VH.foreground,
                ),
              ),
            ),
          for (var index = 0; index < appointments.length; index++) ...[
            _mobileAppointment(appointments[index], index, scale),
            if (index < appointments.length - 1)
              Positioned(
                left: 88 * scale,
                top: (465 + 85 * index) * scale,
                child: _FigmaDottedLine(
                  key: ValueKey('agenda-divider-$index'),
                  width: 221 * scale,
                ),
              ),
          ],
          Positioned(
            left: 343 * scale,
            top: 439 * scale,
            width: 24 * scale,
            height: 24 * scale,
            child: ExcludeSemantics(
              child: Icon(
                Icons.expand_less,
                size: 24 * scale,
                color: VH.foreground,
              ),
            ),
          ),
          Positioned(
            left: 343 * scale,
            top: 555 * scale,
            width: 24 * scale,
            height: 24 * scale,
            child: ExcludeSemantics(
              child: Icon(
                Icons.expand_more,
                size: 24 * scale,
                color: VH.foreground,
              ),
            ),
          ),
          Positioned(
            left: 145 * scale,
            top: actionTop * scale,
            width: 99 * scale,
            height: 41 * scale,
            child: Semantics(
              button: true,
              label: 'Nova Consulta',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100 * scale),
                  onTap: () => Navigator.pushNamed(context, '/escolhaPet'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: VH.primary,
                      borderRadius: BorderRadius.circular(100 * scale),
                      boxShadow: const [
                        BoxShadow(
                          color: VetColors.shadowDark,
                          offset: Offset(2, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Nova Consulta',
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: VH.bodyFontFamily,
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileAppointment(_AgendaItem item, int index, double scale) {
    final top = (399 + 84 * index) * scale;
    final end = item.agendamento.endDate;
    return Semantics(
      container: true,
      label: [
        item.agendamento.tipo,
        fmtHorario(item.agendamento.data, end),
        item.name,
        item.agendamento.local,
      ].join(', '),
      child: Stack(
        children: [
          Positioned(
            left: 40.5 * scale,
            top: top,
            width: 50 * scale,
            height: 50 * scale,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmtHora(item.agendamento.data),
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15 * scale,
                        fontFamily: VH.bodyFontFamily,
                      ),
                    ),
                    if (end != null)
                      Text(
                        fmtHora(end),
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15 * scale,
                          fontFamily: VH.bodyFontFamily,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 102 * scale,
            top: top,
            width: 195 * scale,
            height: 50 * scale,
            child: Container(
              decoration: insetBox(color: VH.secondary, radius: 15 * scale),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8 * scale),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.agendamento.tipo,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                    fontFamily: VH.bodyFontFamily,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

class _FigmaDottedLine extends StatelessWidget {
  const _FigmaDottedLine({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, 2),
    painter: const _FigmaDottedLinePainter(),
  );
}

class _FigmaDottedLinePainter extends CustomPainter {
  const _FigmaDottedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 1.0;
    const pitch = 5.0;
    final paint = Paint()..color = VH.foreground.withValues(alpha: .55);
    for (var x = radius; x <= size.width - radius; x += pitch) {
      canvas.drawCircle(Offset(x, size.height / 2), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FigmaDottedLinePainter oldDelegate) => false;
}
