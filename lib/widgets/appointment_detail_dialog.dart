import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter_svg/flutter_svg.dart';

import '../core/utils/formatters.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../theme/vet_colors.dart';
import 'figma_action_target.dart';
import 'pets/pet_avatar.dart';
import 'pets/pets_theme.dart';

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
    final scale = math.min(
      1.0,
      math.min(viewport.width / 390, viewport.height / 381),
    );
    final extraHeight = math.min(
      188 * (1 - scale),
      math.max(0.0, viewport.height - 381 * scale),
    );
    final surfaceHeight = 381 * scale + extraHeight;
    final detailsHeight = 110 * scale + extraHeight;
    final deleteBottom = math.min(
      surfaceHeight,
      math.max(348 * scale, 288 * scale + 48) + extraHeight,
    );
    final details = [
      fmtData(appointment.data),
      fmtHorario(appointment.data, appointment.endDate),
      'Veterinário: ${appointment.veterinario}',
      if (appointment.address != null) 'Endereço: ${appointment.locationLabel}',
      'Local: ${appointment.local}',
      if (appointment.descricao?.trim().isNotEmpty ?? false)
        'Observação: ${appointment.descricao!.trim()}',
    ].join('\n');
    final detailsFontSize = 10 + ((390 - viewport.width) / 35).clamp(0.0, 2.0);
    final detailsStyle = TextStyle(
      color: VetColors.calendarTextOnRose,
      fontFamily: 'Comfortaa',
      fontSize: detailsFontSize,
      fontWeight: FontWeight.bold,
      height: 1.35,
    );
    final titleStyle = TextStyle(
      color: VetColors.brown,
      fontFamily: 'MontserratAlternates',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.1,
    );
    final titlePainter = TextPainter(
      text: TextSpan(text: appointment.tipo, style: titleStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: 151 * scale);
    final titleOverflowed =
        titlePainter.didExceedMaxLines || titlePainter.height > 42 * scale;
    titlePainter.dispose();
    final detailsPainter = TextPainter(
      text: TextSpan(text: details, style: detailsStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 7,
      ellipsis: '…',
    )..layout(maxWidth: 140 * scale);
    final detailsOverflowed =
        detailsPainter.didExceedMaxLines ||
        detailsPainter.height > detailsHeight;
    detailsPainter.dispose();
    final showFullDetails = titleOverflowed || detailsOverflowed;
    final lineHeight =
        MediaQuery.textScalerOf(context).scale(detailsFontSize) * 1.35;
    final visibleLines =
        ((detailsHeight - (showFullDetails ? 48 : 0)) / lineHeight)
            .floor()
            .clamp(1, 7);
    final hasObservation = appointment.descricao?.trim().isNotEmpty ?? false;
    final readFullDetailsLabel = hasObservation
        ? 'Ler observação completa'
        : 'Ler detalhes completos';

    void openFullDetails() {
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          final dialogSize = MediaQuery.sizeOf(dialogContext);
          final dialogHeight = math.min(420.0, dialogSize.height * .75);
          final dialogWidth = math.min(390.0, dialogSize.width - 32);
          return Dialog(
            key: const ValueKey('appointment-full-details-dialog'),
            insetPadding: const EdgeInsets.all(16),
            child: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Detalhes do agendamento',
                      style: Theme.of(dialogContext).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        key: const ValueKey('appointment-full-details-scroll'),
                        child: SelectableText(
                          'Serviço: ${appointment.tipo}\n$details',
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Fechar'),
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
        height: surfaceHeight,
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
                  left: 29.5 * scale,
                  top: 120.5 * scale,
                  width: 141 * scale,
                  height: 141 * scale,
                  child: ExcludeSemantics(
                    child: IgnorePointer(
                      child: SvgPicture.asset(
                        'assets/imagens/figma/appointment-detail-ring.svg',
                        key: const ValueKey('appointment-detail-ring'),
                        width: 141 * scale,
                        height: 141 * scale,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 38 * scale,
                  top: 129 * scale,
                  width: 123 * scale,
                  height: 123 * scale,
                  child: DecoratedBox(
                    decoration: inset.BoxDecoration(
                      borderRadius: BorderRadius.circular(100 * scale),
                      boxShadow: [
                        inset.BoxShadow(
                          color: const Color(0x40000000),
                          offset: Offset(2 * scale, 2 * scale),
                          blurRadius: 5 * scale,
                          inset: true,
                        ),
                      ],
                    ),
                    child: Center(
                      child: PetAvatar(
                        image: pet.imagePath,
                        photoBase64: pet.photoBase64,
                        species: pet.species,
                        size: 105 * scale / PetsTheme.scaleOf(context),
                        silhouetteSurface: Colors.transparent,
                        silhouetteColor: VetColors.brownSecondary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 195 * scale,
                  top: 92 * scale,
                  width: 167 * scale,
                  height: 188 * scale + extraHeight,
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
                            height: 50 * scale,
                            child: ColoredBox(
                              color: VetColors.chatComposerBackground,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8 * scale,
                                    vertical: 4 * scale,
                                  ),
                                  child: Text(
                                    appointment.tipo,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: titleStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            key: const ValueKey(
                              'appointment-detail-text-region',
                            ),
                            left: 13 * scale,
                            top: 74 * scale,
                            width: 140 * scale,
                            height: detailsHeight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Semantics(
                                    label: details,
                                    excludeSemantics: true,
                                    child: Text(
                                      details,
                                      maxLines: visibleLines,
                                      overflow: TextOverflow.ellipsis,
                                      style: detailsStyle,
                                    ),
                                  ),
                                ),
                                if (showFullDetails)
                                  FigmaActionTarget(
                                    key: const ValueKey(
                                      'appointment-detail-read-more-target',
                                    ),
                                    width: 140 * scale,
                                    height: 48,
                                    label: readFullDetailsLabel,
                                    onPressed: openFullDetails,
                                    child: Text(
                                      hasObservation
                                          ? 'Ler observação'
                                          : 'Ver detalhes',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: VetColors.calendarTextOnRose,
                                        fontFamily: 'Comfortaa',
                                        fontSize: 12,
                                        height: 1,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 140 * scale,
                  top: deleteBottom - 48,
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
