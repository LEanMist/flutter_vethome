import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;

import '../../data/gabriela_demo_chat.dart';
import '../../data/gabriela_profile_repository.dart';
import '../../models/vet_models.dart';
import '../../theme/vet_colors.dart';
import '../../widgets/pets/pets_theme.dart';

class GabrielaMessagesTab extends StatefulWidget {
  const GabrielaMessagesTab({
    super.key,
    this.conversations = gabrielaDemoConversations,
  });

  final List<GabrielaConversation> conversations;

  @override
  State<GabrielaMessagesTab> createState() => _GabrielaMessagesTabState();
}

class _GabrielaMessagesTabState extends State<GabrielaMessagesTab> {
  GabrielaConversation? _selectedContact;
  final _composer = TextEditingController();
  final Map<String, String> _drafts = {};
  final Map<String, List<ChatMessage>> _localMessages = {};

  static const _contactFont = 'MontserratAlternates';

  List<ChatMessage> _messagesFor(GabrielaConversation contact) => [
    ...contact.messages,
    ...?_localMessages[contact.id],
  ];

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _send() {
    final text = _composer.text.trim();
    final contact = _selectedContact;
    if (text.isEmpty || contact == null) return;
    setState(() {
      _localMessages
          .putIfAbsent(contact.id, () => [])
          .add(ChatMessage(text: text, fromClient: false));
      _drafts.remove(contact.id);
      _composer.clear();
    });
  }

  void _openContact(GabrielaConversation contact) {
    setState(() {
      _selectedContact = contact;
      _composer.text = _drafts[contact.id] ?? '';
    });
  }

  void _closeContact() {
    final contact = _selectedContact;
    if (contact == null) return;
    setState(() {
      _drafts[contact.id] = _composer.text;
      _composer.clear();
      _selectedContact = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = PetsTheme.scaleOf(context);
    final contact = _selectedContact;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Column(
      children: [
        _header(s, contact, keyboardOpen),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              12 * s,
              (keyboardOpen
                      ? 4
                      : contact == null
                      ? 32
                      : 22) *
                  s,
              12 * s,
              (keyboardOpen ? 4 : 20) * s,
            ),
            child: Material(
              color: Color.alphaBlend(
                VetColors.rose.withValues(alpha: .25),
                VetColors.pink,
              ),
              borderRadius: BorderRadius.circular(25 * s),
              clipBehavior: Clip.antiAlias,
              child: contact == null
                  ? _conversationList(s)
                  : _conversation(s, contact),
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(double s, GabrielaConversation? contact, bool keyboardOpen) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: (keyboardOpen ? 72 : 125) * s),
      decoration: BoxDecoration(
        color: VetColors.rose,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30 * s)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52 * s,
            child: contact == null
                ? null
                : IconButton(
                    tooltip: 'Voltar para as conversas',
                    onPressed: _closeContact,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10 * s),
              child: Column(
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Chat',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: PetsTheme.fontComfortaa,
                        fontWeight: FontWeight.w700,
                        fontSize: 30 * s,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: VetColors.pink,
                      borderRadius: BorderRadius.circular(10 * s),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Text(
                        'Demonstração local · mensagens só nesta sessão',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11 * s,
                          color: VetColors.brown,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 52 * s),
        ],
      ),
    );
  }

  Widget _conversationList(double s) {
    final contacts = widget.conversations;
    if (contacts.isEmpty) {
      return const Center(child: Text('Nenhuma conversa disponível.'));
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(19 * s, 25 * s, 19 * s, 20 * s),
      itemCount: contacts.length,
      separatorBuilder: (_, _) => SizedBox(height: 15 * s),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final unread = contact.demoUnread;
        final messages = _messagesFor(contact);
        final radius = BorderRadius.circular(32 * s);
        return DecoratedBox(
          decoration: inset.BoxDecoration(
            color: VetColors.rose.withValues(alpha: .5),
            borderRadius: radius,
            boxShadow: const [
              inset.BoxShadow(
                color: Color(0x40000000),
                offset: Offset(2, 2),
                blurRadius: 2,
                inset: true,
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: () => _openContact(contact),
              child: Row(
                children: [
                  _ContactAvatar(size: 61 * s),
                  SizedBox(width: 15 * s),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: _contactFont,
                              fontSize: 20 * s,
                              fontWeight: FontWeight.w500,
                              color: VetColors.brown,
                            ),
                          ),
                          Text(
                            messages.lastOrNull?.text ?? 'Nenhuma mensagem',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: PetsTheme.fontComfortaa,
                              fontSize: 11 * s,
                              color: VetColors.brown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (unread != null)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 28 * s),
                        padding: EdgeInsets.all(5 * s),
                        decoration: const BoxDecoration(
                          color: VetColors.pink,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$unread',
                          semanticsLabel: '$unread não lidas no exemplo',
                          style: TextStyle(
                            color: VetColors.brown,
                            fontFamily: _contactFont,
                            fontSize: 12 * s,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 12 * s),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _conversation(double s, GabrielaConversation contact) {
    final messages = _messagesFor(contact);
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text('Nenhuma mensagem nesta conversa.'))
              : ListView.builder(
                  key: ValueKey(contact.id),
                  reverse: true,
                  padding: EdgeInsets.all(10 * s),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final received = message.fromClient;
                    final sender = received
                        ? contact.name
                        : GabrielaProfileRepository.name;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12 * s),
                      child: Align(
                        alignment: received
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: .79,
                          child: Column(
                            crossAxisAlignment: received
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              Text(
                                sender,
                                textAlign: received
                                    ? TextAlign.left
                                    : TextAlign.right,
                                style: TextStyle(
                                  fontFamily: PetsTheme.fontComfortaa,
                                  fontSize: 19 * s,
                                  fontWeight: FontWeight.w700,
                                  color: VetColors.brown,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 13 * s,
                                  vertical: 13 * s,
                                ),
                                decoration: BoxDecoration(
                                  color: received
                                      ? VetColors.rose.withValues(alpha: .5)
                                      : VetColors.brown,
                                  borderRadius: BorderRadius.circular(25 * s),
                                ),
                                child: Text(
                                  message.text,
                                  textAlign: received
                                      ? TextAlign.left
                                      : TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: PetsTheme.fontComfortaa,
                                    fontSize: 13 * s,
                                    color: received
                                        ? VetColors.brown
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(17 * s, 8 * s, 17 * s, 10 * s),
          child: Row(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28 * s),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        VetColors.pink,
                        VetColors.rose.withValues(alpha: .36),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(2, 2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _composer,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: TextStyle(
                      fontFamily: _contactFont,
                      fontSize: 15 * s,
                      color: VetColors.brown,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Mensagem',
                      hintStyle: const TextStyle(color: VetColors.brown),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16 * s,
                        vertical: 12 * s,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(28)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12 * s),
              IconButton.filled(
                tooltip: 'Enviar mensagem',
                onPressed: _send,
                style: IconButton.styleFrom(
                  minimumSize: Size.square(48 * s),
                  backgroundColor: VetColors.brown,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.send_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: VetColors.pink,
    ),
    child: Image.asset(
      'assets/imagens/figma/frame-53-3.png',
      width: size,
      height: size,
      excludeFromSemantics: true,
    ),
  );
}
