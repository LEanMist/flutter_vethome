import 'contract_values.dart';

/// Payload provisório observado em `origin/nicolly` para `POST /cliente`.
/// Obrigatoriedade, validações e resposta ainda não foram confirmadas.
class ClientCreateRequest {
  const ClientCreateRequest({
    this.nome,
    this.dataNascimento,
    this.cpf,
    this.telefone,
    this.email,
    this.senha,
  });

  final String? nome;
  final String? dataNascimento;
  final String? cpf;
  final String? telefone;
  final String? email;
  final String? senha;

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'dataNascimento': observedDate(dataNascimento),
    'cpf': observedDigits(cpf),
    'telefone': observedDigits(telefone),
    'email': email,
    'senha': senha,
  };
}
