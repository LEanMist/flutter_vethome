import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pet_model.dart';
import 'api_config.dart';
import 'utils/utils.dart';

class PetService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<List<PetModel>> listarPets({String? cpfCliente}) async {
    final uri = cpfCliente == null || cpfCliente.trim().isEmpty
        ? Uri.parse('$baseUrl/pet')
        : Uri.parse(
            '$baseUrl/pet?cpfCliente=${Uri.encodeQueryComponent(cpfCliente)}',
          );

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar pets: ${response.statusCode} - ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Resposta inválida do backend para pets.');
    }

    return decoded
        .map((item) => PetModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> cadastrarPet(Map<String, String?> dados) async {
    final body = {
      'nome': dados['nome'],
      'dataNasc': Utils.formatDate(dados['dataNasc']),
      'especie': dados['especie'],
      'sexo': dados['sexo'],
      'raca': dados['raca'] ?? '',
      'peso': dados['peso'],
      'cpfCliente': Utils.limparCpf(dados['cpfCliente']),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/pet'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro ao cadastrar pet: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
