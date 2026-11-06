import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/pet_model.dart';
import '../theme/vet_colors.dart';
import 'pets/pet_avatar.dart';

/// Cartão móvel do fluxo de agendamento, baseado no CALENDAR_WIDGET do Figma.
class AppointmentBookingCard extends StatelessWidget {
  const AppointmentBookingCard({
    super.key,
    required this.service,
    required this.plan,
    required this.pet,
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
  static const double designHeight = 461;

  final String service;
  final String plan;
  final PetModel pet;
  final DateTime date;
  final TimeOfDay? start;
  final TimeOfDay? end;
  final TextEditingController descriptionController;
  final VoidCallback onChooseDate;
  final VoidCallback onChooseStart;
  final VoidCallback onChooseEnd;
  final VoidCallback onSave;
  final bool saving;

  static const _chipColor = Color(0xFFDDA7A8);

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
              child: _buildDesignCard(context),
            ),
          ),
        ),
      );
    },
  );

  Widget _buildDesignCard(BuildContext context) => Container(
    key: const ValueKey('appointment-booking-card'),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: VetColors.pink,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Stack(
      children: [
        _icon(Icons.calendar_today_outlined, left: 32, top: 38),
        _staticPill(
          key: const ValueKey('appointment-booking-service'),
          left: 81,
          top: 35,
          label: service,
          semanticLabel: 'Serviço: $service',
          color: _chipColor,
        ),
        _icon(Icons.calendar_today_outlined, left: 32, top: 86),
        _staticPill(
          key: const ValueKey('appointment-booking-plan'),
          left: 81,
          top: 83,
          label: plan,
          semanticLabel: 'Convênio: $plan',
          color: _chipColor,
        ),
        _icon(Icons.calendar_today_outlined, left: 32, top: 134),
        _actionPill(
          key: const ValueKey('appointment-booking-date'),
          left: 81,
          top: 131,
          label: _dateLabel(date),
          semanticLabel: 'Data: ${_dateLabel(date)}. Alterar data.',
          color: VetColors.rose,
          onTap: onChooseDate,
        ),
        _icon(Icons.access_time_filled, left: 32, top: 190),
        Positioned(
          left: 81,
          top: 185,
          width: 222,
          height: 42,
          child: Row(
            children: [
              _timePill(
                key: const ValueKey('appointment-booking-start-time'),
                label: _timeLabel(start),
                semanticLabel: 'Horário de início: ${_timeLabel(start)}',
                color: VetColors.rose,
                onTap: onChooseStart,
              ),
              const SizedBox(width: 8),
              const SizedBox(
                width: 12,
                child: ExcludeSemantics(
                  child: Text(
                    '–',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: VetColors.brown,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _timePill(
                key: const ValueKey('appointment-booking-end-time'),
                label: _timeLabel(end),
                semanticLabel: 'Horário de término: ${_timeLabel(end)}',
                color: _chipColor,
                onTap: onChooseEnd,
              ),
            ],
          ),
        ),
        _icon(Icons.notes, left: 34, top: 258),
        const Positioned(
          left: 85,
          top: 231,
          width: 270,
          height: 20,
          child: ExcludeSemantics(
            child: Text(
              'Adicionar uma descrição',
              style: TextStyle(
                color: VetColors.brown,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ),
        ),
        Positioned(
          left: 80,
          top: 252,
          width: 285,
          height: 103,
          child: Semantics(
            label: 'Descrição opcional do agendamento',
            textField: true,
            child: TextField(
              key: const ValueKey('appointment-booking-description'),
              controller: descriptionController,
              minLines: 3,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(
                color: VetColors.calendarTextOnRose,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: VetColors.rose,
                hintText: '...',
                hintStyle: const TextStyle(color: VetColors.calendarTextOnRose),
                counterText: '',
                contentPadding: const EdgeInsets.fromLTRB(12, 7, 12, 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: VetColors.brown,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 365,
          width: 36,
          height: 36,
          child: Semantics(
            image: true,
            label: 'Foto de ${pet.name}',
            child: PetAvatar(
              image: pet.imagePath,
              photoBase64: pet.photoBase64,
              species: pet.species,
              size: 36,
            ),
          ),
        ),
        Positioned(
          left: 80,
          top: 373,
          width: 170,
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              pet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: VetColors.brown,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 13,
          width: 105,
          height: 44,
          child: ElevatedButton(
            key: const ValueKey('appointment-booking-save'),
            onPressed: saving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: VetColors.pink,
              foregroundColor: VetColors.brown,
              elevation: 2,
              shadowColor: VetColors.shadowDark,
              padding: EdgeInsets.zero,
              minimumSize: const Size(105, 44),
              maximumSize: const Size(105, 44),
              shape: const StadiumBorder(
                side: BorderSide(color: Colors.white, width: 1),
              ),
            ),
            child: Text(
              saving ? 'Salvando…' : 'Salvar',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _icon(IconData icon, {required double left, required double top}) =>
      Positioned(
        left: left,
        top: top,
        width: 30,
        height: 30,
        child: ExcludeSemantics(
          child: Icon(icon, color: VetColors.brown, size: 29),
        ),
      );

  Widget _staticPill({
    required Key key,
    required double left,
    required double top,
    required String label,
    required String semanticLabel,
    required Color color,
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: VetColors.brown, fontSize: 13),
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
    required VoidCallback onTap,
  }) => Positioned(
    left: left,
    top: top,
    width: 222,
    height: 35,
    child: Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          key: key,
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ExcludeSemantics(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: VetColors.calendarTextOnRose,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _timePill({
    required Key key,
    required String label,
    required String semanticLabel,
    required Color color,
    required VoidCallback onTap,
  }) => Expanded(
    child: Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: key,
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Container(
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ExcludeSemantics(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: VetColors.calendarTextOnRose,
                    fontSize: 13,
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
    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }
}
