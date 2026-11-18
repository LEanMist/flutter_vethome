import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/session.dart';
import '../models/saved_address.dart';
import 'api_config.dart';
import 'utils/utils.dart';

class EnderecoService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Cache em memória da lista exibida na tela de Endereços.
  /// É preenchido por [listarEnderecos] / [carregar] com os dados do backend.
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

  static SavedAddress _fromApi(Map<String, dynamic> json) => SavedAddress(
    id: '${json['id']}',
    street: json['logradouro']?.toString() ?? '',
    name: json['apelido']?.toString() ?? '',
    number: json['numero']?.toString() ?? '',
    complement: json['complemento']?.toString() ?? '',
    city: json['cidade']?.toString() ?? '',
    cep: json['cep']?.toString() ?? '',
    neighborhood: json['bairro']?.toString() ?? '',
  );

  /// Busca no backend os endereços do cliente logado e atualiza o cache.
  /// Sem cliente logado devolve apenas o que já está no cache.
  static Future<List<SavedAddress>> listarEnderecos({String? cpfCliente}) async {
    final cpf = Utils.limparCpf(cpfCliente ?? Session.clientCpf);
    if (cpf.isEmpty) return List<SavedAddress>.from(addresses);

    final response = await http.get(
      Uri.parse('$baseUrl/endereco').replace(
        queryParameters: {'cpfCliente': cpf, 'size': '100'},
      ),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception(
        _mensagemDeErro(response, 'Não foi possível carregar os endereços'),
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    // O Spring devolve Page<...>: {"content": [...], ...}
    final List items = decoded is Map && decoded['content'] is List
        ? decoded['content'] as List
        : decoded is List
        ? decoded
        : throw Exception('Resposta inválida do backend para endereços.');

    final lista = items
        .map((item) => _fromApi(Map<String, dynamic>.from(item as Map)))
        .toList();
    addresses
      ..clear()
      ..addAll(lista);
    return lista;
  }

  static Future<void> carregar() async {
    await listarEnderecos();
  }

  /// Cria (POST) ou atualiza (PUT) um endereço do cliente logado e recarrega a lista.
  /// Ids numéricos vêm do backend; ids gerados no app ('address-...') são endereços novos.
  static Future<void> salvar(SavedAddress address) async {
    final cpf = Utils.limparCpf(Session.clientCpf);
    if (cpf.isEmpty) {
      throw Exception('Entre na sua conta para salvar endereços.');
    }

    final id = int.tryParse(address.id);
    final body = {
      if (id != null) 'id': id,
      'cep': Utils.limparCep(address.cep),
      'logradouro': address.street,
      'complemento': address.complement,
      'bairro': address.neighborhood,
      'cidade': address.city,
      'numero': address.number,
      'apelido': address.name,
      if (id == null) 'cpfCliente': cpf,
    };

    final uri = Uri.parse('$baseUrl/endereco');
    const headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final response = id == null
        ? await http.post(uri, headers: headers, body: jsonEncode(body))
        : await http.put(uri, headers: headers, body: jsonEncode(body));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _mensagemDeErro(response, 'Não foi possível salvar o endereço'),
      );
    }

    try {
      await listarEnderecos();
    } catch (_) {
      // O endereço foi salvo; a lista será recarregada na próxima abertura da tela.
    }
  }

  /// Exclui (DELETE) um endereço do backend e tira do cache.
  static Future<void> excluir(String id) async {
    final numerico = int.tryParse(id);
    if (numerico != null) {
      final response = await http.delete(Uri.parse('$baseUrl/endereco/$numerico'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          _mensagemDeErro(response, 'Não foi possível excluir o endereço'),
        );
      }
    }
    removeAddress(id);
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
        _mensagemDeErro(response, 'Erro ao cadastrar endereço'),
      );
    }
  }
}
