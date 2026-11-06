import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets.dart';

const String _chatLocalityNotice =
    'Conversa de demonstração local. As mensagens digitadas aparecem somente '
    'nesta sessão e não são enviadas à veterinária.';

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
          padding: MediaQuery.sizeOf(context).width < VH.desktopBreakpoint
              ? const EdgeInsets.fromLTRB(12, 22, 12, 16)
              : const EdgeInsets.all(16),
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
              'Gabriela Falcão',
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

  Widget _conversation(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final mobile = viewport.width < VH.desktopBreakpoint;
    final bubbleWidth = (viewport.width - 48).clamp(0.0, 273.0).toDouble();
    final composerHeight = _composerHeight(context);
    final baseHeight = (viewport.height - (mobile ? 288 : 230))
        .clamp(420, 680)
        .toDouble();
    var cardHeight = baseHeight;
    if (mobile) {
      // O aviso cresce com a fonte do sistema. A página já permite rolagem:
      // ampliar apenas o cartão evita cortar o aviso ou o compositor em 320 px.
      final noticeText = TextPainter(
        text: const TextSpan(
          text: _chatLocalityNotice,
          style: TextStyle(fontSize: 12, height: 1.35),
        ),
        textScaler: MediaQuery.textScalerOf(context),
        textDirection: Directionality.of(context),
      )..layout(maxWidth: (viewport.width - 94).clamp(1.0, double.infinity));
      final minimum =
          noticeText.height +
          10 + // Espaço superior do cartão.
          20 + // Padding vertical do aviso.
          8 + // Espaço abaixo do aviso.
          composerHeight +
          56; // Área mínima da lista de mensagens.
      noticeText.dispose();
      if (minimum > cardHeight) cardHeight = minimum;
    }

    return Container(
      key: const ValueKey('chat-conversation-card'),
      height: cardHeight,
      decoration: insetBox(color: VH.muted),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: _localityNotice(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView(
                children: [
                  for (final (index, message)
                      in VetRepository.chatMessages.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: message.fromClient
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: SizedBox(
                          width: bubbleWidth,
                          child: Column(
                            crossAxisAlignment: message.fromClient
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: message.fromClient
                                    ? null
                                    : () => Navigator.pushNamed(
                                        context,
                                        '/sobre',
                                      ),
                                child: SizedBox(
                                  width: bubbleWidth,
                                  child: Text(
                                    message.fromClient
                                        ? VetRepository.clientName
                                        : 'Gabriela Falcão',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: message.fromClient
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: const TextStyle(
                                      fontFamily: VH.headingFontFamily,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: VetColors.brownSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: bubbleWidth,
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: message.fromClient
                                      ? VetColors.brown.withValues(alpha: .5)
                                      : VetColors.roseOverlay50,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  message.text,
                                  textAlign: message.fromClient
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: const TextStyle(
                                    fontFamily: VH.headingFontFamily,
                                    fontSize: 10,
                                    height: 1.2,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Icon(
                                Icons.done_all_rounded,
                                key: ValueKey('chat-message-check-$index'),
                                size: 12,
                                color: VetColors.brownSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _composer(context),
        ],
      ),
    );
  }

  Widget _localityNotice() => Semantics(
    container: true,
    label: _chatLocalityNotice,
    child: ExcludeSemantics(
      child: Container(
        key: const ValueKey('chat-locality-notice'),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: VH.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: VetColors.brown),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _chatLocalityNotice,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: VetColors.brown,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  double _composerHeight(BuildContext context) {
    final extraText = (MediaQuery.textScalerOf(context).scale(16) - 16).clamp(
      0.0,
      double.infinity,
    );
    return 80 + extraText * 1.5;
  }

  Widget _composer(BuildContext context) => SizedBox(
    key: const ValueKey('chat-composer'),
    height: _composerHeight(context),
    child: ColoredBox(
      color: VetColors.chatComposerBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Mensagem',
                    hintStyle: TextStyle(
                      color: VH.foreground.withValues(alpha: .5),
                      fontFamily: VH.headingFontFamily,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 50,
              height: 50,
              child: IconButton(
                tooltip: 'Enviar mensagem',
                onPressed: enviar,
                style: IconButton.styleFrom(
                  backgroundColor: VH.background.withValues(alpha: .25),
                  foregroundColor: VetColors.brownSecondary,
                  fixedSize: const Size(50, 50),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  side: const BorderSide(color: VetColors.brownSecondary),
                ),
                icon: const Icon(Icons.send_outlined, size: 25),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
