import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/vet_colors.dart';

/// Cartão móvel do fluxo de agendamento, baseado no CALENDAR_WIDGET do Figma.
class AppointmentBookingCard extends StatelessWidget {
  const AppointmentBookingCard({
    super.key,
    required this.service,
    required this.plan,
    required this.date,
    required this.start,
    required this.end,
    required this.descriptionController,
    required this.onChooseDate,
    required this.onChooseStart,
    required this.onChooseEnd,
    required this.onSave,
    this.saving = false,
  });

  static const double designWidth = 390;
  static const double designHeight = 453;
  static const double minimumTouchTarget = 48;

  static const _calendarIcon = 'assets/imagens/figma/appointment-calendar.svg';
  static const _clockIcon = 'assets/imagens/figma/appointment-clock.svg';
  static const _descriptionIcon =
      'assets/imagens/figma/appointment-text-long.svg';
  static const _timeDivider =
      'assets/imagens/figma/appointment-time-divider.svg';

  final String service;
  final String plan;
  final DateTime date;
  final TimeOfDay? start;
  final TimeOfDay? end;
  final TextEditingController descriptionController;
  final VoidCallback onChooseDate;
  final VoidCallback onChooseStart;
  final VoidCallback onChooseEnd;
  final VoidCallback onSave;
  final bool saving;

  static const _chipColor = Color.fromRGBO(192, 128, 129, 0.5);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final availableWidth = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final cardWidth = math.min(availableWidth, designWidth);
      final scale = cardWidth / designWidth;

      return Center(
        child: SizedBox(
          key: const ValueKey('appointment-booking-scaled-size'),
          width: cardWidth,
          height: designHeight * scale,
          child: FittedBox(
            alignment: Alignment.topLeft,
            fit: BoxFit.fill,
            child: SizedBox(
              width: designWidth,
              height: designHeight,
              child: _buildDesignCard(context, scale),
            ),
          ),
        ),
      );
    },
  );

  Widget _buildDesignCard(BuildContext context, double scale) {
    final textScale = 1 / scale;
    final timeTargetHeight = minimumTouchTarget / scale;
    final narrowLayoutOffset = math.max(0.0, timeTargetHeight - 56.0);
    final saveHeight = math.max(51.0, timeTargetHeight);
    final saveTop = 376 - (saveHeight - 51) / 2;

    return Container(
      key: const ValueKey('appointment-booking-card'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: VetColors.pink,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          _icon(_calendarIcon, left: 33, top: 38),
          _staticPill(
            key: const ValueKey('appointment-booking-service'),
            left: 81,
            top: 35,
            label: service,
            semanticLabel: 'Serviço: $service',
            color: _chipColor,
            textScale: textScale,
          ),
          _icon(_calendarIcon, left: 33, top: 85),
          _staticPill(
            key: const ValueKey('appointment-booking-plan'),
            left: 81,
            top: 83,
            label: plan,
            semanticLabel: 'Convênio: $plan',
            color: _chipColor,
            textScale: textScale,
          ),
          _icon(_calendarIcon, left: 33, top: 132),
          _actionPill(
            key: const ValueKey('appointment-booking-date'),
            left: 81,
            top: 131,
            label: _dateLabel(date),
            semanticLabel: 'Data: ${_dateLabel(date)}. Alterar data.',
            color: VetColors.rose,
            textScale: textScale,
            tapTargetHeight: timeTargetHeight,
            onTap: onChooseDate,
          ),
          _icon(_clockIcon, left: 33, top: 187),
          Positioned(
            left: 81,
            top: 187 + narrowLayoutOffset - (timeTargetHeight - 35) / 2,
            width: 222,
            height: timeTargetHeight,
            child: Row(
              children: [
                _timePill(
                  key: const ValueKey('appointment-booking-start-time'),
                  label: _timeLabel(start),
                  semanticLabel: 'Horário de início: ${_timeLabel(start)}',
                  color: VetColors.rose,
                  textScale: textScale,
                  tapTargetHeight: timeTargetHeight,
                  onTap: onChooseStart,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 2,
                  child: ExcludeSemantics(
                    child: SvgPicture.asset(_timeDivider),
                  ),
                ),
                const SizedBox(width: 8),
                _timePill(
                  key: const ValueKey('appointment-booking-end-time'),
                  label: _timeLabel(end),
                  semanticLabel: 'Horário de término: ${_timeLabel(end)}',
                  color: _chipColor,
                  textScale: textScale,
                  tapTargetHeight: timeTargetHeight,
                  onTap: onChooseEnd,
                ),
              ],
            ),
          ),
          _icon(_descriptionIcon, left: 33, top: 252 + narrowLayoutOffset),
          Positioned(
            left: 85,
            top: 231 + narrowLayoutOffset,
            width: 270,
            height: 20,
            child: ExcludeSemantics(
              child: Text(
                'Adicionar uma descrição',
                style: TextStyle(
                  color: VetColors.brown,
                  fontFamily: 'MontserratAlternates',
                  fontSize: 12 * textScale,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ),
          Positioned(
            left: 80,
            top: 252 + narrowLayoutOffset,
            width: 285,
            height: 103,
            child: Semantics(
              label: 'Descrição opcional do agendamento',
              textField: true,
              child: Container(
                key: const ValueKey('appointment-booking-description-surface'),
                decoration: inset_shadow.BoxDecoration(
                  color: VetColors.rose,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    inset_shadow.BoxShadow(
                      color: Color(0x40000000),
                      offset: Offset(2, 2),
                      blurRadius: 5,
                      inset: true,
                    ),
                  ],
                ),
                child: TextField(
                  key: const ValueKey('appointment-booking-description'),
                  controller: descriptionController,
                  minLines: 3,
                  maxLines: 4,
                  maxLength: 500,
                  style: TextStyle(
                    color: VetColors.calendarTextOnRose,
                    fontFamily: 'MontserratAlternates',
                    fontSize: 12 * textScale,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    filled: false,
                    hintText: '. . .',
                    hintStyle: TextStyle(
                      color: VetColors.calendarTextOnRose,
                      fontFamily: 'MontserratAlternates',
                      fontSize: 12 * textScale,
                      fontWeight: FontWeight.w500,
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.fromLTRB(12, 7, 12, 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: VetColors.brown,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 137,
            top: saveTop,
            width: 117,
            height: saveHeight,
            child: ElevatedButton(
              key: const ValueKey('appointment-booking-save'),
              onPressed: saving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: VetColors.pink,
                foregroundColor: VetColors.brown,
                elevation: 2,
                shadowColor: const Color(0x40000000),
                padding: EdgeInsets.zero,
                minimumSize: Size(117, saveHeight),
                maximumSize: Size(117, saveHeight),
                shape: const StadiumBorder(),
              ),
              child: Text(
                saving ? 'Salvando…' : 'Salvar',
                style: TextStyle(
                  fontFamily: 'MontserratAlternates',
                  fontSize: 18 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(String asset, {required double left, required double top}) =>
      Positioned(
        left: left,
        top: top,
        width: 28,
        height: 28,
        child: ExcludeSemantics(
          child: SvgPicture.asset(asset, fit: BoxFit.fill),
        ),
      );

  Widget _staticPill({
    required Key key,
    required double left,
    required double top,
    required String label,
    required String semanticLabel,
    required Color color,
    required double textScale,
  }) => Positioned(
    left: left,
    top: top,
    width: 222,
    height: 35,
    child: Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Container(
          key: key,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: VetColors.brown,
              fontFamily: 'MontserratAlternates',
              fontSize: 12 * textScale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _actionPill({
    required Key key,
    required double left,
    required double top,
    required String label,
    required String semanticLabel,
    required Color color,
    required double textScale,
    required double tapTargetHeight,
    required VoidCallback onTap,
  }) {
    const visualHeight = 35.0;
    final verticalInset = (tapTargetHeight - visualHeight) / 2;

    return Positioned(
      left: left,
      top: top - verticalInset,
      width: 222,
      height: tapTargetHeight,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            key: key,
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: SizedBox(
              height: tapTargetHeight,
              child: Center(
                child: SizedBox(
                  width: 222,
                  height: visualHeight,
                  child: Ink(
                    decoration: inset_shadow.BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        inset_shadow.BoxShadow(
                          color: Color(0x40000000),
                          offset: Offset(2, 2),
                          blurRadius: 5,
                          inset: true,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ExcludeSemantics(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: VetColors.calendarTextOnRose,
                              fontFamily: 'MontserratAlternates',
                              fontSize: 12 * textScale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _timePill({
    required Key key,
    required String label,
    required String semanticLabel,
    required Color color,
    required double textScale,
    required double tapTargetHeight,
    required VoidCallback onTap,
  }) => Expanded(
    child: Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: key,
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: SizedBox(
            height: tapTargetHeight,
            child: Center(
              child: Container(
                height: 35,
                alignment: Alignment.center,
                decoration: inset_shadow.BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: color == VetColors.rose
                      ? const [
                          inset_shadow.BoxShadow(
                            color: Color(0x40000000),
                            offset: Offset(2, 2),
                            blurRadius: 5,
                            inset: true,
                          ),
                        ]
                      : null,
                ),
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: VetColors.calendarTextOnRose,
                      fontFamily: 'MontserratAlternates',
                      fontSize: 12 * textScale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  static String _timeLabel(TimeOfDay? time) => time == null
      ? '--:--'
      : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  static String _dateLabel(DateTime date) {
    const weekdays = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    final weekday = weekdays[date.weekday - 1];
    final capitalizedWeekday =
        '${weekday[0].toUpperCase()}${weekday.substring(1)}';
    return '$capitalizedWeekday, ${date.day} de ${months[date.month - 1]}';
  }
}
