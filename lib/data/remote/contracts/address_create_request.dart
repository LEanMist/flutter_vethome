import 'contract_values.dart';

/// Payload provisório observado em `origin/nicolly` para
/// `POST /cliente/endereco`.
/// O campo bairro e o vínculo por CPF continuam pendentes de confirmação.
class AddressCreateRequest {
  const AddressCreateRequest({
    this.cep,
    this.logradouro,
    this.complemento,
    this.bairro,
    this.cidade,
    this.numero,
    this.cpfCliente,
  });

  final String? cep;
  final String? logradouro;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? numero;
  final String? cpfCliente;

  Map<String, dynamic> toJson() => {
    'cep': observedDigits(cep),
    'logradouro': logradouro,
    'complemento': complemento,
    'bairro': bairro,
    'cidade': cidade,
    'numero': numero,
    'cpfCliente': observedDigits(cpfCliente),
  };
}
