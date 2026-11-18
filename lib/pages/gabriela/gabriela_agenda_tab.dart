import 'package:flutter/material.dart';

import '../../theme/vet_colors.dart';
import '../../widgets/pets/pets_theme.dart';

class GabrielaAgendaTab extends StatefulWidget {
  const GabrielaAgendaTab({super.key});

  @override
  State<GabrielaAgendaTab> createState() => _GabrielaAgendaTabState();
}

class _GabrielaAgendaTabState extends State<GabrielaAgendaTab> {
  DateTime _selectedDate = DateTime(2026, 11, 10);

  static const _appointments = [
    _AgendaAppointment(
      '10:00 – 11:00',
      'Rambo Augusto',
      'Consulta de rotina',
      'Fernando',
      'Hemograma + 3',
      'R. Augusto Cury, 123 – Vila Osasco',
    ),
    _AgendaAppointment(
      '13:00 – 14:00',
      'Nicolly Santos',
      'Retorno',
      'Rambo',
      'Avaliação de retorno',
      'R. Augusto Cury, 123 – Vila Osasco',
    ),
    _AgendaAppointment(
      '16:00 – 17:00',
      'Olivia Palito',
      'Consulta',
      'Kelly',
      'Consulta clínica',
      'R. Augusto Cury, 123 – Vila Osasco',
    ),
  ];

  String get _dayLabel =>
      '${_selectedDate.day} - ${_weekday(_selectedDate.weekday)}';

  String _weekday(int day) => const [
    'Segunda Feira',
    'Terça Feira',
    'Quarta Feira',
    'Quinta Feira',
    'Sexta Feira',
    'Sábado',
    'Domingo',
  ][day - 1];

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('pt', 'BR'),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _showAppointment(_AgendaAppointment appointment) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: VetColors.pink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: VetColors.rose,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                appointment.pet,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: VetColors.brown,
                ),
              ),
              Text(
                '${appointment.client} · ${appointment.kind}',
                style: const TextStyle(fontSize: 14, color: VetColors.brown),
              ),
              const SizedBox(height: 18),
              const Text(
                'Dados do paciente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: VetColors.brown,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'M  ·  24 kg  ·  23/03/2012',
                style: TextStyle(color: VetColors.brown),
              ),
              const Text(
                'Lulu-da-Pomerânia',
                style: TextStyle(color: VetColors.brown),
              ),
              const SizedBox(height: 14),
              _DetailCard(
                icon: Icons.medical_services_outlined,
                title: appointment.service,
                subtitle: 'Atendimento veterinário',
              ),
              const SizedBox(height: 10),
              _DetailCard(
                icon: Icons.location_on_outlined,
                title: appointment.address,
                subtitle: appointment.time,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = PetsTheme.scaleOf(context);
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: VetColors.rose,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30 * s),
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: 16 * s),
                  child: InkWell(
                    onTap: _chooseDate,
                    borderRadius: BorderRadius.circular(24 * s),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 21 * s,
                        vertical: 9 * s,
                      ),
                      decoration: BoxDecoration(
                        color: VetColors.pink.withValues(alpha: .75),
                        borderRadius: BorderRadius.circular(22 * s),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _dayLabel,
                            style: TextStyle(
                              fontFamily: PetsTheme.fontComfortaa,
                              color: VetColors.brown,
                              fontWeight: FontWeight.w700,
                              fontSize: 15 * s,
                            ),
                          ),
                          SizedBox(width: 8 * s),
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 18 * s,
                            color: VetColors.brown,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(17 * s, 15 * s, 17 * s, 12 * s),
                  itemCount: _appointments.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10 * s),
                  itemBuilder: (context, index) => _AppointmentTile(
                    appointment: _appointments[index],
                    onTap: () => _showAppointment(_appointments[index]),
                    scale: s,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AgendaAppointment {
  const _AgendaAppointment(
    this.time,
    this.pet,
    this.kind,
    this.client,
    this.service,
    this.address,
  );
  final String time;
  final String pet;
  final String kind;
  final String client;
  final String service;
  final String address;
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({
    required this.appointment,
    required this.onTap,
    required this.scale,
  });
  final _AgendaAppointment appointment;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) => Material(
    color: VetColors.rose.withValues(alpha: .23),
    borderRadius: BorderRadius.circular(15 * scale),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15 * scale),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 11 * scale,
        ),
        child: Row(
          children: [
            Container(
              width: 50 * scale,
              height: 50 * scale,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: VetColors.rose,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.pets, color: Colors.white, size: 24 * scale),
            ),
            SizedBox(width: 11 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.pet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w700,
                      color: VetColors.brown,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    appointment.kind,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: VetColors.brown.withValues(alpha: .82),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6 * scale),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  appointment.time,
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                    color: VetColors.brown,
                  ),
                ),
                SizedBox(height: 3 * scale),
                Icon(
                  Icons.chevron_right,
                  color: VetColors.brown,
                  size: 21 * scale,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: VetColors.rose.withValues(alpha: .2),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(icon, color: VetColors.brown),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: VetColors.brown,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: VetColors.brown),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
