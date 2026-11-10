import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'utils/utils.dart';

class ConsultaService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Monta o JSON exatamente com os nomes que o backend espera (DadosCriarConsulta).
  static Map<String, dynamic> buildPayload(Map<String, String?> dados) {
    final idPet = int.tryParse((dados['idPet'] ?? '').trim());
    if (idPet == null) {
      throw Exception(
        'Este pet ainda não tem id do servidor. Recarregue a lista de pets e tente de novo.',
      );
    }

    return {
      'cpfCliente': Utils.limparCpf(dados['cpfCliente']),
      'idPet': idPet,
      'servicos': (dados['servicos'] ?? '').trim(),
      'convenio':
          (dados['convenio'] ?? dados['complemento'] ?? 'Particular').trim(),
      'dataConsulta': Utils.formatDate(dados['data']), // yyyy-MM-dd
      'horarioConsulta': (dados['horarioInicio'] ?? '').trim(), // HH:mm
      'descricao_consulta': (dados['descricao'] ?? '').trim(),
    };
  }

  static Future<void> criarConsulta(Map<String, String?> dados) async {
    final body = buildPayload(dados);

    final response = await http.post(
      Uri.parse('$baseUrl/consulta'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao criar consulta (${response.statusCode}): ${response.body}',
      );
    }
  }
}
