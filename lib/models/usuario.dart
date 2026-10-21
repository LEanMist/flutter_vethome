enum GeneroUsuario { feminino, masculino, outro, prefiroNaoInformar }

class Usuario {
  Usuario({
    this.id,
    this.fotoPerfilPath,
    required this.nome,
    required this.dataNascimento,
    required this.genero,
    required this.cpf,
    required this.telefone,
    required this.cep,
    required this.endereco,
    required this.numero,
    required this.complemento,
    required this.cidade,
    required this.email,
  });

  final String? id;
  final String? fotoPerfilPath;
  final String nome;
  final DateTime? dataNascimento;
  final GeneroUsuario? genero;
  final String cpf;
  final String telefone;
  final String cep;
  final String endereco;
  final String numero;
  final String complemento;
  final String cidade;
  final String email;

  Map<String, String> get errors {
    final validationErrors = <String, String>{};
    final cpfDigits = _digits(cpf);
    final phoneDigits = _digits(telefone);
    final cepDigits = _digits(cep);

    if (nome.trim().length < 2) {
      validationErrors['nome'] = 'Informe seu nome completo.';
    }
    if (dataNascimento == null) {
      validationErrors['dataNascimento'] = 'Informe sua data de nascimento.';
    } else if (dataNascimento!.isAfter(DateTime.now())) {
      validationErrors['dataNascimento'] =
          'A data de nascimento não pode ser futura.';
    }
    if (genero == null) {
      validationErrors['genero'] = 'Selecione uma opção.';
    }
    if (!RegExp(r'^[\d.\-\s]+$').hasMatch(cpf) || !_isValidCpf(cpfDigits)) {
      validationErrors['cpf'] = 'Informe um CPF válido.';
    }
    if (phoneDigits.length < 10 || phoneDigits.length > 11) {
      validationErrors['telefone'] = 'Informe um telefone válido com DDD.';
    }
    if (cepDigits.length != 8) {
      validationErrors['cep'] = 'Informe um CEP com 8 números.';
    }
    if (endereco.trim().isEmpty) {
      validationErrors['endereco'] = 'Informe seu endereço.';
    }
    if (numero.trim().isEmpty) {
      validationErrors['numero'] = 'Informe o número do endereço.';
    }
    if (cidade.trim().isEmpty) {
      validationErrors['cidade'] = 'Informe sua cidade.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) {
      validationErrors['email'] = 'Informe um e-mail válido.';
    }

    return Map<String, String>.unmodifiable(validationErrors);
  }

  Usuario copyWith({String? id, String? fotoPerfilPath}) {
    return Usuario(
      id: id ?? this.id,
      fotoPerfilPath: fotoPerfilPath ?? this.fotoPerfilPath,
      nome: nome,
      dataNascimento: dataNascimento,
      genero: genero,
      cpf: cpf,
      telefone: telefone,
      cep: cep,
      endereco: endereco,
      numero: numero,
      complemento: complemento,
      cidade: cidade,
      email: email,
    );
  }

  static String normalizeEmail(String value) => value.trim().toLowerCase();

  static String normalizeCpf(String value) => _digits(value);

  static String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  static bool _isValidCpf(String digits) {
    if (digits.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(digits)) {
      return false;
    }

    int calculateDigit(int length) {
      var sum = 0;
      for (var index = 0; index < length; index++) {
        sum += int.parse(digits[index]) * (length + 1 - index);
      }
      final remainder = sum % 11;
      return remainder < 2 ? 0 : 11 - remainder;
    }

    final firstDigit = calculateDigit(9);
    final secondDigit = calculateDigit(10);
    return int.parse(digits[9]) == firstDigit &&
        int.parse(digits[10]) == secondDigit;
  }
}
