import 'dart:convert';
import 'package:http/http.dart' as http;
import 'utils/utils.dart';

class ConsultaService{
  //emulador android
  static const String baseUrl = 'http://10.0.2.2:8080';

  //celular fisico
  // static const String baseUrl = 'http://10.106.75.47:8080';

  //web
  // static const String baseUrl = 'http://localhost:8080';

  static Future<void> criarConsulta(Map<String, String?> dados) async {
    final body = {
      'cpfCliente': Utils.limparCpf(dados['cpfCliente']),
      'idPet': (dados['idPet']),
      'servicos': dados['servicos'],
      'convenio': dados['complemento'],
    };

    final response = await http.post(
      Uri.parse('$baseUrl/consulta'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao cadastrar endereco: ${response.body}');
    }
  }
  
}

