import 'dart:convert';

import 'package:http/http.dart' as http;

class CepResult {
  const CepResult({
    required this.street,
    required this.city,
    this.neighborhood = '',
  });

  final String street;
  final String city;
  final String neighborhood;
}

class CepService {
  const CepService();

  /// Consulta o ViaCEP. Devolve null quando o CEP não existe e lança erro
  /// quando a consulta falha (sem rede, timeout etc.).
  Future<CepResult?> lookup(String cep) async {
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;
    final response = await http
        .get(Uri.https('viacep.com.br', '/ws/$digits/json/'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw StateError('Falha na consulta de CEP');
    }
    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (json['erro'] == true || json['erro'] == 'true') return null;
    return CepResult(
      street: json['logradouro'] as String? ?? '',
      city: json['localidade'] as String? ?? '',
      neighborhood: json['bairro'] as String? ?? '',
    );
  }
}
