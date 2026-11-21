import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/vet_colors.dart';
import '../../widgets/auth/demo_mode_notice.dart';
import 'gabriela_appointment.dart';

class GabrielaAppointmentDetails extends StatelessWidget {
  const GabrielaAppointmentDetails({super.key, required this.appointment});
  final GabrielaAppointment appointment;
  static const _base = 'assets/imagens/figma/';

  TextStyle _text(
    double size, {
    Color color = VetColors.brown,
    String font = 'Comfortaa',
  }) => TextStyle(
    fontFamily: font == 'Comfortaa' ? font : null,
    fontSize: size,
    color: color,
    height: 1.2,
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final s = constraints.maxWidth / 390;
      final a = appointment;
      final hasDetails =
          a.sex != null ||
          a.weight != null ||
          a.birthDate != null ||
          a.breed != null;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 70 * s),
            alignment: Alignment.center,
            color: VetColors.rose,
            child: Text(
              a.clientName,
              textAlign: TextAlign.center,
              style: _text(40 * s, color: Colors.white),
            ),
          ),
          if (a.isDemonstration)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: DemoModeNotice(
                compact: true,
                message: 'Consulta demonstrativa',
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(25 * s, 15 * s, 25 * s, 19 * s),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 155 * s,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 141 * s,
                            height: 141 * s,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 123 * s,
                                  height: 123 * s,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        VetColors.pinkOverlay50,
                                        VetColors.pink,
                                      ],
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: VetColors.shadowDark,
                                        blurRadius: 5,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: a.imageAsset == null
                                      ? Center(
                                          child: Text(
                                            'Sem foto',
                                            style: _text(12 * s),
                                          ),
                                        )
                                      : Center(
                                          child: Transform.flip(
                                            flipX: true,
                                            child: Opacity(
                                              opacity: .5,
                                              child: Image.asset(
                                                a.imageAsset!,
                                                width: 72 * s,
                                                height: 80 * s,
                                                fit: BoxFit.contain,
                                                semanticLabel:
                                                    'Foto de ${a.petName}',
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                                FittedBox(
                                  child: SvgPicture.asset(
                                    '${_base}pet-outline.svg',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 7 * s),
                          Text(
                            a.petName,
                            textAlign: TextAlign.center,
                            style: _text(20 * s),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15 * s),
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(minHeight: 169 * s),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: VetColors.rose,
                          borderRadius: BorderRadius.circular(15 * s),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              color: VetColors.chatComposerBackground,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8 * s,
                                vertical: 10 * s,
                              ),
                              child: Text(
                                a.service,
                                textAlign: TextAlign.center,
                                style: _text(
                                  12 * s,
                                  font: 'MontserratAlternates',
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(13 * s),
                              child: Text(
                                a.serviceDescription,
                                style: _text(10 * s, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasDetails) ...[
                  SizedBox(height: 17 * s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 6 * s,
                        height: 158.333 * s,
                        child: FittedBox(
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: SvgPicture.asset('${_base}detail-line.svg'),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 252 * s,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                            16 * s,
                            10 * s,
                            23 * s,
                            12 * s,
                          ),
                          decoration: BoxDecoration(
                            color: VetColors.roseOverlay25,
                            borderRadius: BorderRadius.circular(25 * s),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  if (a.sex != null)
                                    Expanded(
                                      child: _labelled(
                                        s,
                                        'Gênero/Sexo',
                                        _pill(
                                          s,
                                          a.sex!,
                                          'pet-sex.svg',
                                          completeIcon: true,
                                        ),
                                      ),
                                    ),
                                  if (a.sex != null && a.weight != null)
                                    SizedBox(width: 13 * s),
                                  if (a.weight != null)
                                    Expanded(
                                      child: _labelled(
                                        s,
                                        'Peso',
                                        _pill(s, a.weight!, 'pet-weight.svg'),
                                      ),
                                    ),
                                ],
                              ),
                              if (a.birthDate case final date?) ...[
                                SizedBox(height: 5 * s),
                                _labelled(
                                  s,
                                  'Data de Nascimento',
                                  _pill(
                                    s,
                                    '${date.day.toString().padLeft(2, '0')} / ${date.month.toString().padLeft(2, '0')} / ${date.year}',
                                    'pet-birthday.svg',
                                  ),
                                ),
                              ],
                              if (a.breed case final breed?) ...[
                                SizedBox(height: 5 * s),
                                _labelled(
                                  s,
                                  'Raça',
                                  _pill(s, breed, 'pet-breed.svg'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 6 * s,
                        height: 158.333 * s,
                        child: FittedBox(
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: SvgPicture.asset('${_base}detail-line.svg'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 17 * s),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 16 * s,
                    horizontal: 8 * s,
                  ),
                  decoration: BoxDecoration(
                    color: VetColors.roseOverlay50,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(5 * s),
                      bottom: Radius.circular(20 * s),
                    ),
                  ),
                  child: Text(
                    a.address,
                    textAlign: TextAlign.center,
                    style: _text(15 * s, font: 'MontserratAlternates'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  Widget _labelled(double s, String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 6 * s, bottom: 3 * s),
        child: Text(label, style: _text(10 * s, font: 'MontserratAlternates')),
      ),
      child,
    ],
  );

  Widget _pill(
    double s,
    String value,
    String icon, {
    bool completeIcon = false,
  }) => Container(
    constraints: BoxConstraints(minHeight: 40 * s),
    decoration: BoxDecoration(
      color: VetColors.roseOverlay50,
      borderRadius: BorderRadius.circular(100),
    ),
    child: Row(
      children: [
        if (completeIcon)
          SizedBox(
            width: 41 * s,
            height: 40 * s,
            child: FittedBox(child: SvgPicture.asset('$_base$icon')),
          )
        else
          Container(
            width: 41 * s,
            height: 40 * s,
            decoration: BoxDecoration(
              color: VetColors.pink,
              border: Border.all(color: VetColors.rose, width: 4 * s),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Transform.scale(
                scale: s,
                child: SvgPicture.asset('$_base$icon'),
              ),
            ),
          ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: _text(12 * s, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
