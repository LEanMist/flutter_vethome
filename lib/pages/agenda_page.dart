import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/utils/formatters.dart';
import '../data/vet_repository.dart';
import '../screens/pets.dart' show openPetChoiceDialog;
import '../models/vet_models.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets.dart';
import '../widgets/appointment_detail_dialog.dart';
import '../widgets/vet_calendar.dart';

List<DateTime> calendarMonthDays(DateTime month) =>
    VetCalendar.monthDays(month);

const _agendaChevronUp = 'assets/imagens/figma/agenda-chevron-up.svg';
const _agendaChevronDown = 'assets/imagens/figma/agenda-chevron-down.svg';

typedef _AgendaItem = ({
  String petId,
  String name,
  Agendamento agendamento,
  bool demo,
});

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
              petId: pet.id,
              name: pet.name,
              agendamento: appointment,
              demo: !VetRepository.realAppointments(
                pet.id,
              ).contains(appointment),
            ),
      if (_isDemoDate(_selecionado))
        for (final example in const [
          (hour: 10, type: 'Hemograma', name: 'Rambo Augusto'),
          (hour: 13, type: 'Urina', name: 'Nicolly Santos'),
          (hour: 16, type: 'Creatinina', name: 'Olivia Palito'),
        ])
          (
            petId: '',
            name: example.name,
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

    final viewport = MediaQuery.sizeOf(context);
    final isMobile = viewport.width < VH.desktopBreakpoint;
    final mobileScale = (viewport.width / 390).clamp(0.8, 1.0).toDouble();
    final pinMobileAction = isMobile;
    final page = VHPage(
      tab: '/agenda',
      showPetsTab: true,
      footer: pinMobileAction
          ? SizedBox(
              height: 70 * mobileScale,
              child: Container(
                key: const ValueKey('agenda-sticky-action-footer'),
                color: VH.background,
                alignment: Alignment.topCenter,
                child: _mobileNewAppointmentAction(mobileScale),
              ),
            )
          : null,
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
    final textScaler = MediaQuery.textScalerOf(context);
    const selectedDateTop = 323.0;
    final weekdays = const [
      'Domingo',
      'Segunda Feira',
      'Terça Feira',
      'Quarta Feira',
      'Quinta Feira',
      'Sexta Feira',
      'Sábado',
    ];
    final selectedDateLabel =
        '${_selecionado.day} - ${weekdays[_selecionado.weekday % 7]}';
    final selectedDateTextStyle = TextStyle(
      fontFamily: VH.headingFontFamily,
      fontSize: 22 * scale,
      fontWeight: FontWeight.bold,
      color: VH.foreground,
    );
    final selectedDateTextPainter = TextPainter(
      text: TextSpan(text: selectedDateLabel, style: selectedDateTextStyle),
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
      textScaler: textScaler,
    )..layout(maxWidth: 248 * scale);
    final dateTextIsEnlarged = textScaler.scale(22 * scale) > 22 * scale;
    final selectedDateHeight = dateTextIsEnlarged
        ? math.max(41 * scale, selectedDateTextPainter.height + 12 * scale)
        : 41 * scale;
    selectedDateTextPainter.dispose();
    final selectedDateBottom = selectedDateTop * scale + selectedDateHeight;
    final contentOffset = math.max(
      0.0,
      selectedDateBottom + 35 * scale - 399 * scale,
    );
    final emptyMessageTop = math.max(
      399 * scale,
      selectedDateBottom + 10 * scale,
    );
    var precedingCardExpansion = 0.0;
    if (appointments.length > 1) {
      for (final appointment in appointments.take(appointments.length - 1)) {
        precedingCardExpansion +=
            _mobileAppointmentHeight(appointment, scale) - 50 * scale;
      }
    }
    final lastCardBottom = appointments.isEmpty
        ? 0.0
        : (399 + 84 * (appointments.length - 1)) * scale +
              precedingCardExpansion +
              _mobileAppointmentHeight(appointments.last, scale);
    final contentHeight = math.max(
      414 * scale,
      appointments.isEmpty
          ? emptyMessageTop + 36 * scale
          : lastCardBottom + contentOffset,
    );
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
              hasIndicator: (date) =>
                  _isDemoDate(date) || _hasAppointment(date),
            ),
          ),
          Positioned(
            left: 67 * scale,
            top: selectedDateTop * scale,
            width: 258 * scale,
            height: selectedDateHeight,
            child: Container(
              key: const ValueKey('agenda-selected-date'),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: VetColors.pinkOverlay50,
                border: Border.all(color: VetColors.rose, width: 5 * scale),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(200 * scale),
                  bottom: Radius.circular(100 * scale),
                ),
              ),
              child: Text(
                selectedDateLabel,
                key: const ValueKey('agenda-selected-date-label'),
                textAlign: TextAlign.center,
                style: selectedDateTextStyle,
              ),
            ),
          ),
          if (appointments.isEmpty)
            Positioned(
              left: 35 * scale,
              right: 35 * scale,
              top: emptyMessageTop,
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
          ..._mobileAppointmentWidgets(
            appointments,
            scale,
            topOffset: contentOffset,
          ),
          Positioned(
            left: 345 * scale,
            top: 435 * scale + contentOffset,
            width: 20 * scale,
            height: 20 * scale,
            child: SizedBox.expand(
              key: const ValueKey('agenda-chevron-up'),
              child: ExcludeSemantics(
                child: Center(
                  child: Transform.rotate(
                    angle: -math.pi / 2,
                    child: SvgPicture.asset(
                      _agendaChevronUp,
                      width: 11 * scale,
                      height: 19.6299 * scale,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 345 * scale,
            top: 560 * scale + contentOffset,
            width: 20 * scale,
            height: 20 * scale,
            child: SizedBox.expand(
              key: const ValueKey('agenda-chevron-down'),
              child: ExcludeSemantics(
                child: Center(
                  child: Transform.rotate(
                    angle: math.pi / 2,
                    child: SvgPicture.asset(
                      _agendaChevronDown,
                      width: 11 * scale,
                      height: 19.6299 * scale,
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

  Widget _mobileNewAppointmentAction(double scale) {
    final visualHeight = 41 * scale;
    final touchHeight = math.max(48.0, visualHeight);
    return SizedBox(
      width: 99 * scale,
      height: touchHeight,
      child: Semantics(
        key: const ValueKey('agenda-new-appointment-target'),
        button: true,
        label: 'Nova Consulta',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100 * scale),
            onTap: () => openPetChoiceDialog(context),
            child: Center(
              child: Container(
                width: 99 * scale,
                height: visualHeight,
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
    );
  }

  List<Widget> _mobileAppointmentWidgets(
    List<_AgendaItem> appointments,
    double scale, {
    required double topOffset,
  }) {
    final children = <Widget>[];
    var accumulatedExpansion = 0.0;

    for (var index = 0; index < appointments.length; index++) {
      final item = appointments[index];
      final top = (399 + 84 * index) * scale + topOffset + accumulatedExpansion;
      final cardHeight = _mobileAppointmentHeight(item, scale);
      final expansion = cardHeight - 50 * scale;
      children.add(
        _mobileAppointment(
          item,
          index,
          scale,
          top: top,
          cardHeight: cardHeight,
        ),
      );
      if (index < appointments.length - 1) {
        children.add(
          Positioned(
            left: 88 * scale,
            top:
                (465 + 84 * index + (index > 0 ? 1 : 0)) * scale +
                topOffset +
                accumulatedExpansion +
                expansion,
            child: _FigmaDottedLine(
              key: ValueKey('agenda-divider-$index'),
              width: 221 * scale,
            ),
          ),
        );
      }
      accumulatedExpansion += expansion;
    }

    return children;
  }

  double _mobileAppointmentHeight(_AgendaItem item, double scale) {
    final standardHeight = 50 * scale;
    final textScaler = MediaQuery.textScalerOf(context);
    if (item.demo) {
      final contentHeight =
          (textScaler.scale(9 * scale) + textScaler.scale(15 * scale)) * 1.5;
      return math.max(standardHeight, contentHeight).toDouble();
    }

    final fontSize = 15 * scale;
    if (textScaler.scale(fontSize) <= fontSize) return standardHeight;

    final titlePainter = TextPainter(
      text: TextSpan(
        text: item.name,
        style: TextStyle(
          color: VetColors.calendarTextOnRose,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          fontFamily: VH.bodyFontFamily,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
      textScaler: textScaler,
    )..layout(maxWidth: 179 * scale);
    final titleHeight = titlePainter.height;
    titlePainter.dispose();
    return math.max(standardHeight, titleHeight).toDouble();
  }

  Widget _mobileAppointment(
    _AgendaItem item,
    int index,
    double scale, {
    required double top,
    required double cardHeight,
  }) {
    final end = item.agendamento.endDate;
    final label = [
      if (item.demo) 'Demonstração',
      item.agendamento.tipo,
      fmtHorario(item.agendamento.data, end),
      item.name,
      item.agendamento.local,
    ].join(', ');
    return Stack(
      children: [
        Positioned(
          left: 46 * scale,
          top: top,
          width: 39 * scale,
          height: cardHeight,
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
          height: cardHeight,
          child: Semantics(
            container: true,
            excludeSemantics: true,
            button: !item.demo,
            label: label,
            onTap: item.demo ? null : () => _showAppointmentDetails(item),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15 * scale),
              child: InkWell(
                key: ValueKey(
                  'agenda-appointment-${item.agendamento.data.microsecondsSinceEpoch}-${item.agendamento.tipo}',
                ),
                borderRadius: BorderRadius.circular(15 * scale),
                onTap: item.demo ? null : () => _showAppointmentDetails(item),
                child: Container(
                  decoration: insetBox(color: VH.secondary, radius: 15 * scale),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                  child: item.demo
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Demonstração',
                              key: ValueKey('agenda-demo-badge-$index'),
                              maxLines: 1,
                              style: TextStyle(
                                color: VetColors.calendarTextOnRose,
                                fontSize: 9 * scale,
                                fontWeight: FontWeight.bold,
                                fontFamily: VH.bodyFontFamily,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.agendamento.tipo,
                                maxLines: 1,
                                style: TextStyle(
                                  color: VetColors.calendarTextOnRose,
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: VH.bodyFontFamily,
                                ),
                              ),
                            ),
                          ],
                        )
                      : MediaQuery.textScalerOf(context).scale(15 * scale) >
                            15 * scale
                      ? Text(
                          item.name,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                            color: VetColors.calendarTextOnRose,
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w600,
                            fontFamily: VH.bodyFontFamily,
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.name,
                            maxLines: 1,
                            style: TextStyle(
                              color: VetColors.calendarTextOnRose,
                              fontSize: 15 * scale,
                              fontWeight: FontWeight.w600,
                              fontFamily: VH.bodyFontFamily,
                            ),
                          ),
                        ),
                ),
              ),
            ),
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
        onPressed: () => openPetChoiceDialog(context),
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
              child: Semantics(
                excludeSemantics: true,
                button: !item.demo,
                label: [
                  if (item.demo) 'Demonstração',
                  item.agendamento.tipo,
                  fmtData(item.agendamento.data),
                  fmtHorario(item.agendamento.data, item.agendamento.endDate),
                  item.name,
                  item.agendamento.local,
                ].join(', '),
                onTap: item.demo ? null : () => _showAppointmentDetails(item),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: item.demo
                        ? null
                        : () => _showAppointmentDetails(item),
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
                                    color: VetColors.calendarTextOnRose,
                                  ),
                                ),
                                Text(
                                  fmtHorario(
                                    item.agendamento.data,
                                    item.agendamento.endDate,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: VetColors.calendarTextOnRose,
                                  ),
                                ),
                                Text(
                                  '${item.demo ? 'Demonstração · ' : ''}${item.name} · ${item.agendamento.local}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: VetColors.calendarTextOnRose,
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
              ),
            ),
          const SizedBox(height: 4),
          button,
        ],
      ],
    );
  }

  Future<void> _showAppointmentDetails(_AgendaItem item) async {
    if (item.demo) return;
    final pet = VetRepository.petById(item.petId);
    if (pet == null) return;

    final deleteRequested = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppointmentDetailDialog(
        pet: pet,
        appointment: item.agendamento,
        onDelete: () => Navigator.pop(dialogContext, true),
      ),
    );
    if (!mounted || deleteRequested != true) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir consulta?'),
        content: Text(
          'Remover ${item.agendamento.tipo} de ${item.name} em '
          '${fmtData(item.agendamento.data)} deste dispositivo?',
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
        item.petId,
        item.agendamento,
      );
      if (!removed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esta consulta já não está salva.')),
        );
        return;
      }
      setState(() {});
      final saved = await VetRepository.flush();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? 'Consulta removida.'
                : 'Consulta removida nesta sessão. Não foi possível salvar localmente.',
          ),
        ),
      );
    } on PersistenceBlockedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Armazenamento local bloqueado. A consulta não foi removida.',
          ),
        ),
      );
    }
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
