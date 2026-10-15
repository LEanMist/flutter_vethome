import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/services/cep_lookup_service.dart';
import 'package:http/http.dart' as http;

void main() {
  test('looks up and parses a ViaCEP response', () async {
    Uri? requestedUri;
    final service = ViaCepLookupService(
      get: (uri) async {
        requestedUri = uri;
        return http.Response(
          jsonEncode({
            'logradouro': 'Rua das Flores',
            'localidade': 'São Paulo',
          }),
          200,
        );
      },
    );

    final endereco = await service.consultar('01.001-000');

    expect(requestedUri?.host, 'viacep.com.br');
    expect(requestedUri?.path, '/ws/01001000/json/');
    expect(endereco?.logradouro, 'Rua das Flores');
    expect(endereco?.cidade, 'São Paulo');
  });

  test('returns null when ViaCEP does not find the postal code', () async {
    final service = ViaCepLookupService(
      get: (_) async => http.Response(jsonEncode({'erro': true}), 200),
    );

    expect(await service.consultar('00000000'), isNull);
  });

  test('does not make a request when the postal code is incomplete', () async {
    var requestCount = 0;
    final service = ViaCepLookupService(
      get: (_) async {
        requestCount++;
        return http.Response('{}', 200);
      },
    );

    expect(await service.consultar('1234567'), isNull);
    expect(requestCount, 0);
  });
}
