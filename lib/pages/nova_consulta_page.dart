import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets/appointment_booking_card.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/pet_summary.dart';
import '../widgets/vet_calendar.dart';
import '../widgets/vet/vet_page_scaffold.dart';

const _appointmentVeterinarian = 'Dra. Ana Silva';

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
  if (VetRepository.hasAppointmentConflict(
    petId: petId,
    veterinarian: appointment.veterinario,
    start: appointment.data,
    end: appointment.endDate ?? appointment.data.add(const Duration(hours: 1)),
  )) {
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
  static const _localityNoticeText =
      'Demonstração local: esta consulta é salva apenas neste dispositivo e não é enviada à veterinária.';
  static const _localityNoticeStyle = TextStyle(
    color: VetColors.brown,
    fontSize: 12,
    height: 1.35,
  );

  DateTime _date = DateTime.now().add(const Duration(days: 1));
  late DateTime _calendarMonth;
  TimeOfDay? _time = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay? _end = const TimeOfDay(hour: 13, minute: 0);
  bool _saving = false;
  final _description = TextEditingController();
  DateTime _at(TimeOfDay t) =>
      DateTime(_date.year, _date.month, _date.day, t.hour, t.minute);

  void _selectDate(DateTime date) {
    var clearedByConflict = false;
    setState(() {
      _date = date;
      _calendarMonth = DateTime(date.year, date.month);
      if (_time == null) return;

      final start = _at(_time!);
      if (!isFutureAppointmentTime(start, DateTime.now())) {
        _time = null;
        _end = null;
        return;
      }

      final end = _end == null ? null : _at(_end!);
      if (end != null &&
          end.isAfter(start) &&
          VetRepository.hasAppointmentConflict(
            petId: widget.pet.id,
            veterinarian: _appointmentVeterinarian,
            start: start,
            end: end,
          )) {
        _time = null;
        _end = null;
        clearedByConflict = true;
      }
    });
    if (clearedByConflict) {
      _message(
        'O horário selecionado conflita com outro agendamento nesta data. '
        'Escolha outro horário.',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _calendarMonth = DateTime(_date.year, _date.month);

    final start = _at(_time!);
    final end = _at(_end!);
    final initialConflict =
        end.isAfter(start) &&
        VetRepository.hasAppointmentConflict(
          petId: widget.pet.id,
          veterinarian: _appointmentVeterinarian,
          start: start,
          end: end,
        );
    if (initialConflict) {
      _time = null;
      _end = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _message(
            'O horário padrão conflita com outro agendamento nesta data. '
            'Escolha outro horário.',
          );
        }
      });
    }
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
                  onPreviousMonth: () => setDialogState(() {
                    final previous = DateTime(month.year, month.month - 1);
                    final firstMonth = DateTime(today.year, today.month);
                    if (!previous.isBefore(firstMonth)) month = previous;
                  }),
                  onNextMonth: () => setDialogState(() {
                    month = DateTime(month.year, month.month + 1);
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
    if (date != null && mounted) _selectDate(date);
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
        petId: widget.pet.id,
        veterinarian: _appointmentVeterinarian,
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
  Future<void> _schedule() async {
    if (_saving) return;
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
    final endDate = _at(_end!);
    if (VetRepository.hasAppointmentConflict(
      petId: widget.pet.id,
      veterinarian: _appointmentVeterinarian,
      start: date,
      end: endDate,
    )) {
      _message('Este horário se sobrepõe a outro agendamento salvo.');
      return;
    }
    late final bool scheduled;
    try {
      scheduled = tryScheduleAppointment(
        petId: widget.pet.id,
        appointment: Agendamento(
          data: date,
          endDate: endDate,
          tipo: widget.service,
          veterinario: _appointmentVeterinarian,
          local: 'VetHome · ${widget.plan}',
          status: StatusAgendamento.pendente,
          descricao: _description.text.trim(),
        ),
        now: DateTime.now(),
      );
    } on PersistenceBlockedException {
      if (!mounted) return;
      _message('Armazenamento local bloqueado. Nenhuma consulta foi criada.');
      return;
    }
    if (!scheduled) {
      _message('Escolha uma data e horário futuros.');
      return;
    }
    setState(() => _saving = true);
    final saved = await VetRepository.flush();
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) {
      _message(
        'Consulta criada nesta sessão. Não foi possível salvar localmente.',
      );
    }
    if (ModalRoute.of(context)?.isCurrent == false) return;
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
        textColor: VetColors.calendarTextOnRose,
        iconColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: VetColors.calendarTextOnRose,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: VetColors.calendarTextOnRose,
        ),
        shape: StadiumBorder(),
      ),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pet = VetRepository.petById(widget.pet.id) ?? widget.pet;
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < VH.desktopBreakpoint;
    final compactMobileAction = isMobile && _needsCompactConfirmButton(context);
    final page = VetPageScaffold(
      title: 'Novo agendamento',
      pet: pet,
      selectedIndex: 3,
      contentMaxWidth: 1120,
      edgeToEdgeContentOnMobile: true,
      footerReserveHeight: compactMobileAction ? 112 : null,
      footer: isMobile
          ? (compactMobileAction ? _compactConfirmButton() : null)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _localityNotice(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _schedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VetColors.brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      _saving ? 'Salvando…' : 'Confirmar agendamento',
                    ),
                  ),
                ),
              ],
            ),
      children: [
        VetResponsiveLayout(
          mobile: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _localityNotice(),
              ),
              const SizedBox(height: 12),
              AppointmentBookingCard(
                service: widget.service,
                plan: widget.plan,
                petName: pet.name,
                date: _date,
                start: _time,
                end: _end,
                descriptionController: _description,
                onChooseDate: _chooseDate,
                onChooseStart: () => _chooseTime(),
                onChooseEnd: () => _chooseTime(end: true),
                onSave: _schedule,
                saving: _saving,
                showSaveButton: !compactMobileAction,
              ),
            ],
          ),
          desktop: Row(
            key: const ValueKey('new-appointment-desktop-layout'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _inlineCalendar()),
              const SizedBox(width: 28),
              Expanded(child: _form(context, pet, dateDialogEnabled: false)),
            ],
          ),
        ),
      ],
    );
    return PopScope(
      canPop: !_saving,
      child: AbsorbPointer(absorbing: _saving, child: page),
    );
  }

  bool _needsCompactConfirmButton(BuildContext context) {
    final media = MediaQuery.of(context);
    final scale = PetsTheme.scaleOf(context);
    final cardScale = math
        .min(media.size.width / AppointmentBookingCard.designWidth, 1.0)
        .toDouble();
    final headerTopPadding = media.padding.top > 14 * scale
        ? media.padding.top
        : 14 * scale;
    final headerHeight = math.max(
      VH.headerHeight,
      headerTopPadding + 70 * scale,
    );
    final navigationHeight = 88 * scale + media.viewPadding.bottom;
    final pagePadding = VH.pagePaddingFor(media.size.width) * scale;
    final noticeTextPainter = TextPainter(
      text: TextSpan(
        text: _localityNoticeText,
        style: DefaultTextStyle.of(context).style.merge(_localityNoticeStyle),
      ),
      textScaler: media.textScaler,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: math.max(1, media.size.width - 26));
    final noticeHeight = math.max(18.0, noticeTextPainter.height) + 8;
    noticeTextPainter.dispose();
    final actionBottom =
        headerHeight +
        pagePadding +
        noticeHeight +
        12 +
        AppointmentBookingCard.designHeight * cardScale;
    final usableViewportHeight = media.size.height - media.viewInsets.bottom;
    return actionBottom > usableViewportHeight - navigationHeight;
  }

  Widget _compactConfirmButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      key: const ValueKey('appointment-booking-compact-confirm'),
      onPressed: _saving ? null : _schedule,
      style: ElevatedButton.styleFrom(
        backgroundColor: VetColors.brown,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        minimumSize: const Size.fromHeight(48),
      ),
      child: Text(_saving ? 'Salvando…' : 'Confirmar agendamento'),
    ),
  );

  Widget _localityNotice() => Semantics(
    key: const ValueKey('appointment-locality-notice'),
    container: true,
    label: _localityNoticeText,
    child: ExcludeSemantics(
      child: const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: VetColors.brown),
            SizedBox(width: 8),
            Expanded(
              child: Text(_localityNoticeText, style: _localityNoticeStyle),
            ),
          ],
        ),
      ),
    ),
  );

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
      onSelected: _selectDate,
    );
  }

  Widget _form(
    BuildContext context,
    PetModel pet, {
    required bool dateDialogEnabled,
  }) => Column(
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
          onTap: dateDialogEnabled ? _chooseDate : null,
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
        style: const TextStyle(color: VetColors.calendarTextOnRose),
        maxLength: 500,
        decoration: InputDecoration(
          filled: true,
          fillColor: VetColors.rose,
          hintStyle: const TextStyle(color: VetColors.calendarTextOnRose),
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
  const _TimeChoices({
    required this.date,
    required this.petId,
    required this.veterinarian,
    this.minimum,
    this.selected,
  });
  final DateTime date;
  final String petId;
  final String veterinarian;
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
    final start = widget.minimum ?? date;
    final end = widget.minimum == null
        ? date.add(const Duration(hours: 1))
        : date;
    return isFutureAppointmentTime(
          date,
          DateTime.now(),
          after: widget.minimum,
        ) &&
        !VetRepository.hasAppointmentConflict(
          petId: widget.petId,
          veterinarian: widget.veterinarian,
          start: start,
          end: end,
        );
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.minimum == null
        ? [12, 13, 14, 15, 16]
        : [13, 14, 15, 16, 17];
    final width = math.min(390.0, MediaQuery.sizeOf(context).width);
    final firstRowGap = ((width - 300) / 2).clamp(10.0, 28.0).toDouble();
    final secondRowGap = ((width - 300) / 2).clamp(10.0, 26.0).toDouble();
    final firstRowLeft = (width - 300 - firstRowGap - secondRowGap) / 2;
    final secondRowLeft = (width - 200 - secondRowGap) / 2 + 4 * width / 390;
    final buttonLefts = [
      firstRowLeft,
      firstRowLeft + 100 + firstRowGap,
      firstRowLeft + 200 + firstRowGap + secondRowGap,
      secondRowLeft,
      secondRowLeft + 100 + secondRowGap,
    ];
    final buttonTops = [28.0, 28.0, 28.0, 95.0, 95.0];
    final hasAvailableTime = options.any(_available);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: Semantics(
        key: const ValueKey('time-choice-semantics'),
        container: true,
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: hasAvailableTime
            ? 'Escolha o horário'
            : 'Escolha o horário. Nenhum horário disponível para a data escolhida.',
        child: Container(
          key: const ValueKey('time-choice-panel'),
          width: width,
          height: 168,
          constraints: const BoxConstraints(maxWidth: 390),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: VetColors.pink,
            borderRadius: BorderRadius.circular(30),
          ),
          child: SizedBox(
            key: const ValueKey('time-choice-grid'),
            width: width,
            height: 168,
            child: Stack(
              children: [
                for (var index = 0; index < options.length; index++)
                  Positioned(
                    left: buttonLefts[index],
                    top: buttonTops[index],
                    width: 100,
                    height: 45,
                    child: Semantics(
                      key: ValueKey('time-choice-semantics-${options[index]}'),
                      button: true,
                      selected: widget.selected?.hour == options[index],
                      enabled: _available(options[index]),
                      label: '${options[index].toString().padLeft(2, '0')}:00',
                      onTap: _available(options[index])
                          ? () => Navigator.pop(
                              context,
                              TimeOfDay(hour: options[index], minute: 0),
                            )
                          : null,
                      excludeSemantics: true,
                      child: Container(
                        key: ValueKey('time-choice-shadow-${options[index]}'),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, .25),
                              offset: Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          key: ValueKey('time-choice-${options[index]}'),
                          onPressed: _available(options[index])
                              ? () => Navigator.pop(
                                  context,
                                  TimeOfDay(hour: options[index], minute: 0),
                                )
                              : null,
                          style: ButtonStyle(
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.zero,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: const WidgetStatePropertyAll(0),
                            backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.disabled)
                                  ? VetColors.rose.withValues(alpha: .18)
                                  : widget.selected?.hour == options[index]
                                  ? VetColors.brown
                                  : VetColors.rose,
                            ),
                            foregroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.disabled)
                                  ? VetColors.brown.withValues(alpha: .35)
                                  : widget.selected?.hour == options[index]
                                  ? Colors.white
                                  : VetColors.calendarTextOnRose,
                            ),
                            textStyle: const WidgetStatePropertyAll(
                              TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            shape: const WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
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
                          child: Text(
                            '${options[index].toString().padLeft(2, '0')}:00',
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
