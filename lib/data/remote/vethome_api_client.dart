import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'contracts/address_create_request.dart';
import 'contracts/client_create_request.dart';
import 'contracts/pet_create_request.dart';

/// Transporte isolado para os três POSTs observados em `origin/nicolly`.
///
/// Nenhuma tela usa esta classe ainda. O corpo de sucesso não é interpretado,
/// pois a branch de referência não comprova um contrato de resposta.
class VetHomeApiClient {
  const VetHomeApiClient({required this.config, required this.client});

  final ApiConfig config;
  final http.Client client;

  Future<void> createClient(ClientCreateRequest request) =>
      _post('cliente', request.toJson());

  Future<void> createAddress(AddressCreateRequest request) =>
      _post('cliente/endereco', request.toJson());

  Future<void> createPet(PetCreateRequest request) =>
      _post('cliente/pet', request.toJson());

  Future<void> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await client
          .post(
            config.resolve(path),
            headers: const {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(body),
          )
          .timeout(config.timeout);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiException.http(response.statusCode);
      }
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException.timeout();
    } on http.ClientException {
      throw ApiException.network();
    }
  }
}
