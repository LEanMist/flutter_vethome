import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/saved_address.dart';
import 'api_config.dart';
import 'utils/utils.dart';

class PersistenceClearingException implements Exception {
  const PersistenceClearingException();

  @override
  String toString() => 'PersistenceClearingException';
}

class PersistenceBlockedException implements Exception {
  const PersistenceBlockedException();

  @override
  String toString() => 'PersistenceBlockedException';
}

class EnderecoService {
  static String get baseUrl => ApiConfig.baseUrl;

  static final List<SavedAddress> addresses = <SavedAddress>[];

  static void saveAddress(SavedAddress address) {
    final index = addresses.indexWhere((item) => item.id == address.id);
    if (index >= 0) {
      addresses[index] = address;
      return;
    }
    addresses.add(address);
  }

  static void removeAddress(String id) {
    final index = addresses.indexWhere((item) => item.id == id);
    if (index >= 0) {
      addresses.removeAt(index);
    }
  }

  static Future<bool> flush() async {
    return true;
  }

  static Future<List<SavedAddress>> listarEnderecos() async {
    return List<SavedAddress>.from(addresses);
  }

  static Future<void> cadastrarEndereco(Map<String, String?> dados) async {
    final body = {
      'cep': Utils.limparCep(dados['cep']),
      'logradouro': dados['logradouro'],
      'complemento': dados['complemento'],
      'bairro': dados['bairro'],
      'cidade': dados['cidade'],
      'numero': dados['numero'],
      'cpfCliente': Utils.limparCpf(dados['cpfCliente']),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/endereco'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao cadastrar endereço (${response.statusCode}): ${response.body}',
      );
    }
  }
}
