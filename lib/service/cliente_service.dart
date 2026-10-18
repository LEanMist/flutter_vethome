import 'dart:convert';
import 'package:http/http.dart' as http;
import 'utils/utils.dart';


class ClienteService {
  //emulador android
  static const String baseUrl = 'http://10.0.2.2:8080';

  //celular fisico
  // static const String baseUrl = 'http://10.106.75.47:8080';

  //web
  // static const String baseUrl = 'http://localhost:8080';


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