import 'package:flutter/material.dart';

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
            Text('Data de nascimento não informada', style: TextStyle(fontSize: 13)),
          ],
        ),
        VHMenu(['Mudar Foto de Perfil', 'Mudar Nome de Perfil', 'Mudar Data de Nascimento']),
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
              Text('Sobre Mim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text(
                'Sou veterinária há mais de 8 anos, apaixonada por cães e gatos. Atendo em domicílio para que seu pet fique tranquilo no lar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text('CONTATO:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Telefone não informado', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
              SizedBox(height: 8),
              Text('Email não informado', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class Msg {
  const Msg(this.me, this.text);

  final bool me;
  final String text;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ctrl = TextEditingController();
  final msgs = <Msg>[
    const Msg(false, 'Olá! Como está seu pet depois da última consulta?'),
    const Msg(true, 'Está ótimo, comendo bem e brincando.'),
    const Msg(false, 'Que bom! Lembre-se de agendar o retorno.'),
  ];

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void enviar() {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => msgs.add(Msg(true, text)));
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
              for (final message in msgs)
                Align(
                  alignment: message.me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: message.me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: message.me ? null : () => Navigator.pushNamed(context, '/sobre'),
                        child: Text(
                          message.me ? 'Você' : 'Gabriella Falcão',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
                        margin: const EdgeInsets.only(top: 4, bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.me ? VH.secondary : VH.card,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: VH.raise,
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(color: message.me ? VH.onSecondary : VH.foreground),
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
  late int dia = DateTime.now().day;

  static const nomes = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
  static const consultas = [
    ['10:00', '11:00', 'Hemograma'],
    ['16:00', '17:00', 'Creatinina'],
    ['13:00', '14:00', 'Urina'],
  ];
  static const meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final firstOffset = monthStart.weekday % 7;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

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
                Text(
                  '${meses[now.month - 1]} ${now.year}',
                  style: const TextStyle(color: VH.onSecondary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final weekday in ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'])
                      Center(
                        child: Text(
                          weekday,
                          style: const TextStyle(color: VH.onSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    for (var i = 0; i < firstOffset; i++) const SizedBox(),
                    for (var date = 1; date <= daysInMonth; date++)
                      GestureDetector(
                        onTap: () => setState(() => dia = date),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: date == dia ? VH.background : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              '$date',
                              style: TextStyle(
                                fontSize: 11,
                                color: date == dia ? VH.foreground : VH.onSecondary,
                              ),
                            ),
                          ),
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
              '$dia - ${nomes[DateTime(now.year, now.month, dia).weekday % 7]}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            children: [
              for (final consulta in consultas)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Text('${consulta[0]}\n${consulta[1]}', style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: VH.secondary,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: VH.raise,
                          ),
                          child: Text(
                            consulta[2],
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: VH.onSecondary, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
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
          const ['Tema do Aplicativo', 'Meus Endereços', 'Suporte', 'Histórico', 'Sair'],
          onTap: (index) {
            if (index == 4) {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            }
          },
        ),
      ],
    );
  }
}