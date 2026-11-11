import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'utils/utils.dart';

class ConsultaService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Lê {"mensagem": "..."} das respostas de erro do backend.
  static String _mensagemDeErro(http.Response response, String padrao) {
    try {
      final corpo = jsonDecode(utf8.decode(response.bodyBytes));
      if (corpo is Map && corpo['mensagem'] != null) {
        return corpo['mensagem'].toString();
      }
    } catch (_) {}
    return '$padrao (${response.statusCode})';
  }

  /// Monta o JSON exatamente com os nomes que o backend espera (DadosCriarConsulta).
  static Map<String, dynamic> buildPayload(Map<String, String?> dados) {
    final idPet = (dados['idPet'] ?? '').trim();
    if (idPet.isEmpty) {
      throw Exception(
        'Este pet ainda não tem id do servidor. Recarregue a lista de pets e tente de novo.',
      );
    }

    final cpfCliente = Utils.limparCpf(dados['cpfCliente']);
    final servicos = (dados['servicos'] ?? '').trim();
    final convenio =
        (dados['convenio'] ?? dados['complemento'] ?? 'Particular').trim();
    final data = Utils.formatDate(dados['data']);
    final horarioInicio = (dados['horarioInicio'] ?? '').trim();
    final horarioFim = (dados['horarioFim'] ?? '').trim();
    final descricao = (dados['descricao'] ?? '').trim();

    return {
      'cpfCliente': cpfCliente,
      'idPet': idPet,
      'servicos': servicos,
      'convenio': convenio,
      'data': data,
      'horarioInicio': horarioInicio,
      'horarioFim': horarioFim,
      'descricao': descricao,
      'dataConsulta': data,
      'horarioConsulta': horarioInicio,
      'descricao_consulta': descricao,
    };
  }

  /// Horários livres da data, no formato "HH:mm" (ex.: ["12:00", "14:00"]).
  static Future<List<String>> horariosDisponiveis(DateTime data) async {
    final dia = '${data.year}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
    final response = await http.get(
      Uri.parse('$baseUrl/consulta/horarios-disponiveis')
          .replace(queryParameters: {'data': dia}),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        _mensagemDeErro(response, 'Não foi possível buscar os horários'),
      );
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return (decoded as List).map((item) => item.toString()).toList();
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
        _mensagemDeErro(response, 'Não foi possível criar a consulta'),
      );
    }
  }
}
