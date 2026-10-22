import 'package:flutter/material.dart';

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
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime date)? hasIndicator;

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

  static List<DateTime> monthDays(DateTime month) {
    final first = DateTime(month.year, month.month);
    final offset = first.weekday % 7;
    return List.generate(
      42,
      (index) => DateTime(month.year, month.month, 1 - offset + index),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _enabled(DateTime date) {
    final minimum = firstDate;
    if (minimum == null) return true;
    final day = DateTime(date.year, date.month, date.day);
    final first = DateTime(minimum.year, minimum.month, minimum.day);
    final maximum = lastDate;
    if (day.isBefore(first)) return false;
    if (maximum == null) return true;
    final last = DateTime(maximum.year, maximum.month, maximum.day);
    return !day.isAfter(last);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Container(
      key: const ValueKey('vet-calendar'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VH.secondary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(VH.radiusXLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Mês anterior',
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${monthNames[month.month - 1]} ${month.year}',
                    style: const TextStyle(
                      color: VH.foreground,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: VH.headingFontFamily,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Próximo mês',
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          GridView.count(
            crossAxisCount: 7,
            mainAxisExtent: 41,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final weekday in const [
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: VH.headingFontFamily,
                    ),
                  ),
                ),
              for (final date in monthDays(month))
                _CalendarDay(
                  date: date,
                  selected: _sameDay(date, selected),
                  today: _sameDay(date, today),
                  inMonth: date.month == month.month,
                  enabled: _enabled(date),
                  indicator: hasIndicator?.call(date) ?? false,
                  onTap: () => onSelected(date),
                ),
            ],
          ),
        ],
      ),
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
  });

  final DateTime date;
  final bool selected, today, inMonth, enabled, indicator;
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

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: widget.selected,
    enabled: widget.enabled,
    label: '${widget.date.day}/${widget.date.month}/${widget.date.year}',
    child: Center(
      child: SizedBox.square(
        dimension: 35,
        child: Material(
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
                ? BorderSide(color: VH.foreground.withValues(alpha: .5))
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
                  ? const _InsetCircleShadowPainter()
                  : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${widget.date.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: VH.headingFontFamily,
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
                      bottom: 2,
                      child: CircleAvatar(
                        radius: 2,
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
  );
}

class _InsetCircleShadowPainter extends CustomPainter {
  const _InsetCircleShadowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final circle = Path()..addOval(bounds);
    final center = bounds.center + const Offset(2, 2);
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
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _InsetCircleShadowPainter oldDelegate) => false;
}
