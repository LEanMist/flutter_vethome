import 'contract_values.dart';

/// Payload provisório observado em `origin/nicolly` para
/// `POST /cliente/pet`.
/// Sexo, castração, foto, tipos definitivos e resposta não foram confirmados.
class PetCreateRequest {
  const PetCreateRequest({
    this.nome,
    this.dataNasc,
    this.especie,
    this.raca,
    this.peso,
    this.convenio,
    this.cpfCliente,
  });

  final String? nome;
  final String? dataNasc;
  final String? especie;
  final String? raca;
  final String? peso;
  final String? convenio;
  final String? cpfCliente;

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'dataNasc': observedDate(dataNasc),
    'especie': especie,
    'raca': raca ?? '',
    'peso': peso,
    'convenio': convenio,
    'cpfCliente': observedDigits(cpfCliente),
  };
}
