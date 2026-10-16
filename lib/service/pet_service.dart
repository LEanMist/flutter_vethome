import 'dart:convert';
import 'package:http/http.dart' as http;
import 'utils/utils.dart';

class PetService{
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<void> cadastrarPet(Map<String, String?> dados) async {
    final body = {
      'nome': dados['nome'],
      'dataNasc':Utils.formatDate(dados['dataNasc']),
      'especie': dados['especie'],
    //'sexo': dados['sexo']  
      'raca': dados['raca'] ?? '',
      'peso': dados['peso'],
      'convenio': dados['convenio'],
      'cpfCliente': Utils.limparCpf(dados['cpfCliente']),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/cliente/pet'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao cadastrar pet: ${response.body}');
    }
  }
}