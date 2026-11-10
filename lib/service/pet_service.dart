import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pet_model.dart';
import 'api_config.dart';
import 'utils/utils.dart';

class PetService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<List<PetModel>> listarPets({String? cpfCliente}) async {
    final cpf = Utils.limparCpf(cpfCliente);
    // O backend exige cpfCliente (GET /pet sem ele devolve 400).
    if (cpf.isEmpty) return [];

    final uri = Uri.parse('$baseUrl/pet').replace(
      queryParameters: {'cpfCliente': cpf, 'size': '100'},
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar pets: ${response.statusCode} - ${response.body}',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    // O Spring devolve Page<...>: {"content": [...], "totalElements": ...}
    final List items;
    if (decoded is Map && decoded['content'] is List) {
      items = decoded['content'] as List;
    } else if (decoded is List) {
      items = decoded;
    } else {
      throw Exception('Resposta inválida do backend para pets.');
    }

    return items
        .map((item) => PetModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> cadastrarPet(Map<String, String?> dados) async {
    final peso = double.tryParse((dados['peso'] ?? '').replaceAll(',', '.'));

    final body = {
      'nome': dados['nome'],
      'dataNasc': Utils.formatDate(dados['dataNasc']),
      'especie': dados['especie'],
      'sexo': dados['sexo'],
      'raca': dados['raca'] ?? '',
      'peso': peso, // número, não string ("12,5" quebraria no Jackson)
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
