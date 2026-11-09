import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'utils/utils.dart';

class EnderecoService {
  static String get baseUrl => ApiConfig.baseUrl;

static Future<void> cadastrarEndereco(Map<String, String?> dados) async {
    final body = {
      'cep': Utils.limparCep(dados['cep']),
      'logradouro': dados['logradouro'],
      'complemento': dados['complemento'],
      'bairro': dados['bairro'],
      'cidade': dados['cidade'],
      'numero': dados['numero'],
      'cpfCliente': Utils.limparCpf(dados['cpfCliente']),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/endereco'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao cadastrar endereço (${response.statusCode}): ${response.body}',
      );
    }
  }

}