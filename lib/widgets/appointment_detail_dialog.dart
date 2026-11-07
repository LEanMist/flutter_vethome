import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../theme/vet_colors.dart';
import 'figma_action_target.dart';
import 'pets/pet_avatar.dart';

class AppointmentDetailDialog extends StatelessWidget {
  const AppointmentDetailDialog({
    super.key,
    required this.pet,
    required this.appointment,
    required this.onDelete,
  });

  final PetModel pet;
  final Agendamento appointment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final scale = math
        .min(1.0, math.min(viewport.width / 390, viewport.height / 346))
        .clamp(.7, 1.0)
        .toDouble();
    final details = [
      fmtData(appointment.data),
      fmtHorario(appointment.data, appointment.endDate),
      'Veterinário: ${appointment.veterinario}',
      'Local: ${appointment.local}',
      if (appointment.descricao?.trim().isNotEmpty ?? false)
        'Observação: ${appointment.descricao!.trim()}',
    ].join('\n');

    return Dialog(
      key: const ValueKey('appointment-detail-dialog'),
      alignment: Alignment.center,
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        key: const ValueKey('appointment-detail-surface'),
        width: 390 * scale,
        height: 346 * scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30 * scale),
          child: ColoredBox(
            color: VetColors.pink,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: 390 * scale,
                  height: 70 * scale,
                  child: ColoredBox(
                    color: VetColors.rose,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            pet.name,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Comfortaa',
                              fontSize: 40 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 31 * scale,
                  top: 107 * scale,
                  width: 138 * scale,
                  height: 138 * scale,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DottedAppointmentRing(scale: scale),
                    ),
                  ),
                ),
                Positioned(
                  left: 38 * scale,
                  top: 115 * scale,
                  width: 123 * scale,
                  height: 123 * scale,
                  child: Center(
                    child: PetAvatar(
                      image: pet.imagePath,
                      photoBase64: pet.photoBase64,
                      species: pet.species,
                      size: 98 * scale,
                    ),
                  ),
                ),
                Positioned(
                  left: 195 * scale,
                  top: 92 * scale,
                  width: 167 * scale,
                  height: 169 * scale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15 * scale),
                    child: ColoredBox(
                      color: VetColors.rose,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            width: 167 * scale,
                            height: 35 * scale,
                            child: ColoredBox(
                              color: VetColors.chatComposerBackground,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8 * scale,
                                  ),
                                  child: Text(
                                    appointment.tipo,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: VetColors.brown,
                                      fontFamily: 'Montserrat Alternates',
                                      fontSize: 12 * scale,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 13 * scale,
                            top: 48 * scale,
                            width: 141 * scale,
                            height: 111 * scale,
                            child: Semantics(
                              label: details,
                              child: Text(
                                details,
                                maxLines: 7,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: VetColors.calendarTextOnRose,
                                  fontFamily: 'Comfortaa',
                                  fontSize: 10 * scale,
                                  fontWeight: FontWeight.bold,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 140 * scale,
                  top: 324 * scale - 48,
                  width: 109 * scale,
                  height: 48,
                  child: FigmaActionTarget(
                    key: const ValueKey('appointment-detail-delete-target'),
                    width: 109 * scale,
                    height: 48,
                    label: 'Deletar consulta',
                    onPressed: onDelete,
                    child: SizedBox(
                      key: const ValueKey('appointment-detail-delete'),
                      width: 109 * scale,
                      height: 41 * scale,
                      child: Material(
                        color: const Color(0xFF940000),
                        borderRadius: BorderRadius.circular(100 * scale),
                        child: Center(
                          child: Text(
                            'Deletar',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Comfortaa',
                              fontSize: 15 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DottedAppointmentRing extends CustomPainter {
  const _DottedAppointmentRing({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VetColors.profileOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;
    final path = Path()..addOval(Offset.zero & size);
    for (final metric in path.computeMetrics()) {
      for (var offset = 0.0; offset < metric.length; offset += 12 * scale) {
        final end = math.min(offset + 6 * scale, metric.length);
        canvas.drawPath(metric.extractPath(offset, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DottedAppointmentRing oldDelegate) =>
      oldDelegate.scale != scale;
}
