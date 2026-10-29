import 'dart:convert';
import 'package:http/http.dart' as http;
import 'utils/utils.dart';

class ConsultaService {
  // emulador android
  static const String baseUrl = 'http://10.0.2.2:8080';

  //celular fisico
  // static const String baseUrl = 'http://10.106.75.47:8080';

  //web
  // static const String baseUrl = 'http://localhost:8080';

  static Map<String, dynamic> buildPayload(Map<String, String?> dados) {
    final body = <String, dynamic>{
      'cpfCliente': Utils.limparCpf(dados['cpfCliente']),
      'idPet': (dados['idPet'] ?? '').trim(),
      'servicos': (dados['servicos'] ?? '').trim(),
      'convenio':
          (dados['convenio'] ?? dados['complemento'] ?? 'Particular').trim(),
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

