import 'dart:typed_data';

import '../service/cliente_service.dart';

/// Dados do cliente da sessão atual: login no backend ou perfil local de
/// demonstração. É a fonte única; o [VetRepository] apenas repassa para cá.
class Session {
  Session._();

  static const defaultClientName = 'Liminha';
  static final defaultClientBirthDate = DateTime(2007, 2, 5);

  static String clientName = defaultClientName;
  static String clientCpf = '';
  static DateTime clientBirthDate = defaultClientBirthDate;
  static String clientEmail = '';
  static String clientAddress = '';
  static String clientPhone = '';
  static String clientGender = '';
  static String clientGenderCustom = '';
  static String? clientPhotoBase64;
  static String? clientPhotoPath;
  // No Web, o caminho do picker é temporário; conserva a foto nesta sessão.
  static Uint8List? clientPhotoBytes;

  static bool get isLoggedIn => clientCpf.trim().isNotEmpty;

  /// Só valida o formato dos campos da tela de login.
  /// Quem confere a senha de verdade é o backend (veja [entrar]).
  static bool credenciaisValidas(String email, String password) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim()) &&
      password.trim().length >= 6;

  /// Login no backend: preenche os dados do cliente.
  static Future<void> entrar(String email, String senha) async {
    final dados = await ClienteService.login(email, senha);
    clientName = (dados['nome'] ?? clientName).toString();
    clientCpf = (dados['cpf'] ?? '').toString();
    clientEmail = (dados['email'] ?? email).toString();
    clientPhone = (dados['telefone'] ?? '').toString();
    final nasc = dados['dataNascimento']?.toString();
    if (nasc != null) {
      clientBirthDate = DateTime.tryParse(nasc) ?? clientBirthDate;
    }
    clientAddress = '';
    clientPhotoPath = null;
  }

  /// Volta o perfil local ao padrão de demonstração.
  /// Não mexe no CPF, que pertence ao login.
  static void resetLocalClient() {
    clientName = defaultClientName;
    clientBirthDate = defaultClientBirthDate;
    clientAddress = '';
    clientPhone = '';
    clientEmail = '';
    clientGender = '';
    clientGenderCustom = '';
    clientPhotoBase64 = null;
    clientPhotoPath = null;
    clientPhotoBytes = null;
  }

  /// Esta demonstração mantém um único perfil local por instalação.
  static bool hasDifferentLocalClientEmail(String? email) {
    final current = clientEmail.trim().toLowerCase();
    final incoming = email?.trim().toLowerCase() ?? '';
    return current.isNotEmpty && incoming.isNotEmpty && current != incoming;
  }

  /// Detecta uma tentativa de trocar o perfil sem fornecer o e-mail salvo.
  /// Atualizações parciais sem nome continuam permitidas para o perfil atual.
  static bool hasLocalClientIdentityConflict({String? email, String? name}) {
    if (hasDifferentLocalClientEmail(email)) return true;

    final currentEmail = clientEmail.trim();
    final incomingEmail = email?.trim() ?? '';
    final incomingName = name?.trim() ?? '';
    return currentEmail.isNotEmpty &&
        incomingEmail.isEmpty &&
        incomingName.isNotEmpty &&
        incomingName.toLowerCase() != clientName.trim().toLowerCase();
  }
}
