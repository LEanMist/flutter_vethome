import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets.dart';

const String _chatLocalityNotice =
    'Conversa de demonstração local. As mensagens digitadas aparecem somente '
    'nesta sessão e não são enviadas à veterinária.';
const String _chatVeterinarianName = 'Gabriela Falcão';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  Future<void> _openConversation() async {
    await Navigator.pushNamed<void>(context, '/chat/conversa');
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final messages = VetRepository.chatMessages;
    final preview = messages.isEmpty
        ? 'Nenhuma mensagem nesta conversa.'
        : messages.last.text;

    return VHPage(
      tab: '/chat',
      showPetsTab: true,
      children: [
        const VHHeader('Whatsapp'),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 32, 12, 31),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SizedBox(
                width: double.infinity,
                height: 536,
                child: Container(
                  key: const ValueKey('chat-list-card'),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: VetColors.roseOverlay25,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 7,
                        top: 8,
                        right: 7,
                        bottom: 58,
                        child: Container(
                          key: const ValueKey('chat-list-viewport'),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(9, 14, 9, 12),
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: SizedBox(
                                  width: 328,
                                  child: _ChatConversationTile(
                                    name: _chatVeterinarianName,
                                    preview: preview,
                                    onTap: _openConversation,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -10,
                        height: 80,
                        child: ExcludeSemantics(
                          child: CustomPaint(
                            key: const ValueKey('chat-list-footer'),
                            painter: _ChatListFooterPainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatConversationTile extends StatelessWidget {
  const _ChatConversationTile({
    required this.name,
    required this.preview,
    required this.onTap,
  });

  final String name;
  final String preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Conversa com $name. Última mensagem: $preview',
    hint: 'Abre a conversa local.',
    onTap: onTap,
    child: ExcludeSemantics(
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: insetBox(color: VetColors.roseOverlay50, radius: 100),
          child: InkWell(
            key: const ValueKey('chat-conversation-entry'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 61,
              child: Row(
                children: [
                  Container(
                    width: 61,
                    height: 61,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: VetColors.pink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: VetColors.brownOnRose,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: VH.bodyFontFamily,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: VetColors.brownOnRose,
                            ),
                          ),
                          Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: VH.headingFontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: VetColors.brownOnRose,
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
        ),
      ),
    ),
  );
}

class _ChatListFooterPainter extends CustomPainter {
  const _ChatListFooterPainter();

  static const _background = Color(0xFFEBBEC0);
  static const _chevron = Color(0xFF886252);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _background);
    final stroke = Paint()
      ..color = _chevron
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final centerX = size.width / 2;
    final firstChevron = Path()
      ..moveTo(centerX - 4, 36)
      ..lineTo(centerX + 4, 44)
      ..lineTo(centerX + 12, 36);
    final secondChevron = Path()
      ..moveTo(centerX - 12, 36)
      ..lineTo(centerX - 4, 44)
      ..lineTo(centerX + 4, 36);
    canvas
      ..drawPath(firstChevron, stroke)
      ..drawPath(secondChevron, stroke);
  }

  @override
  bool shouldRepaint(covariant _ChatListFooterPainter oldDelegate) => false;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ctrl = TextEditingController();
  final _messagesScrollController = ScrollController();

  @override
  void dispose() {
    ctrl.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  void enviar() {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => VetRepository.sendChatMessage(text));
    ctrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollUntilAtEnd();
    });
  }

  Future<void> _scrollUntilAtEnd() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      if (!mounted || !_messagesScrollController.hasClients) return;
      final position = _messagesScrollController.position;
      await _messagesScrollController.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
      if (!mounted || !_messagesScrollController.hasClients) return;
      final updatedPosition = _messagesScrollController.position;
      if (updatedPosition.pixels >= updatedPosition.maxScrollExtent - 1) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VHPage(
      tab: '/chat',
      showPetsTab: true,
      children: [
        const VHHeader('Whatsapp'),
        Padding(
          padding: MediaQuery.sizeOf(context).width < VH.desktopBreakpoint
              ? const EdgeInsets.fromLTRB(12, 0, 12, 16)
              : const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final conversation = _conversation(context);
              final conversationWithNotice = Column(
                mainAxisSize: MainAxisSize.min,
                children: [_localityNotice(), conversation],
              );
              if (constraints.maxWidth < VH.desktopBreakpoint) {
                return conversationWithNotice;
              }
              return Row(
                key: const ValueKey('chat-desktop-layout'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 300, child: _vetCard(context)),
                  const SizedBox(width: 28),
                  Expanded(child: conversationWithNotice),
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
              _chatVeterinarianName,
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
    final cardHeight = (viewport.height - (mobile ? 288 : 230))
        .clamp(420, 680)
        .toDouble();

    return Container(
      key: const ValueKey('chat-conversation-card'),
      height: cardHeight,
      decoration: insetBox(color: VH.muted),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView(
                controller: _messagesScrollController,
                padding: const EdgeInsets.only(top: 25),
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
                              Semantics(
                                container: true,
                                explicitChildNodes: true,
                                button: !message.fromClient,
                                label: message.fromClient
                                    ? VetRepository.clientName
                                    : 'Ver informações sobre $_chatVeterinarianName',
                                onTap: message.fromClient
                                    ? null
                                    : () => Navigator.pushNamed(
                                        context,
                                        '/sobre',
                                      ),
                                child: ExcludeSemantics(
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(
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
                                              : _chatVeterinarianName,
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
                                  ),
                                ),
                              ),
                              Container(
                                width: bubbleWidth,
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: VetColors.roseOverlay50,
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
                                    color: VetColors.chatMessageText,
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
        margin: const EdgeInsets.only(bottom: 2),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 14, color: VetColors.brown),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                'Demonstração local: mensagens não são enviadas à veterinária.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  height: 1,
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
                      color: VetColors.brownOnRose,
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
