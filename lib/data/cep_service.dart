import 'dart:convert';
import 'package:http/http.dart' as http;

class CepResult {
  const CepResult(this.street, this.city);
  final String street, city;
}

class CepService {
  const CepService();
  Future<CepResult?> lookup(String cep) async {
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) throw const FormatException('CEP inválido');
    final response = await http
        .get(Uri.https('viacep.com.br', '/ws/$digits/json/'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw StateError('Falha na consulta de CEP');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['erro'] == true || json['erro'] == 'true') return null;
    return CepResult(
      json['logradouro'] as String? ?? '',
      json['localidade'] as String? ?? '',
    );
  }
}
