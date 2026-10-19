import 'dart:async';
import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../theme/vet_colors.dart';
import '../widgets/pet_summary.dart';
import '../widgets/vet_calendar.dart';
import '../widgets/vet/vet_page_scaffold.dart';

bool isFutureAppointmentTime(DateTime time, DateTime now, {DateTime? after}) =>
    time.isAfter(now) && (after == null || time.isAfter(after));

bool tryScheduleAppointment({
  required String petId,
  required Agendamento appointment,
  required DateTime now,
}) {
  if (!isFutureAppointmentTime(appointment.data, now) ||
      (appointment.endDate != null &&
          !isFutureAppointmentTime(
            appointment.endDate!,
            now,
            after: appointment.data,
          ))) {
    return false;
  }
  VetRepository.addAgendamento(petId, appointment);
  return true;
}

class NovaConsultaPage extends StatefulWidget {
  const NovaConsultaPage({
    required this.pet,
    required this.service,
    required this.plan,
    super.key,
  });
  final PetModel pet;
  final String service, plan;
  @override
  State<NovaConsultaPage> createState() => _NovaConsultaPageState();
}

class _NovaConsultaPageState extends State<NovaConsultaPage> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  late DateTime _calendarMonth;
  TimeOfDay? _time = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay? _end = const TimeOfDay(hour: 13, minute: 0);
  final _description = TextEditingController();
  DateTime _at(TimeOfDay t) =>
      DateTime(_date.year, _date.month, _date.day, t.hour, t.minute);
  @override
  void initState() {
    super.initState();
    _calendarMonth = DateTime(_date.year, _date.month);
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var selected = _date.isBefore(today) ? today : _date;
    var month = DateTime(selected.year, selected.month);
    final lastDate = DateTime(now.year + 2);
    final date = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            key: const ValueKey('mobile-calendar-dialog'),
            constraints: const BoxConstraints(maxWidth: 390),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            decoration: BoxDecoration(
              color: VetColors.pink,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: VetColors.shadowDark,
                  offset: Offset(2, 2),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                VetCalendar(
                  month: month,
                  selected: selected,
                  firstDate: today,
                  lastDate: lastDate,
                  onPreviousMonth: () => setDialogState(() {
                    final previous = DateTime(month.year, month.month - 1);
                    final firstMonth = DateTime(today.year, today.month);
                    if (!previous.isBefore(firstMonth)) month = previous;
                  }),
                  onNextMonth: () => setDialogState(() {
                    final next = DateTime(month.year, month.month + 1);
                    final lastMonth = DateTime(lastDate.year, lastDate.month);
                    if (!next.isAfter(lastMonth)) month = next;
                  }),
                  onSelected: (value) => setDialogState(() {
                    selected = value;
                    month = DateTime(value.year, value.month);
                  }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, selected),
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (date != null && mounted) {
      setState(() {
        _date = date;
        _calendarMonth = DateTime(date.year, date.month);
        if (_time != null &&
            !isFutureAppointmentTime(_at(_time!), DateTime.now())) {
          _time = null;
          _end = null;
        }
      });
    }
  }

  Future<void> _chooseTime({bool end = false}) async {
    if (end && _time == null) {
      _message('Escolha primeiro o horário inicial.');
      return;
    }
    final value = await showDialog<TimeOfDay>(
      context: context,
      builder: (_) => _TimeChoices(
        date: _date,
        minimum: end ? _at(_time!) : null,
        selected: end ? _end : _time,
      ),
    );
    if (value != null && mounted) {
      setState(() {
        if (end) {
          _end = value;
        } else {
          _time = value;
          _end = TimeOfDay(hour: value.hour + 1, minute: 0);
        }
      });
    }
  }

  void _message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
  void _schedule() {
    if (_time == null) {
      _message('Escolha uma data e horário futuros.');
      return;
    }
    if (_end == null ||
        !isFutureAppointmentTime(
          _at(_end!),
          DateTime.now(),
          after: _at(_time!),
        )) {
      _message('O horário final deve ser depois do inicial.');
      return;
    }
    final date = _at(_time!);
    final saved = tryScheduleAppointment(
      petId: widget.pet.id,
      appointment: Agendamento(
        data: date,
        endDate: _at(_end!),
        tipo: widget.service,
        veterinario: 'Dra. Ana Silva',
        local: 'VetHome · ${widget.plan}',
        status: StatusAgendamento.pendente,
        descricao: _description.text.trim(),
      ),
      now: DateTime.now(),
    );
    if (!saved) {
      _message('Escolha uma data e horário futuros.');
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/agenda',
      (route) => route.isFirst,
      arguments: date,
    );
  }

  Widget _selectionPill(Widget child) => Material(
    color: VetColors.rose,
    borderRadius: BorderRadius.circular(100),
    child: ListTileTheme(
      data: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        subtitleTextStyle: TextStyle(fontSize: 14, color: Colors.white),
        shape: StadiumBorder(),
      ),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pet = VetRepository.petById(widget.pet.id) ?? widget.pet;
    final form = _form(context, pet);
    return VetPageScaffold(
      title: 'Novo agendamento',
      pet: pet,
      selectedIndex: 3,
      contentMaxWidth: 1120,
      footer: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _schedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: VetColors.brown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Confirmar agendamento'),
        ),
      ),
      children: [
        VetResponsiveLayout(
          mobile: form,
          desktop: Row(
            key: const ValueKey('new-appointment-desktop-layout'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _inlineCalendar()),
              const SizedBox(width: 28),
              Expanded(child: form),
            ],
          ),
        ),
      ],
    );
  }

  Widget _inlineCalendar() {
    final today = DateTime.now();
    return VetCalendar(
      month: _calendarMonth,
      selected: _date,
      firstDate: today,
      onPreviousMonth: () => setState(() {
        final previous = DateTime(
          _calendarMonth.year,
          _calendarMonth.month - 1,
        );
        final currentMonth = DateTime(today.year, today.month);
        if (!previous.isBefore(currentMonth)) _calendarMonth = previous;
      }),
      onNextMonth: () => setState(
        () => _calendarMonth = DateTime(
          _calendarMonth.year,
          _calendarMonth.month + 1,
        ),
      ),
      onSelected: (date) => setState(() {
        _date = date;
        _calendarMonth = DateTime(date.year, date.month);
        if (_time != null &&
            !isFutureAppointmentTime(_at(_time!), DateTime.now())) {
          _time = null;
          _end = null;
        }
      }),
    );
  }

  Widget _form(BuildContext context, PetModel pet) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PetSummary(pet: pet),
      const SizedBox(height: 12),
      const Divider(),
      const Text(
        'Detalhes do agendamento',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: VetColors.rose.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Serviço: ${const ['V8', 'V10', 'Antirrábica'].contains(widget.service)
                  ? 'Vacina'
                  : const ['Hemograma', 'Creatinina', 'Urina'].contains(widget.service)
                  ? 'Exames'
                  : widget.service}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (const ['V8', 'V10', 'Antirrábica'].contains(widget.service))
              Text('Vacina: ${widget.service}')
            else if (const [
              'Hemograma',
              'Creatinina',
              'Urina',
            ].contains(widget.service))
              Text('Exame: ${widget.service}'),
            const SizedBox(height: 6),
            Text('Convênio: ${widget.plan}'),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _selectionPill(
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: const Icon(Icons.calendar_month),
          title: const Text('Data'),
          subtitle: Text(
            '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
          ),
          trailing: const Icon(Icons.edit_calendar),
          onTap: MediaQuery.sizeOf(context).width >= 900 ? null : _chooseDate,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _selectionPill(
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: const Text('Início'),
                subtitle: Text(_time?.format(context) ?? 'Selecione'),
                trailing: const Icon(Icons.schedule, size: 18),
                onTap: () => _chooseTime(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _selectionPill(
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: const Text('Fim'),
                subtitle: Text(_end?.format(context) ?? 'Selecione'),
                trailing: const Icon(Icons.schedule_outlined, size: 18),
                onTap: () => _chooseTime(end: true),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _description,
        minLines: 3,
        maxLines: 5,
        style: const TextStyle(color: Colors.white),
        maxLength: 500,
        decoration: InputDecoration(
          filled: true,
          fillColor: VetColors.rose,
          hintStyle: const TextStyle(color: Colors.white),
          hintText: 'Adicionar uma descrição (opcional)',
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}

class _TimeChoices extends StatefulWidget {
  const _TimeChoices({required this.date, this.minimum, this.selected});
  final DateTime date;
  final DateTime? minimum;
  final TimeOfDay? selected;
  @override
  State<_TimeChoices> createState() => _TimeChoicesState();
}

class _TimeChoicesState extends State<_TimeChoices> {
  late final Timer _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool _available(int hour) {
    final date = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      hour,
    );
    return isFutureAppointmentTime(date, DateTime.now(), after: widget.minimum);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.minimum == null
        ? [12, 13, 14, 15, 16]
        : [13, 14, 15, 16, 17];
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        key: const ValueKey('time-choice-panel'),
        constraints: const BoxConstraints(maxWidth: 390),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
        decoration: BoxDecoration(
          color: VetColors.pink,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: VetColors.shadowDark,
              offset: Offset(2, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escolha o horário',
              style: TextStyle(
                color: VetColors.brown,
                fontFamily: 'Comfortaa',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            if (!options.any(_available))
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Nenhum horário disponível. Escolha outra data.'),
              ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final hour in options)
                  SizedBox(
                    key: ValueKey('time-choice-$hour'),
                    width: 96,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _available(hour)
                          ? () => Navigator.pop(
                              context,
                              TimeOfDay(hour: hour, minute: 0),
                            )
                          : null,
                      style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll(0),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? VetColors.rose.withValues(alpha: .18)
                              : widget.selected?.hour == hour
                              ? VetColors.brown
                              : VetColors.rose,
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? VetColors.brown.withValues(alpha: .35)
                              : Colors.white,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        overlayColor: WidgetStateProperty.resolveWith(
                          (states) =>
                              states.contains(WidgetState.focused) ||
                                  states.contains(WidgetState.hovered)
                              ? Colors.white.withValues(alpha: .16)
                              : null,
                        ),
                      ),
                      child: Text('${hour.toString().padLeft(2, '0')}:00'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
