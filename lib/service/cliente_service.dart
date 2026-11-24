import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'utils/utils.dart';

class ClienteService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<void> cadastrarCliente(Map<String, String?> dados) async {
    final body = {
      'nome': dados['Nome Completo'],
      'dataNascimento': _dataNascimentoIso(dados['Data de Nascimento']),
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

  /// Converte datas digitadas como DD/MM/AAAA (com ou sem espaços) para ISO.
  static String _dataNascimentoIso(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return Utils.formatDate(value);
    return '${digits.substring(4, 8)}-${digits.substring(2, 4)}-${digits.substring(0, 2)}';
  }

  /// Login no backend. Devolve {id, nome, cpf, email, telefone, dataNascimento}.
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'email': email.trim(), 'senha': senha}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw Exception(
        'Não foi possível conectar ao servidor ($baseUrl). O backend está rodando?',
      );
    }

    if (response.statusCode == 401) {
      throw Exception('E-mail ou senha incorretos.');
    }
    if (response.statusCode != 200) {
      throw Exception('Erro ao entrar (${response.statusCode}): ${response.body}');
    }
    return Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
  }
}
