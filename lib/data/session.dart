import '../service/cliente_service.dart';

/// Cliente logado: dados do perfil e login/cadastro.
/// Não conhece pets nem consultas.
class Session {
  Session._();

  static String clientName = 'Liminha';
  static String clientCpf = ''; // vazio = ninguém logado (modo demonstração)
  static DateTime clientBirthDate = DateTime(2007, 2, 5);
  static String clientEmail = '';
  static String clientAddress = '';
  static String clientPhone = '';
  static String? clientPhotoPath;

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

  /// Guarda os dados do cliente recém-cadastrado.
  static void registerClient(Map<String, String> values) {
    clientName = values['Nome Completo']?.trim().isNotEmpty == true
        ? values['Nome Completo']!.trim()
        : clientName;
    clientCpf = values['CPF']?.trim().isNotEmpty == true
        ? values['CPF']!.replaceAll(RegExp(r'[^0-9]'), '')
        : clientCpf;
    clientEmail = values['E-mail']?.trim() ?? clientEmail;
    clientPhone = values['Telefone/Celular']?.trim() ?? clientPhone;
    clientAddress = [
      values['Endereço'],
      values['Número'],
      values['Complemento'],
      values['Cidade'],
      values['CEP'],
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');
    final birth = values['Data de Nascimento'];
    if (birth != null) clientBirthDate = _parseDate(birth) ?? clientBirthDate;
  }

  static void updateClient({
    String? name,
    DateTime? birthDate,
    String? address,
    String? phone,
  }) {
    if (name != null) clientName = name;
    if (birthDate != null) clientBirthDate = birthDate;
    if (address != null) clientAddress = address;
    if (phone != null) clientPhone = phone;
  }

  static DateTime? _parseDate(String value) {
    final parts = value.trim().split(RegExp(r'[/.-]'));
    if (parts.length != 3) return DateTime.tryParse(value);
    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    final c = int.tryParse(parts[2]);
    if (a == null || b == null || c == null) return null;
    final yearFirst = a > 31;
    final date = yearFirst ? DateTime(a, b, c) : DateTime(c, b, a);
    final expectedDay = yearFirst ? c : a;
    if (date.year < 1900 ||
        date.month != b ||
        date.day != expectedDay ||
        date.isAfter(DateTime.now())) {
      return null;
    }
    return date;
  }
}
