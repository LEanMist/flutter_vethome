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

  static String? _toBrazilianDate(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    if (raw.contains('/')) return raw;
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static Future<void> atualizarPet({
    required String id,
    required Map<String, String?> dados,
  }) async {
    final petId = int.tryParse(id);
    if (petId == null) {
      throw Exception('Este pet não possui um identificador válido do servidor.');
    }
    final peso = double.tryParse((dados['peso'] ?? '').replaceAll(',', '.'));
    final body = <String, dynamic>{
      'id': petId,
      if ((dados['nome'] ?? '').trim().isNotEmpty) 'nome': dados['nome']!.trim(),
      if ((dados['dataNasc'] ?? '').trim().isNotEmpty)
        'dataNasc': _toBrazilianDate(dados['dataNasc']), // DTO PUT exige dd/MM/yyyy.
      if ((dados['especie'] ?? '').trim().isNotEmpty) 'especie': dados['especie'],
      if ((dados['sexo'] ?? '').trim().isNotEmpty) 'sexo': dados['sexo'],
      if ((dados['raca'] ?? '').trim().isNotEmpty) 'raca': dados['raca'],
      if (peso != null) 'peso': peso,
    };
    final response = await http.put(
      Uri.parse('$baseUrl/pet'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao atualizar pet (${response.statusCode}): ${response.body}');
    }
  }

  static Future<void> excluirPet(String id) async {
    final petId = int.tryParse(id);
    if (petId == null) {
      throw Exception('Este pet não possui um identificador válido do servidor.');
    }
    final response = await http.delete(Uri.parse('$baseUrl/pet/$petId'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao excluir pet (${response.statusCode}): ${response.body}');
    }
  }

}
