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
        borderRadius: BorderRadius.circular(VH.radiusCard),
        boxShadow: VH.cardShadow,
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
            mainAxisExtent: 37,
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

class _CalendarDay extends StatelessWidget {
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
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    enabled: enabled,
    label: '${date.day}/${date.month}/${date.year}',
    child: InkWell(
      key: ValueKey('calendar-${date.year}-${date.month}-${date.day}'),
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? onTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: selected
                  ? VH.background
                  : today
                  ? VH.background.withValues(alpha: .35)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: today && !selected
                  ? Border.all(color: VH.foreground.withValues(alpha: .5))
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 11,
                color: VH.foreground.withValues(
                  alpha: enabled
                      ? inMonth
                            ? 1
                            : .35
                      : .2,
                ),
              ),
            ),
          ),
          if (indicator)
            const Positioned(
              bottom: 2,
              child: CircleAvatar(radius: 2, backgroundColor: VH.onSecondary),
            ),
        ],
      ),
    ),
  );
}
