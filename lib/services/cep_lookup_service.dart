import 'dart:convert';
import 'package:http/http.dart' as http;

class EnderecoCep {
  const EnderecoCep({required this.logradouro, required this.cidade});

  final String logradouro;
  final String cidade;
}

abstract interface class CepLookupService {
  Future<EnderecoCep?> consultar(String cep);
}

class ViaCepLookupService implements CepLookupService {
  ViaCepLookupService({Future<http.Response> Function(Uri uri)? get})
    : _get = get ?? _getResponse;

  final Future<http.Response> Function(Uri uri) _get;

  static Future<http.Response> _getResponse(Uri uri) => http.get(uri);

  @override
  Future<EnderecoCep?> consultar(String cep) async {
    final cepNumerico = cep.replaceAll(RegExp(r'\D'), '');
    if (cepNumerico.length != 8) return null;

    final uri = Uri.https('viacep.com.br', '/ws/$cepNumerico/json/');
    final response = await _get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw const FormatException('Não foi possível consultar o CEP.');
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Resposta inválida do serviço de CEP.');
    }
    if (payload['erro'] == true) return null;

    final logradouro = (payload['logradouro'] as String? ?? '').trim();
    final cidade = (payload['localidade'] as String? ?? '').trim();
    if (logradouro.isEmpty && cidade.isEmpty) return null;

    return EnderecoCep(logradouro: logradouro, cidade: cidade);
  }
}
