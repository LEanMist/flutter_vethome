import 'package:flutter/material.dart';

import '../../theme/vet_colors.dart';

/// Calendário integrado à agenda; selecionar um dia atualiza a própria página.
class GabrielaCalendarPicker extends StatefulWidget {
  const GabrielaCalendarPicker({
    super.key,
    required this.selectedDate,
    required this.onChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  State<GabrielaCalendarPicker> createState() => _GabrielaCalendarPickerState();
}

class _GabrielaCalendarPickerState extends State<GabrielaCalendarPicker> {
  static const _weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'];
  static const _months = [
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
  late DateTime _visibleMonth = DateTime(
    widget.selectedDate.year,
    widget.selectedDate.month,
  );

  void _moveMonth(int offset) => setState(() {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + offset);
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final s = (constraints.maxWidth / 342).clamp(.7, 1.0);
      final firstWeekday = _visibleMonth.weekday % 7;
      final days = DateUtils.getDaysInMonth(
        _visibleMonth.year,
        _visibleMonth.month,
      );
      final rows = ((firstWeekday + days) / 7).ceil();
      return Container(
        padding: EdgeInsets.all(10 * s),
        decoration: BoxDecoration(
          color: VetColors.pink.withValues(alpha: .65),
          borderRadius: BorderRadius.circular(28 * s),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Mês anterior',
                  onPressed: () => _moveMonth(-1),
                  icon: Icon(Icons.chevron_left, size: 20 * s),
                  color: VetColors.brown,
                ),
                Text(
                  '${_months[_visibleMonth.month - 1]}  ${_visibleMonth.year}',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 15 * s,
                    color: VetColors.brown,
                  ),
                ),
                IconButton(
                  tooltip: 'Próximo mês',
                  onPressed: () => _moveMonth(1),
                  icon: Icon(Icons.chevron_right, size: 20 * s),
                  color: VetColors.brown,
                ),
              ],
            ),
            Row(
              children: [
                for (final day in _weekdays)
                  Expanded(
                    child: SizedBox(
                      height: 35 * s,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 13 * s,
                            color: VetColors.brown,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: rows * 7,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4 * s,
                crossAxisSpacing: 4 * s,
              ),
              itemBuilder: (context, index) {
                final date = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month,
                  index - firstWeekday + 1,
                );
                final inMonth = date.month == _visibleMonth.month;
                final selected = DateUtils.isSameDay(date, widget.selectedDate);
                return Semantics(
                  button: true,
                  selected: selected,
                  label: '${date.day} de ${_months[date.month - 1]}',
                  child: Material(
                    color: selected
                        ? VetColors.roseOverlay50
                        : Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        if (!inMonth) {
                          setState(
                            () =>
                                _visibleMonth = DateTime(date.year, date.month),
                          );
                        }
                        widget.onChanged(date);
                      },
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 14 * s,
                            color: VetColors.brown.withValues(
                              alpha: inMonth ? 1 : .3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
