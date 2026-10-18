import 'dart:convert';
import 'package:http/http.dart' as http;
import 'utils/utils.dart';


class EnderecoService {
  
  //emulador android
  static const String baseUrl = 'http://10.0.2.2:8080';

  //celular fisico
  // static const String baseUrl = 'http://10.106.75.47:8080';

  //web
  // static const String baseUrl = 'http://localhost:8080';

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
      Uri.parse('$baseUrl/cliente/endereco'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao cadastrar endereco: ${response.body}');
    }
  }

}