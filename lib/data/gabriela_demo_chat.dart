import '../models/vet_models.dart';

class GabrielaConversation {
  const GabrielaConversation({
    required this.id,
    required this.name,
    required this.messages,
    this.demoUnread,
  });

  final String id;
  final String name;
  final List<ChatMessage> messages;
  final int? demoUnread;
}

/// Conversas fictícias para explorar a interface local da veterinária.
const gabrielaDemoConversations = [
  GabrielaConversation(
    id: 'demo-nicolly',
    name: 'Nicolly',
    demoUnread: 15,
    messages: [
      ChatMessage(text: 'Oi, doutora! Como está o Rambo?', fromClient: true),
      ChatMessage(
        text: 'Está bem e já está se recuperando.',
        fromClient: false,
      ),
      ChatMessage(text: 'Que bom! Obrigada pelo retorno.', fromClient: true),
    ],
  ),
  GabrielaConversation(
    id: 'demo-caio',
    name: 'Caio',
    demoUnread: 2,
    messages: [
      ChatMessage(
        text: 'A consulta ficou confirmada para amanhã.',
        fromClient: true,
      ),
    ],
  ),
  GabrielaConversation(
    id: 'demo-kelvin',
    name: 'Kelvin',
    demoUnread: 4,
    messages: [
      ChatMessage(text: 'Enviei os exames por aqui.', fromClient: true),
    ],
  ),
  GabrielaConversation(
    id: 'demo-estevao',
    name: 'Estevão',
    messages: [
      ChatMessage(text: 'Obrigado pela orientação, doutora.', fromClient: true),
    ],
  ),
  GabrielaConversation(
    id: 'demo-judite',
    name: 'Judite',
    messages: [
      ChatMessage(text: 'Podemos remarcar para sexta-feira?', fromClient: true),
    ],
  ),
  GabrielaConversation(
    id: 'demo-rambo',
    name: 'Rambo',
    messages: [
      ChatMessage(text: 'Tudo certo com o retorno de hoje.', fromClient: true),
    ],
  ),
];
