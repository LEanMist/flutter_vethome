import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets.dart';

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
        const VHHeader('Whatsapp'),
        Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final conversation = _conversation(context);
              if (constraints.maxWidth < VH.desktopBreakpoint) {
                return conversation;
              }
              return Row(
                key: const ValueKey('chat-desktop-layout'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 300, child: _vetCard(context)),
                  const SizedBox(width: 28),
                  Expanded(child: conversation),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _vetCard(BuildContext context) => Material(
    color: VH.card,
    borderRadius: BorderRadius.circular(VH.radiusCard),
    child: InkWell(
      borderRadius: BorderRadius.circular(VH.radiusCard),
      onTap: () => Navigator.pushNamed(context, '/sobre'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset(
              'assets/imagens/figma/vethomepng-2.png',
              width: 120,
              height: 120,
            ),
            const Text(
              'Gabriella Falcão',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: VH.headingFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Ver informações', textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );

  Widget _conversation(BuildContext context) => Container(
    key: const ValueKey('chat-conversation-card'),
    height: (MediaQuery.sizeOf(context).height - 230).clamp(420, 680),
    padding: const EdgeInsets.all(12),
    decoration: insetBox(color: VH.muted),
    child: Column(
      children: [
        Expanded(
          child: ListView(
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
                                    MediaQuery.sizeOf(context).width * 0.72,
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
        const SizedBox(height: 8),
        _composer(),
      ],
    ),
  );

  Widget _composer() => ColoredBox(
    color: VetColors.chatComposerBackground,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
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
          IconButton.filled(
            tooltip: 'Enviar mensagem',
            onPressed: enviar,
            style: IconButton.styleFrom(backgroundColor: VH.secondary),
            icon: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
