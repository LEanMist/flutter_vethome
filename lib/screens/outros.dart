import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../data/vet_repository.dart';
import '../theme.dart';
import '../widgets.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VHPage(
      tab: '/perfil',
      children: const [
        VHHeader('Perfil'),
        VHBadge('user-badge', 'Minha conta'),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cake, size: 16),
            SizedBox(width: 4),
            Text(
              'Data de nascimento não informada',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        VHMenu([
          'Mudar Foto de Perfil',
          'Mudar Nome de Perfil',
          'Mudar Data de Nascimento',
        ]),
      ],
    );
  }
}

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VHPage(
      tab: '/chat',
      children: [
        const VHHeader('Sobre a veterinária'),
        const VHBadge('vet-badge', 'Gabriella'),
        Container(
          margin: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          padding: const EdgeInsets.all(20),
          decoration: insetBox(color: VH.muted),
          child: const Column(
            children: [
              Text(
                'Sobre Mim',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Sou veterinária há mais de 8 anos, apaixonada por cães e gatos. Atendo em domicílio para que seu pet fique tranquilo no lar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text('CONTATO:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'Telefone não informado',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 8),
              Text(
                'Email não informado',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
      children: [
        const VHHeader('Whatsapp', face: 'ω'),
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
                  child: Column(
                    crossAxisAlignment: message.fromClient
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: message.fromClient
                            ? null
                            : () => Navigator.pushNamed(context, '/sobre'),
                        child: Text(
                          message.fromClient
                              ? VetRepository.clientName
                              : 'Gabriella Falcão',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                        ),
                        margin: const EdgeInsets.only(top: 4, bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.fromClient ? VH.secondary : VH.card,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: VH.raise,
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.fromClient
                                ? VH.onSecondary
                                : VH.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: insetBox(color: VH.card, radius: 999),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: ctrl,
                    onSubmitted: (_) => enviar(),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Mensagem',
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
      ],
    );
  }
}

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _selecionado = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

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
    final firstOffset = DateTime(_mes.year, _mes.month, 1).weekday % 7;
    final daysInMonth = DateTime(_mes.year, _mes.month + 1, 0).day;
    final consultasDoDia = [
      for (final pet in VetRepository.pets)
        for (final agendamento in VetRepository.agendamentos(pet.name))
          if (_sameDay(agendamento.data, _selecionado))
            (pet: pet, agendamento: agendamento),
    ]..sort((a, b) => a.agendamento.data.compareTo(b.agendamento.data));

    return VHPage(
      tab: '/agenda',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: VH.secondary,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: VH.raise,
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
                        color: VH.onSecondary,
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
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 7,
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
                            color: VH.onSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    for (var i = 0; i < firstOffset; i++) const SizedBox(),
                    for (var date = 1; date <= daysInMonth; date++)
                      GestureDetector(
                        onTap: () => setState(
                          () => _selecionado = DateTime(
                            _mes.year,
                            _mes.month,
                            date,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    date == _selecionado.day &&
                                        _mes.year == _selecionado.year &&
                                        _mes.month == _selecionado.month
                                    ? VH.background
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  '$date',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        date == _selecionado.day &&
                                            _mes.year == _selecionado.year &&
                                            _mes.month == _selecionado.month
                                        ? VH.foreground
                                        : VH.onSecondary,
                                  ),
                                ),
                              ),
                            ),
                            if (_hasAppointment(
                              DateTime(_mes.year, _mes.month, date),
                            ))
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
        Container(
          margin: const EdgeInsets.only(top: 16),
          alignment: Alignment.center,
          child: Container(
            width: 250,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: VH.accent.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: VH.secondary, width: 3),
            ),
            child: Text(
              '${_selecionado.day} - '
              '${_weekdayNames[_selecionado.weekday % 7]}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            children: [
              if (consultasDoDia.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Text('Não há consultas neste dia.'),
                ),
              for (final item in consultasDoDia)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: VH.card,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: VH.raise,
                    ),
                    child: Row(
                      children: [
                        Text(
                          fmtHora(item.agendamento.data),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 14),
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
                                '${item.pet.name} · ${item.agendamento.local}',
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
        const SizedBox(height: 8),
        Center(
          child: PillButton(
            label: 'Nova Consulta',
            onTap: () => Navigator.pushNamed(context, '/escolhaPet'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  static const _weekdayNames = [
    'Domingo',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
  ];

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _hasAppointment(DateTime date) => VetRepository.pets.any(
    (pet) => VetRepository.agendamentos(
      pet.name,
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
        const VHHeader('Configurações', face: '^'),
        VHMenu(
          const [
            'Tema do Aplicativo',
            'Meus Endereços',
            'Suporte',
            'Histórico',
            'Sair',
          ],
          onTap: (index) {
            if (index == 4) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            }
          },
        ),
      ],
    );
  }
}
