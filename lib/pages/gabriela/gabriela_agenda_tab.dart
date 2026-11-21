import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/vet_colors.dart';
import '../../widgets/auth/demo_mode_notice.dart';
import '../../widgets/vet/vet_centered_dialog.dart';
import 'gabriela_calendar_picker.dart';
import 'gabriela_appointment.dart';
import 'gabriela_appointment_dialog.dart';

class GabrielaAgendaTab extends StatefulWidget {
  const GabrielaAgendaTab({super.key});

  @override
  State<GabrielaAgendaTab> createState() => _GabrielaAgendaTabState();
}

class _GabrielaAgendaTabState extends State<GabrielaAgendaTab> {
  late DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  static final _demoDate = DateTime(2026, 3, 10);

  static final _demoAppointments = [
    GabrielaAppointment(
      isDemonstration: true,
      startTime: '10:00',
      endTime: '11:00',
      clientName: 'Rambo',
      clientFullName: 'Rambo Augusto',
      petName: 'Fernando',
      service: 'Hemograma + 3',
      serviceDescription:
          'Hemograma e mais 3 serviços previstos para esta consulta.',
      address: 'R. Augusto Cury 123 - Vila Osasco',
      imageAsset: 'assets/imagens/figma/fernando.png',
      sex: 'M',
      weight: '24kg',
      birthDate: DateTime(2012, 3, 23),
      breed: 'Lulu-da-Pomerânia',
    ),
    const GabrielaAppointment(
      isDemonstration: true,
      startTime: '16:00',
      endTime: '17:00',
      clientName: 'Olivia',
      clientFullName: 'Olivia Palito',
      petName: 'Kelly',
      service: 'Consulta clínica',
      serviceDescription: 'Atendimento veterinário agendado.',
      address: 'R. Augusto Cury 123 - Vila Osasco',
    ),
    const GabrielaAppointment(
      isDemonstration: true,
      startTime: '13:00',
      endTime: '14:00',
      clientName: 'Nicolly',
      clientFullName: 'Nicolly Santos',
      petName: 'Rambo',
      service: 'Avaliação de retorno',
      serviceDescription: 'Atendimento de retorno agendado.',
      address: 'R. Augusto Cury 123 - Vila Osasco',
    ),
  ];

  String get _dayLabel =>
      '${_selectedDate.day} - ${const ['Segunda Feira', 'Terça Feira', 'Quarta Feira', 'Quinta Feira', 'Sexta Feira', 'Sábado', 'Domingo'][_selectedDate.weekday - 1]}';

  List<GabrielaAppointment> get _visibleAppointments =>
      DateUtils.isSameDay(_selectedDate, _demoDate)
      ? _demoAppointments
      : const [];

  void _showAppointment(GabrielaAppointment appointment) =>
      showVetCenteredDialog<void>(
        context: context,
        builder: (_) => GabrielaAppointmentDetails(appointment: appointment),
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = math.min(390.0, constraints.maxWidth);
      final s = width / 390;
      final appointments = _visibleAppointments;
      final showingDemo = DateUtils.isSameDay(_selectedDate, _demoDate);
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: width,
          height: constraints.maxHeight,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: VetColors.rose,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30 * s),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(24 * s, 20 * s, 24 * s, 0),
                  child: Column(
                    children: [
                      GabrielaCalendarPicker(
                        selectedDate: _selectedDate,
                        onChanged: (date) =>
                            setState(() => _selectedDate = date),
                      ),
                      Transform.translate(
                        offset: Offset(0, 18 * s),
                        child: Container(
                          width: 258 * s,
                          padding: EdgeInsets.symmetric(vertical: 6 * s),
                          decoration: BoxDecoration(
                            color: VetColors.pinkOverlay50,
                            border: Border.all(
                              color: VetColors.rose,
                              width: 5 * s,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            _dayLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 20 * s,
                              color: VetColors.brown,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40 * s),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: DemoModeNotice(
                    message:
                        'Agenda demonstrativa. Consultas de clientes não são compartilhadas.',
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedDate = showingDemo
                        ? DateUtils.dateOnly(DateTime.now())
                        : _demoDate;
                  }),
                  child: Text(
                    showingDemo
                        ? 'Voltar para hoje'
                        : 'Ver exemplos de 10/03/2026',
                    textAlign: TextAlign.center,
                  ),
                ),
                if (appointments.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(24 * s),
                    child: const Text(
                      'Nenhum agendamento para este dia.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: VetColors.brown),
                    ),
                  )
                else
                  for (var index = 0; index < appointments.length; index++) ...[
                    _AppointmentTile(
                      appointment: appointments[index],
                      onTap: () => _showAppointment(appointments[index]),
                      scale: s,
                      arrow: index == 0
                          ? 'agenda-up.svg'
                          : index == appointments.length - 1
                          ? 'agenda-down.svg'
                          : null,
                    ),
                    if (index < appointments.length - 1)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 14 * s),
                        child: SizedBox(
                          width: 226.333 * s,
                          height: 5.33333 * s,
                          child: FittedBox(
                            child: SvgPicture.asset(
                              'assets/imagens/figma/agenda-line.svg',
                            ),
                          ),
                        ),
                      ),
                  ],
                SizedBox(height: 20 * s),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({
    required this.appointment,
    required this.onTap,
    required this.scale,
    this.arrow,
  });
  final GabrielaAppointment appointment;
  final VoidCallback onTap;
  final double scale;
  final String? arrow;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 37 * scale),
    child: Row(
      children: [
        SizedBox(
          width: 44 * scale,
          child: Text(
            '${appointment.startTime}\n${appointment.endTime}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15 * scale,
              height: 1.25,
            ),
          ),
        ),
        SizedBox(width: 15 * scale),
        Expanded(
          child: Material(
            color: VetColors.rose,
            borderRadius: BorderRadius.circular(15 * scale),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(15 * scale),
              child: Container(
                constraints: BoxConstraints(minHeight: 50 * scale),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 12 * scale,
                ),
                child: Text(
                  appointment.clientFullName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15 * scale,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 42 * scale),
        SizedBox(
          width: 20 * scale,
          child: arrow == null
              ? null
              : FittedBox(
                  child: RotatedBox(
                    quarterTurns: arrow == 'agenda-up.svg' ? 3 : 1,
                    child: SvgPicture.asset('assets/imagens/figma/$arrow'),
                  ),
                ),
        ),
      ],
    ),
  );
}
