import 'package:flutter/material.dart';

import '../../theme/vet_colors.dart';
import '../../widgets/pets/pets_theme.dart';

class GabrielaMessagesTab extends StatefulWidget {
  const GabrielaMessagesTab({super.key});

  @override
  State<GabrielaMessagesTab> createState() => _GabrielaMessagesTabState();
}

class _GabrielaMessagesTabState extends State<GabrielaMessagesTab> {
  String? _selectedContact;
  final _composer = TextEditingController();
  final Map<String, List<_Message>> _messages = {
    'Nicolly': [
      const _Message('Oi, doutora! Como está o Rambo?', true),
      const _Message('Está bem e já está se recuperando. 😊', false),
      const _Message('Que bom! Obrigada pelo retorno.', true),
    ],
    'Caio': [const _Message('A consulta ficou confirmada para amanhã.', true)],
    'Kelvin': [const _Message('Enviei os exames por aqui.', true)],
    'Estevão': [const _Message('Obrigado pela orientação, doutora.', true)],
    'Judite': [const _Message('Podemos remarcar para sexta-feira?', true)],
    'Rambo': [const _Message('Tudo certo com o retorno de hoje.', true)],
  };

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
      _messages.putIfAbsent(contact, () => []).add(_Message(text, false));
      _composer.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = PetsTheme.scaleOf(context);
    final contact = _selectedContact;
    return Column(
      children: [
        _header(s, contact),
        Expanded(
          child: contact == null
              ? _conversationList(s)
              : _conversation(s, contact),
        ),
      ],
    );
  }

  Widget _header(double s, String? contact) => Container(
    width: double.infinity,
    height: 90 * s,
    padding: EdgeInsets.only(top: 12 * s),
    decoration: BoxDecoration(
      color: VetColors.rose,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28 * s)),
    ),
    child: Row(
      children: [
        if (contact != null)
          IconButton(
            tooltip: 'Voltar para as conversas',
            onPressed: () => setState(() => _selectedContact = null),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          )
        else
          SizedBox(width: 52 * s),
        Expanded(
          child: Text(
            contact ?? 'WhatsApp',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontFamily: PetsTheme.fontComfortaa,
              fontWeight: FontWeight.w700,
              fontSize: 25 * s,
            ),
          ),
        ),
        SizedBox(width: 52 * s),
      ],
    ),
  );

  Widget _conversationList(double s) {
    const contacts = [
      ('Nicolly', 'Oi, doutora! Como está o Rambo?', '15'),
      ('Caio', 'A consulta ficou confirmada para amanhã.', '2'),
      ('Kelvin', 'Enviei os exames por aqui.', '4'),
      ('Estevão', 'Obrigado pela orientação, doutora.', ''),
      ('Judite', 'Podemos remarcar para sexta-feira?', ''),
      ('Rambo', 'Tudo certo com o retorno de hoje.', ''),
    ];
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(18 * s, 16 * s, 18 * s, 12 * s),
      itemCount: contacts.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: VetColors.rose.withValues(alpha: .38)),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return InkWell(
          onTap: () => setState(() => _selectedContact = contact.$1),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10 * s),
            child: Row(
              children: [
                _ContactAvatar(name: contact.$1, size: 52 * s),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.$1,
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w700,
                          color: VetColors.brown,
                        ),
                      ),
                      SizedBox(height: 5 * s),
                      Text(
                        contact.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12 * s,
                          color: VetColors.brown.withValues(alpha: .78),
                        ),
                      ),
                    ],
                  ),
                ),
                if (contact.$3.isNotEmpty)
                  Container(
                    width: 25 * s,
                    height: 25 * s,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: VetColors.rose,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      contact.$3,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _conversation(double s, String contact) {
    final messages = _messages[contact] ?? const <_Message>[];
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16 * s),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return Align(
                alignment: message.fromContact
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 285 * s),
                  margin: EdgeInsets.only(bottom: 10 * s),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14 * s,
                    vertical: 11 * s,
                  ),
                  decoration: BoxDecoration(
                    color: message.fromContact
                        ? Colors.white.withValues(alpha: .78)
                        : VetColors.chatComposerBackground,
                    borderRadius: BorderRadius.circular(17 * s),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(fontSize: 14 * s, color: VetColors.brown),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12 * s, 7 * s, 12 * s, 12 * s),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _composer,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Mensagem',
                    filled: true,
                    fillColor: VetColors.chatComposerBackground,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16 * s,
                      vertical: 12 * s,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24 * s),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8 * s),
              IconButton.filled(
                tooltip: 'Enviar mensagem',
                onPressed: _send,
                style: IconButton.styleFrom(
                  backgroundColor: VetColors.rose,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Message {
  const _Message(this.text, this.fromContact);
  final String text;
  final bool fromContact;
}

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({required this.name, required this.size});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: VetColors.rose.withValues(alpha: .6),
      border: Border.all(color: VetColors.rose, width: 1.5),
    ),
    child: Text(
      name.substring(0, 1).toUpperCase(),
      style: TextStyle(
        fontSize: size * .42,
        color: VetColors.brown,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
