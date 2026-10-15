import 'dart:convert';
import 'package:http/http.dart' as http;

class ClienteService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<void> cadastrarCliente(Map<String, String?> dados) async {
    final body = {
      'nome': dados['Nome Completo'],
      'dataNascimento': _formatDate(dados['Data de Nascimento']),
      'cpf': _limparCpf(dados['CPF']),
      'telefone': _limparTelefone(dados['Telefone/Celular']),
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

  static String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    final parts = value.split('/');
    if (parts.length != 3) return value;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  static String _limparCpf(String? value) => (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  static String _limparTelefone(String? value) => (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  // static String _limparCep(String? value) => (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
}