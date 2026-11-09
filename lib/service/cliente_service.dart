import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'utils/utils.dart';

class ClienteService {
  static String get baseUrl => ApiConfig.baseUrl;


  static Future<void> cadastrarCliente(Map<String, String?> dados) async {
    final body = {
      'nome': dados['Nome Completo'],
      'dataNascimento': Utils.formatDate(dados['Data de Nascimento']),
      'cpf': Utils.limparCpf(dados['CPF']),
      'telefone': Utils.limparTelefone(dados['Telefone/Celular']),
      'email': dados['E-mail'],
      'senha': dados['Senha'],
    };

    final response = await http.post(
      Uri.parse('$baseUrl/cliente'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao cadastrar cliente: ${response.body}');
    }
  }
 
}