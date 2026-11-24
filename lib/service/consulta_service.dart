import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'utils/utils.dart';

class ConsultaService {
  static String get baseUrl => ApiConfig.baseUrl;

  static String _error(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map && decoded['mensagem'] != null) {
        return decoded['mensagem'].toString();
      }
    } catch (_) {}
    return '$fallback (${response.statusCode})';
  }

  /// Constrói o corpo conforme o record DadosCriarConsulta do Spring.
  /// O idEndereco vem do SavedAddress selecionado na interface, nunca digitado.
  static Map<String, dynamic> buildPayload(Map<String, String?> dados) {
    final idPet = int.tryParse((dados['idPet'] ?? '').trim());
    final idEndereco = int.tryParse((dados['idEndereco'] ?? '').trim());
    if (idPet == null) {
      throw Exception('Este pet ainda não tem ID no servidor. Recarregue a lista de pets.');
    }
    if (idEndereco == null) {
      throw Exception('Selecione um endereço cadastrado para a consulta.');
    }

    return {
      'cpfCliente': Utils.limparCpf(dados['cpfCliente']),
      'idPet': idPet,
      'idEndereco': idEndereco,
      'servicos': (dados['servicos'] ?? '').trim(),
      'convenio': (dados['convenio'] ?? dados['complemento'] ?? 'Particular').trim(),
      'dataConsulta': Utils.formatDate(dados['data']),
      'horarioConsulta': (dados['horarioInicio'] ?? '').trim(),
      'descricao_consulta': (dados['descricao'] ?? '').trim(),
    };
  }

  static Future<void> criarConsulta(Map<String, String?> dados) async {
    final response = await http.post(
      Uri.parse('$baseUrl/consulta'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(buildPayload(dados)),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_error(response, 'Erro ao criar consulta'));
    }
  }

  /// Lista consultas pendentes do tutor. A API retorna Page<DadosListagemConsulta>.
  static Future<List<Map<String, dynamic>>> listarConsultas({required String cpfCliente}) async {
    final cpf = Utils.limparCpf(cpfCliente);
    if (cpf.isEmpty) return [];
    final response = await http.get(
      Uri.parse('$baseUrl/consulta').replace(queryParameters: {'cpfCliente': cpf, 'size': '100'}),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception(_error(response, 'Não foi possível carregar as consultas'));
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final List items = decoded is Map && decoded['content'] is List
        ? decoded['content'] as List
        : decoded is List
            ? decoded
            : throw Exception('Resposta inválida do backend para consultas.');
    return items.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static Future<void> excluirConsulta(String id) async {
    final numericId = int.tryParse(id);
    if (numericId == null) throw Exception('Consulta sem identificador válido do servidor.');
    final response = await http.delete(Uri.parse('$baseUrl/consulta/$numericId'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_error(response, 'Não foi possível cancelar a consulta'));
    }
  }

  static Future<void> atualizarConsulta(Map<String, dynamic> dados) async {
    final response = await http.put(
      Uri.parse('$baseUrl/consulta'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(dados),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_error(response, 'Não foi possível atualizar a consulta'));
    }
  }
}
