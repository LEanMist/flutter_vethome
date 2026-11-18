import 'package:flutter/material.dart';

import '../../theme/vet_colors.dart';
import '../../widgets/pets/pets_theme.dart';

class GabrielaCalendarPicker extends StatefulWidget {
  const GabrielaCalendarPicker({super.key, required this.initialDate});

  final DateTime initialDate;

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
    widget.initialDate.year,
    widget.initialDate.month,
  );

  String get _monthTitle =>
      '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}';

  @override
  Widget build(BuildContext context) {
    final s = PetsTheme.scaleOf(context);
    final width = 305 * s;
    final cell = 35 * s;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 20 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42 * s,
              height: 4 * s,
              decoration: BoxDecoration(
                color: VetColors.rose,
                borderRadius: BorderRadius.circular(4 * s),
              ),
            ),
            SizedBox(height: 12 * s),
            SizedBox(
              width: width,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Mês anterior',
                    onPressed: () => setState(
                      () => _visibleMonth = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month - 1,
                      ),
                    ),
                    icon: const Icon(Icons.chevron_left),
                    color: VetColors.brown,
                  ),
                  Expanded(
                    child: Text(
                      _monthTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: VetColors.brown,
                        fontSize: 17 * s,
                        fontFamily: PetsTheme.fontComfortaa,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Próximo mês',
                    onPressed: () => setState(
                      () => _visibleMonth = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month + 1,
                      ),
                    ),
                    icon: const Icon(Icons.chevron_right),
                    color: VetColors.brown,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * s),
            SizedBox(
              width: width,
              child: Row(
                children: [
                  for (var i = 0; i < _weekdays.length; i++) ...[
                    if (i > 0) SizedBox(width: 10 * s),
                    SizedBox(
                      width: cell,
                      height: cell,
                      child: Center(
                        child: Text(
                          _weekdays[i],
                          style: TextStyle(
                            color: VetColors.brown,
                            fontSize: 13 * s,
                            fontFamily: PetsTheme.fontComfortaa,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 10 * s),
            SizedBox(
              width: width,
              height: 260 * s,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 42,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 10 * s,
                  crossAxisSpacing: 10 * s,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final firstWeekday =
                      DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month,
                        1,
                      ).weekday %
                      7;
                  final day = index - firstWeekday + 1;
                  final daysInMonth = DateUtils.getDaysInMonth(
                    _visibleMonth.year,
                    _visibleMonth.month,
                  );
                  if (day < 1 || day > daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final date = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month,
                    day,
                  );
                  final selected = DateUtils.isSameDay(
                    date,
                    widget.initialDate,
                  );
                  return Semantics(
                    button: true,
                    selected: selected,
                    label: '$day de ${_months[_visibleMonth.month - 1]}',
                    child: Material(
                      color: selected
                          ? VetColors.rose.withValues(alpha: .42)
                          : Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.pop(context, date),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: VetColors.brown,
                              fontSize: 15 * s,
                              fontFamily: PetsTheme.fontComfortaa,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
