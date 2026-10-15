import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../data/vet_repository.dart';
import '../models/vet_models.dart';
import '../widgets/appointment_card.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});
  @override
  Widget build(BuildContext context) => VHPage(
    tab: '/sobre',
    children: [
      const VHHeader('Sobre a veterinária'),
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset(
              'assets/imagens/figma/vethomepng-2.png',
              width: 140,
              height: 140,
            ),
            const Text(
              'Gabriella',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sobre mim',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sou veterinária há mais de 8 anos, apaixonada por cães e gatos. Atendo em domicílio para que seu pet fique tranquilo no lar.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const ListTile(
              leading: Icon(Icons.phone_outlined),
              title: Text('11 93244-4392'),
            ),
            const ListTile(
              leading: Icon(Icons.email_outlined),
              title: Text('Gabriela@gmail.com'),
            ),
          ],
        ),
      ),
    ],
  );
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ctrl = TextEditingController();

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void enviar() {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => VetRepository.sendChatMessage(text));
    ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return VHPage(
      tab: '/chat',
      footer: ColoredBox(
        color: VetColors.chatComposerBackground,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: insetBox(
                      color: Colors.transparent,
                      radius: 999,
                      gradient: LinearGradient(
                        colors: [
                          VH.background.withValues(alpha: .5),
                          VH.secondary.withValues(alpha: .375),
                        ],
                        stops: const [.25, 1],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        transform: GradientRotation(-0.1781671607501732),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: ctrl,
                      onSubmitted: (_) => enviar(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Mensagem',
                        hintStyle: TextStyle(
                          color: VH.foreground.withValues(alpha: .5),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Enviar mensagem',
                  onPressed: enviar,
                  icon: const Icon(Icons.send, color: VH.foreground),
                ),
              ],
            ),
          ),
        ),
      ),
      children: [
        const VHHeader('Whatsapp'),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: insetBox(color: VH.muted),
          child: Column(
            children: [
              for (final message in VetRepository.chatMessages)
                Align(
                  alignment: message.fromClient
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!message.fromClient) ...[
                        const CircleAvatar(
                          radius: 15,
                          backgroundColor: VH.secondary,
                          child: Icon(
                            Icons.medical_services_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: message.fromClient
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: message.fromClient
                                  ? null
                                  : () =>
                                        Navigator.pushNamed(context, '/sobre'),
                              child: Text(
                                message.fromClient
                                    ? VetRepository.clientName
                                    : 'Gabriella Falcão',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: VetColors.brownSecondary,
                                ),
                              ),
                            ),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.sizeOf(context).width * 0.66,
                              ),
                              margin: const EdgeInsets.only(top: 4, bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: message.fromClient
                                    ? VH.foreground.withValues(alpha: .5)
                                    : VH.card,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: VH.raise,
                              ),
                              child: Text(
                                message.text,
                                style: const TextStyle(color: VH.onSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (message.fromClient) ...[
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 15,
                          backgroundColor: VH.accent,
                          child: Icon(
                            Icons.person_outline,
                            size: 17,
                            color: VH.foreground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Complete weeks starting on Sunday, including adjacent months.
List<DateTime> calendarMonthDays(DateTime month) {
  final first = DateTime(month.year, month.month);
  final offset = first.weekday % 7;
  // Six complete weeks keep the calendar height stable during navigation.
  const cells = 42;
  return List.generate(
    cells,
    (i) => DateTime(month.year, month.month, 1 - offset + i),
  );
}

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late DateTime _mes;
  late DateTime _selecionado;

  @override
  void initState() {
    super.initState();
    _selecionado = widget.initialDate ?? DateTime.now();
    _mes = DateTime(_selecionado.year, _selecionado.month);
  }

  static const meses = [
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

  @override
  Widget build(BuildContext context) {
    final calendarDays = calendarMonthDays(_mes);
    final consultasDoDia = [
      for (final pet in VetRepository.pets)
        for (final agendamento in VetRepository.agendamentos(pet.id))
          if (_sameDay(agendamento.data, _selecionado))
            (
              name: pet.name,
              agendamento: agendamento,
              demo: !VetRepository.realAppointments(
                pet.id,
              ).contains(agendamento),
            ),
      if (_isDemoDate(_selecionado))
        for (final example in const [
          (hour: 10, type: 'Hemograma'),
          (hour: 13, type: 'Urina'),
          (hour: 16, type: 'Creatinina'),
        ])
          (
            name: 'VetHome',
            demo: true,
            agendamento: Agendamento(
              data: DateTime(2026, 1, 13, example.hour),
              endDate: DateTime(2026, 1, 13, example.hour + 1),
              tipo: example.type,
              veterinario: 'Demonstração',
              local: 'VetHome',
              status: StatusAgendamento.pendente,
            ),
          ),
    ]..sort((a, b) => a.agendamento.data.compareTo(b.agendamento.data));

    return VHPage(
      tab: '/agenda',
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                key: const ValueKey('agenda-calendar'),
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: VH.secondary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            tooltip: 'Mês anterior',
                            onPressed: () => _changeMonth(-1),
                            icon: const Icon(
                              Icons.chevron_left,
                              color: VH.onSecondary,
                            ),
                          ),
                          Text(
                            '${meses[_mes.month - 1]} ${_mes.year}',
                            style: const TextStyle(
                              color: VH.foreground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Próximo mês',
                            onPressed: () => _changeMonth(1),
                            icon: const Icon(
                              Icons.chevron_right,
                              color: VH.onSecondary,
                            ),
                          ),
                        ],
                      ),
                      GridView.count(
                        crossAxisCount: 7,
                        mainAxisExtent: 37,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final weekday in [
                            'Dom',
                            'Seg',
                            'Ter',
                            'Qua',
                            'Qui',
                            'Sex',
                            'Sáb',
                          ])
                            Center(
                              child: Text(
                                weekday,
                                style: const TextStyle(
                                  color: VH.foreground,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          for (final date in calendarDays)
                            GestureDetector(
                              key: ValueKey(
                                'calendar-${date.year}-${date.month}-${date.day}',
                              ),
                              onTap: () => setState(() {
                                _selecionado = date;
                                _mes = DateTime(date.year, date.month);
                              }),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _sameDay(date, _selecionado)
                                          ? VH.background
                                          : Colors.transparent,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${date.day}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: VH.foreground.withValues(
                                            alpha: date.month == _mes.month
                                                ? 1
                                                : .3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_isDemoDate(date) ||
                                      _hasAppointment(date))
                                    const Positioned(
                                      bottom: 1,
                                      child: CircleAvatar(
                                        radius: 2,
                                        backgroundColor: VH.onSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 32,
              right: 32,
              child: Center(
                child: Container(
                  width: 258,
                  height: 41,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: VetColors.pinkOverlay50,
                    border: Border.all(color: VH.secondary),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${_selecionado.day} - ${_weekdayNames[_selecionado.weekday % 7]}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/escolhaPet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: VH.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nova Consulta'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: Column(
              children: [
                if (consultasDoDia.isEmpty)
                  if (!_isDemoDate(_selecionado))
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 22),
                      child: Text(
                        'Não há consultas neste dia.',
                        style: TextStyle(color: VH.foreground),
                      ),
                    ),
                for (final item in consultasDoDia)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: VH.secondary,
                        borderRadius: BorderRadius.circular(18),
                        border: Border(
                          bottom: BorderSide(
                            color: VH.foreground.withValues(alpha: .25),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.agendamento.tipo,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  fmtHorario(
                                    item.agendamento.data,
                                    item.agendamento.endDate,
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${item.demo ? 'Demonstração · ' : ''}${item.name} · ${item.agendamento.local}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  static const _weekdayNames = [
    'Domingo',
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDemoDate(DateTime date) =>
      date.year == 2026 && date.month == 1 && date.day == 13;

  bool _hasAppointment(DateTime date) => VetRepository.pets.any(
    (pet) => VetRepository.agendamentos(
      pet.id,
    ).any((appointment) => _sameDay(appointment.data, date)),
  );

  void _changeMonth(int amount) {
    setState(() {
      _mes = DateTime(_mes.year, _mes.month + amount);
      final lastDay = DateTime(_mes.year, _mes.month + 1, 0).day;
      _selecionado = DateTime(
        _mes.year,
        _mes.month,
        _selecionado.day.clamp(1, lastDay),
      );
    });
  }
}

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VHPage(
      tab: '/config',
      children: [
        const VHHeader('Configurações', showBack: false),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              for (final item in <({String label, VoidCallback action})>[
                (
                  label: 'Tema do Aplicativo',
                  action: () => _chooseTheme(context),
                ),
                (
                  label: 'Meus Endereços',
                  action: () => Navigator.pushNamed(context, '/enderecos'),
                ),
                (
                  label: 'Sobre a veterinária',
                  action: () => Navigator.pushNamed(context, '/sobre'),
                ),
                (label: 'Suporte', action: () => _showSupport(context)),
                (label: 'Histórico', action: () => _showHistory(context)),
                (label: 'Sair', action: () => _signOut(context)),
              ]) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: item.action,
                ),
                Divider(
                  height: 1,
                  thickness: .6,
                  color: VH.foreground.withValues(alpha: .25),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _chooseTheme(BuildContext context) async {
    const colors = [
      Color(0xFF68442E),
      Color(0xFFC08081),
      Color(0xFF718B70),
      Color(0xFF6B8FA3),
      Color(0xFF9477A8),
    ];
    var selected = VH.themeSeed.value;
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VH.background,
          title: const Text('Tema do Aplicativo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 132,
                height: 132,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/imagens/figma/image-8.png',
                      width: 132,
                      height: 132,
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: selected,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                children: [
                  for (final color in colors)
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => setDialogState(() => selected = color),
                      child: CircleAvatar(
                        radius: selected == color ? 19 : 16,
                        backgroundColor: color,
                        child: selected == color
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selected),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
    if (color != null) VH.themeSeed.value = color;
  }

  void _showSupport(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VH.background,
        title: const Text('Suporte VetHome'),
        content: const Text(
          'Estamos aqui para ajudar.\n'
          'Telefone: 11 93244-4392\n'
          'E-mail: Gabriela@gmail.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showHistory(BuildContext context) {
    final events = [
      for (final pet in VetRepository.pets)
        for (final a in VetRepository.realAppointments(pet.id))
          (pet: pet, event: a),
    ]..sort((a, b) => a.event.data.compareTo(b.event.data));
    final future =
        events.where((e) => e.event.data.isAfter(DateTime.now())).toList()
          ..sort((a, b) => a.event.data.compareTo(b.event.data));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: VH.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * .85,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Histórico',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      if (future.isEmpty) ...[
                        const Text(
                          'Próximo agendamento',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Nenhum agendamento futuro'),
                        ),
                      ] else
                        AppointmentCard(
                          pet: future.first.pet,
                          event: future.first.event,
                          next: true,
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.pushNamed(
                              context,
                              '/agenda',
                              arguments: future.first.event.data,
                            );
                          },
                        ),
                      const Divider(height: 24),
                      const Text(
                        'Histórico de agendamentos',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (events.isEmpty)
                        const Text('Nenhuma consulta registrada.'),
                      for (final item in events)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              AppointmentCard(pet: item.pet, event: item.event),
                              const Divider(height: 8, thickness: .5),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VH.background,
        title: const Text('Sair do VetHome?'),
        content: const Text('Você poderá entrar novamente quando quiser.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }
}
