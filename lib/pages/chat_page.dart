import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../theme.dart';
<<<<<<< HEAD
=======
import '../theme/vet_colors.dart';
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
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
<<<<<<< HEAD
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
=======
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
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
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
<<<<<<< HEAD
                                  : () => Navigator.pushNamed(context, '/sobre'),
=======
                                  : () =>
                                        Navigator.pushNamed(context, '/sobre'),
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
                              child: Text(
                                message.fromClient
                                    ? VetRepository.clientName
                                    : 'Gabriella Falcão',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
<<<<<<< HEAD
=======
                                  color: VetColors.brownSecondary,
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
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
<<<<<<< HEAD
                                    ? VH.secondary
=======
                                    ? VH.foreground.withValues(alpha: .5)
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
                                    : VH.card,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: VH.raise,
                              ),
                              child: Text(
                                message.text,
<<<<<<< HEAD
                                style: TextStyle(
                                  color: message.fromClient
                                      ? VH.onSecondary
                                      : VH.foreground,
=======
                                style: const TextStyle(
                                  color: VH.onSecondary,
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
                                ),
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
<<<<<<< HEAD
}
=======
}
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
