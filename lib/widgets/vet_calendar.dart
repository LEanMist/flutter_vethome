import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

class VetCalendar extends StatelessWidget {
  const VetCalendar({
    super.key,
    required this.month,
    required this.selected,
    required this.onSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.firstDate,
    this.lastDate,
    this.hasIndicator,
    this.agendaPageStyle = false,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime date)? hasIndicator;
  final bool agendaPageStyle;

  static const monthNames = [
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

  static const weekdayNames = [
    'Domingo',
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];

  static List<DateTime> monthDays(DateTime month) {
    final first = DateTime(month.year, month.month);
    final offset = first.weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final weekCount = ((offset + daysInMonth + 6) ~/ 7).clamp(5, 6);
    return List.generate(
      weekCount * 7,
      (index) => DateTime(month.year, month.month, 1 - offset + index),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _enabled(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final minimum = firstDate;
    if (minimum != null) {
      final first = DateTime(minimum.year, minimum.month, minimum.day);
      if (day.isBefore(first)) return false;
    }
    final maximum = lastDate;
    if (maximum != null) {
      final last = DateTime(maximum.year, maximum.month, maximum.day);
      if (day.isAfter(last)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    if (agendaPageStyle) return _buildAgendaPageCalendar(context, today);
    return _buildAppointmentCalendar(context, today);
  }

  Widget _buildAppointmentCalendar(BuildContext context, DateTime today) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final scale = (math.min(390.0, availableWidth) / 390)
            .clamp(.55, 1.0)
            .toDouble();
        final dates = monthDays(month);
        final weekCount = dates.length ~/ 7;
        final cellDimension = 35 * scale;
        final columnGap = 10 * scale;
        final rowGap = 10 * scale;
        final gridHeight =
            (cellDimension * (weekCount + 1)) + rowGap * weekCount;
        final height =
            (22 + 35 + 18 + 35 * (weekCount + 1) + 10 * weekCount + 48) * scale;
        final monthLabel = monthNames[month.month - 1];
        final pointerDownPositions = <int, Offset>{};

        Widget calendarRow(List<Widget> children) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                SizedBox.square(
                  dimension: cellDimension,
                  child: children[index],
                ),
                if (index < children.length - 1) SizedBox(width: columnGap),
              ],
            ],
          );
        }

        return Semantics(
          key: const ValueKey('calendar-month-navigation'),
          container: true,
          explicitChildNodes: true,
          header: true,
          label: 'Calendário $monthLabel ${month.year}',
          hint:
              'Deslize para mudar o mês. Use Page Up para o mês anterior e Page Down para o próximo mês.',
          customSemanticsActions: {
            CustomSemanticsAction(label: 'Mês anterior'): onPreviousMonth,
            CustomSemanticsAction(label: 'Próximo mês'): onNextMonth,
          },
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              pointerDownPositions[event.pointer] = event.position;
            },
            onPointerUp: (event) {
              final start = pointerDownPositions.remove(event.pointer);
              if (start == null) return;
              final delta = event.position - start;
              if (delta.dx.abs() < 40 || delta.dx.abs() <= delta.dy.abs()) {
                return;
              }
              if (delta.dx < 0) {
                onNextMonth();
              } else {
                onPreviousMonth();
              }
            },
            onPointerCancel: (event) =>
                pointerDownPositions.remove(event.pointer),
            child: Container(
              key: const ValueKey('vet-calendar'),
              width: 390 * scale,
              height: height,
              decoration: BoxDecoration(
                color: VH.secondary,
                borderRadius: BorderRadius.circular(VH.radiusXLarge * scale),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 128 * scale,
                    top: 22 * scale,
                    width: 71 * scale,
                    height: 35 * scale,
                    child: SizedBox(
                      key: const ValueKey('calendar-month-label'),
                      child: Semantics(
                        label: 'Mês $monthLabel',
                        child: ExcludeSemantics(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                monthLabel,
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                  color: VH.foreground,
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: VH.headingFontFamily,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 226 * scale,
                    top: 22 * scale,
                    width: 35 * scale,
                    height: 35 * scale,
                    child: SizedBox(
                      key: const ValueKey('calendar-year-label'),
                      child: Semantics(
                        label: 'Ano ${month.year}',
                        child: ExcludeSemantics(
                          child: Center(
                            child: Text(
                              '${month.year}',
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                color: VH.foreground,
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.bold,
                                fontFamily: VH.headingFontFamily,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 42 * scale,
                    top: 75 * scale,
                    width: 305 * scale,
                    height: gridHeight,
                    child: SizedBox(
                      key: const ValueKey('calendar-month-grid'),
                      width: 305 * scale,
                      height: gridHeight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          calendarRow([
                            for (
                              var index = 0;
                              index < weekdayNames.length;
                              index++
                            )
                              Semantics(
                                container: true,
                                label: weekdayNames[index],
                                child: ExcludeSemantics(
                                  child: Center(
                                    child: Text(
                                      const [
                                        'Dom',
                                        'Seg',
                                        'Ter',
                                        'Qua',
                                        'Qui',
                                        'Sex',
                                        'Sáb',
                                      ][index],
                                      maxLines: 1,
                                      softWrap: false,
                                      style: TextStyle(
                                        color: VH.foreground,
                                        fontSize: 15 * scale,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: VH.headingFontFamily,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ]),
                          SizedBox(height: rowGap),
                          for (var row = 0; row < weekCount; row++) ...[
                            calendarRow([
                              for (var column = 0; column < 7; column++)
                                _CalendarDay(
                                  date: dates[row * 7 + column],
                                  selected: _sameDay(
                                    dates[row * 7 + column],
                                    selected,
                                  ),
                                  today: _sameDay(
                                    dates[row * 7 + column],
                                    today,
                                  ),
                                  inMonth:
                                      dates[row * 7 + column].month ==
                                      month.month,
                                  enabled: _enabled(dates[row * 7 + column]),
                                  indicator:
                                      hasIndicator?.call(
                                        dates[row * 7 + column],
                                      ) ??
                                      false,
                                  onTap: () =>
                                      onSelected(dates[row * 7 + column]),
                                  scale: scale,
                                  onPreviousMonth: onPreviousMonth,
                                  onNextMonth: onNextMonth,
                                ),
                            ]),
                            if (row < weekCount - 1) SizedBox(height: rowGap),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgendaPageCalendar(BuildContext context, DateTime today) {
    final scale = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.8, 1.0)
        .toDouble();
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compactText = textScale > 1;
    final dayFontScale = textScale >= 1.4 ? .9 : 1.0;
    final first = DateTime(month.year, month.month);
    final leadingDays = first.weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final weekCount = ((leadingDays + daysInMonth + 6) ~/ 7).clamp(5, 6);
    final slots = List<DateTime?>.generate(weekCount * 7, (index) {
      final day = index - leadingDays + 1;
      return day < 1 ? null : DateTime(month.year, month.month, day);
    });
    final weekLabels = const ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final compactWeekLabels = const ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    final cellDimension = 35 * scale;
    final columnGap = 13.142857 * scale;
    final rowGap = 5 * scale;

    return Semantics(
      key: const ValueKey('agenda-calendar-month-navigation'),
      container: true,
      explicitChildNodes: true,
      header: true,
      label: 'Calendário ${monthNames[month.month - 1]} ${month.year}',
      hint: 'Use Page Up para o mês anterior e Page Down para o próximo mês.',
      customSemanticsActions: {
        CustomSemanticsAction(label: 'Mês anterior'): onPreviousMonth,
        CustomSemanticsAction(label: 'Próximo mês'): onNextMonth,
      },
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -100) {
            onNextMonth();
          } else if (velocity > 100) {
            onPreviousMonth();
          }
        },
        child: Container(
          key: const ValueKey('vet-calendar'),
          width: 390 * scale,
          height: 344 * scale,
          clipBehavior: Clip.none,
          decoration: BoxDecoration(
            color: VH.secondary,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(VH.radiusXLarge * scale),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (compactText)
                Positioned(
                  left: 0,
                  top: 10 * scale,
                  width: 390 * scale,
                  height: 44 * scale,
                  child: Semantics(
                    label: 'Mês ${monthNames[month.month - 1]}, ${month.year}',
                    child: ExcludeSemantics(
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            text: monthNames[month.month - 1],
                            children: [TextSpan(text: ' ${month.year}')],
                          ),
                          key: const ValueKey('agenda-calendar-month-heading'),
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: VH.foreground,
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.bold,
                            fontFamily: VH.headingFontFamily,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else ...[
                Positioned(
                  left: 126 * scale,
                  top: 17 * scale,
                  width: 71 * scale,
                  height: 35 * scale,
                  child: Semantics(
                    label: 'Mês ${monthNames[month.month - 1]}',
                    child: Center(
                      child: Text(
                        monthNames[month.month - 1],
                        key: const ValueKey('agenda-calendar-month-heading'),
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: VH.foreground,
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.bold,
                          fontFamily: VH.headingFontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 207 * scale,
                  top: 17 * scale,
                  width: 35 * scale,
                  height: 35 * scale,
                  child: Semantics(
                    label: 'Ano ${month.year}',
                    child: Center(
                      child: Text(
                        '${month.year}',
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: VH.foreground,
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.bold,
                          fontFamily: VH.headingFontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              Positioned(
                left: 31 * scale,
                top: 65 * scale,
                width: 327 * scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _agendaCalendarRow(
                      gap: columnGap,
                      cellDimension: cellDimension,
                      children: [
                        for (var index = 0; index < weekLabels.length; index++)
                          Semantics(
                            container: true,
                            label: weekdayNames[index],
                            child: ExcludeSemantics(
                              child: Center(
                                child: Text(
                                  compactText
                                      ? compactWeekLabels[index]
                                      : weekLabels[index],
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: VH.foreground,
                                    fontSize: (compactText ? 14 : 15) * scale,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: VH.headingFontFamily,
                                    height: compactText ? 1 : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: rowGap),
                    for (var row = 0; row < weekCount; row++) ...[
                      _agendaCalendarRow(
                        gap: columnGap,
                        cellDimension: cellDimension,
                        children: [
                          for (var column = 0; column < 7; column++)
                            _agendaCalendarDate(
                              slots[row * 7 + column],
                              today: today,
                              scale: scale,
                              fontSizeFactor: dayFontScale,
                            ),
                        ],
                      ),
                      if (row < weekCount - 1) SizedBox(height: rowGap),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _agendaCalendarRow({
    required double gap,
    required double cellDimension,
    required List<Widget> children,
  }) => Row(
    children: [
      for (var index = 0; index < children.length; index++) ...[
        SizedBox.square(dimension: cellDimension, child: children[index]),
        if (index < children.length - 1) SizedBox(width: gap),
      ],
    ],
  );

  Widget _agendaCalendarDate(
    DateTime? date, {
    required DateTime today,
    required double scale,
    required double fontSizeFactor,
  }) {
    if (date == null) return const SizedBox.shrink();
    final inMonth = date.month == month.month;
    return _CalendarDay(
      date: date,
      selected: _sameDay(date, selected),
      today: false,
      inMonth: inMonth,
      enabled: _enabled(date),
      indicator: false,
      todayForSemantics: _sameDay(date, today),
      scale: scale,
      fontSizeFactor: fontSizeFactor,
      onPreviousMonth: onPreviousMonth,
      onNextMonth: onNextMonth,
      onTap: () => onSelected(date),
    );
  }
}

class _CalendarDay extends StatefulWidget {
  const _CalendarDay({
    required this.date,
    required this.selected,
    required this.today,
    required this.inMonth,
    required this.enabled,
    required this.indicator,
    required this.onTap,
    this.scale = 1,
    this.fontSizeFactor = 1,
    this.todayForSemantics = false,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  final DateTime date;
  final bool selected, today, inMonth, enabled, indicator;
  final double scale;
  final double fontSizeFactor;
  final bool todayForSemantics;
  final VoidCallback? onPreviousMonth, onNextMonth;
  final VoidCallback onTap;

  @override
  State<_CalendarDay> createState() => _CalendarDayState();
}

class _CalendarDayState extends State<_CalendarDay> {
  final WidgetStatesController _statesController = WidgetStatesController();

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  Color? _overlayColor(Set<WidgetState> states) {
    if (!widget.enabled || states.contains(WidgetState.disabled)) {
      return Colors.transparent;
    }
    final overlayBase = widget.selected ? Colors.white : VH.foreground;
    if (states.contains(WidgetState.pressed)) {
      return overlayBase.withValues(alpha: .20);
    }
    if (states.contains(WidgetState.focused)) {
      return overlayBase.withValues(alpha: .18);
    }
    if (states.contains(WidgetState.hovered)) {
      return overlayBase.withValues(alpha: .12);
    }
    return null;
  }

  Widget _monthKeyboardShortcuts(Widget child) {
    if (widget.onPreviousMonth == null && widget.onNextMonth == null) {
      return child;
    }
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.pageUp &&
            widget.onPreviousMonth != null) {
          widget.onPreviousMonth!();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.pageDown &&
            widget.onNextMonth != null) {
          widget.onNextMonth!();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = [
      '${VetCalendar.weekdayNames[widget.date.weekday % 7].toLowerCase()}, '
          '${widget.date.day} de '
          '${VetCalendar.monthNames[widget.date.month - 1].toLowerCase()} '
          'de ${widget.date.year}',
      if (widget.today || widget.todayForSemantics) 'hoje',
      if (widget.indicator) 'possui agendamento',
    ].join(', ');

    return Semantics(
      key: ValueKey(
        'calendar-date-semantics-${widget.date.year}-'
        '${widget.date.month}-${widget.date.day}',
      ),
      button: true,
      selected: widget.selected,
      enabled: widget.enabled,
      label: dateLabel,
      onTap: widget.enabled ? widget.onTap : null,
      excludeSemantics: true,
      child: Center(
        child: SizedBox.square(
          dimension: 35 * widget.scale,
          child: _monthKeyboardShortcuts(
            Material(
              key: ValueKey(
                'calendar-${widget.date.year}-${widget.date.month}-${widget.date.day}-surface',
              ),
              color: widget.selected
                  ? VH.primary
                  : widget.today
                  ? VH.secondary.withValues(alpha: .25)
                  : Colors.transparent,
              shape: CircleBorder(
                side: widget.today && !widget.selected
                    ? BorderSide(
                        color: VH.foreground.withValues(alpha: .5),
                        width: widget.scale,
                      )
                    : BorderSide.none,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: ValueKey(
                  'calendar-${widget.date.year}-${widget.date.month}-${widget.date.day}',
                ),
                statesController: _statesController,
                customBorder: const CircleBorder(),
                overlayColor: WidgetStateProperty.resolveWith(_overlayColor),
                canRequestFocus: widget.enabled,
                onTap: widget.enabled ? widget.onTap : null,
                child: CustomPaint(
                  foregroundPainter: widget.selected
                      ? _InsetCircleShadowPainter(scale: widget.scale)
                      : null,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${widget.date.day}',
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 15 * widget.scale * widget.fontSizeFactor,
                          fontWeight: FontWeight.bold,
                          fontFamily: VH.headingFontFamily,
                          height: widget.fontSizeFactor < 1 ? 1 : null,
                          color: widget.selected
                              ? VH.onSecondary
                              : VH.foreground.withValues(
                                  alpha: widget.enabled
                                      ? widget.inMonth
                                            ? 1
                                            : .30
                                      : .2,
                                ),
                        ),
                      ),
                      if (widget.indicator)
                        Positioned(
                          bottom: 2 * widget.scale,
                          child: CircleAvatar(
                            radius: 2 * widget.scale,
                            backgroundColor: widget.selected
                                ? VH.onSecondary
                                : VH.foreground,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InsetCircleShadowPainter extends CustomPainter {
  const _InsetCircleShadowPainter({this.scale = 1});
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final circle = Path()..addOval(bounds);
    final center = bounds.center + Offset(2 * scale, 2 * scale);
    final radius = size.shortestSide / 2;

    canvas
      ..save()
      ..clipPath(circle)
      ..drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.black.withValues(alpha: .25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * scale
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 * scale),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _InsetCircleShadowPainter oldDelegate) => false;
}
