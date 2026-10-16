import 'dart:convert';
import 'package:http/http.dart' as http;
import 'utils/utils.dart';

class PetService{
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<void> cadastrarPet(Map<String, String?> dados) async {
    final body = {
      'nome': dados['Nome do Pet'],
      'dataNasc':Utils.formatDate(dados['Data de Nascimento']),
      'especie': dados['Tipo de Animal'],
    //'sexo': dados['Gênero/Sexo']  
      'raca': dados['Raça'],
      'peso': dados['Peso'],
      'convenio': dados['Convênio'],
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