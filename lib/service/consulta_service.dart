import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'utils/utils.dart';

class ConsultaService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Map<String, dynamic> buildPayload(Map<String, String?> dados) {
    final body = <String, dynamic>{
      'cpfCliente': Utils.limparCpf(dados['cpfCliente']),
      'idPet': (dados['idPet'] ?? '').trim(),
      'servicos': (dados['servicos'] ?? '').trim(),
      'convenio':
          (dados['convenio'] ?? dados['complemento'] ?? 'Particular').trim(),
      'data': (dados['data'] ?? '').trim(),
      'horario': (dados['horarioInicio'] ?? '').trim(),
      'descricao': (dados['descricao'] ?? '').trim(),
    };


    final data = (dados['data'] ?? '').trim();
    if (data.isNotEmpty) body['data'] = Utils.formatDate(data);

    final horarioInicio = (dados['horarioInicio'] ?? '').trim();
    if (horarioInicio.isNotEmpty) body['horarioInicio'] = horarioInicio;

    final horarioFim = (dados['horarioFim'] ?? '').trim();
    if (horarioFim.isNotEmpty) body['horarioFim'] = horarioFim;

    final descricao = (dados['descricao'] ?? '').trim();
    if (descricao.isNotEmpty) body['descricao'] = descricao;

    return body;
  }

  static Future<void> criarConsulta(Map<String, String?> dados) async {
    final body = buildPayload(dados);

    final response = await http.post(
      Uri.parse('$baseUrl/consulta'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao criar consulta: ${response.body}');
    }
  }
  
}

