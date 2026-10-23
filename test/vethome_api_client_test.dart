import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_vethome/data/remote/api_config.dart';
import 'package:flutter_vethome/data/remote/api_exception.dart';
import 'package:flutter_vethome/data/remote/contracts/address_create_request.dart';
import 'package:flutter_vethome/data/remote/contracts/client_create_request.dart';
import 'package:flutter_vethome/data/remote/contracts/pet_create_request.dart';
import 'package:flutter_vethome/data/remote/vethome_api_client.dart';

void main() {
  group('ApiConfig', () {
    test('exige URL HTTPS configurada', () {
      expect(
        () => ApiConfig.fromEnvironment(baseUrl: ''),
        throwsA(isA<ApiException>()),
      );
      expect(
        () => ApiConfig.fromEnvironment(baseUrl: 'http://api.example.test'),
        throwsA(isA<ApiException>()),
      );

      final config = ApiConfig.fromEnvironment(
        baseUrl: 'https://api.example.test/v1',
      );
      expect(
        config.resolve('cliente/endereco'),
        Uri.parse('https://api.example.test/v1/cliente/endereco'),
      );
    });
  });

  group('DTOs provisórios observados na Nicolly', () {
    test('cliente conserva apenas o contrato observado e normaliza dados', () {
      final request = ClientCreateRequest(
        nome: 'Ana Lima',
        dataNascimento: '05/02/2007',
        cpf: '534.356.874-94',
        telefone: '(11) 94345-3266',
        email: 'ana@example.test',
        senha: 'segredo-local',
      );

      expect(request.toJson(), {
        'nome': 'Ana Lima',
        'dataNascimento': '2007-02-05',
        'cpf': '53435687494',
        'telefone': '11943453266',
        'email': 'ana@example.test',
        'senha': 'segredo-local',
      });
    });

    test('endereço conserva bairro e vínculo por CPF como pendências', () {
      final request = AddressCreateRequest(
        cep: '34556-234',
        logradouro: 'Rua Central',
        complemento: null,
        bairro: 'Centro',
        cidade: 'Belo Horizonte',
        numero: '73',
        cpfCliente: '534.356.874-94',
      );

      expect(request.toJson(), {
        'cep': '34556234',
        'logradouro': 'Rua Central',
        'complemento': null,
        'bairro': 'Centro',
        'cidade': 'Belo Horizonte',
        'numero': '73',
        'cpfCliente': '53435687494',
      });
    });

    test('pet não inventa sexo, foto, castração ou resposta', () {
      final request = PetCreateRequest(
        nome: 'Fernando',
        dataNasc: '23/03/2012',
        especie: 'Cachorro',
        raca: null,
        peso: '24',
        convenio: 'Particular',
        cpfCliente: '534.356.874-94',
      );

      expect(request.toJson(), {
        'nome': 'Fernando',
        'dataNasc': '2012-03-23',
        'especie': 'Cachorro',
        'raca': '',
        'peso': '24',
        'convenio': 'Particular',
        'cpfCliente': '53435687494',
      });
    });
  });

  group('VetHomeApiClient', () {
    test('envia somente os três POSTs observados e aceita 200/201', () async {
      final seen = <http.Request>[];
      final responses = <int>[200, 201, 200];
      final transport = MockClient((request) async {
        seen.add(request);
        return http.Response('{}', responses[seen.length - 1]);
      });
      final api = VetHomeApiClient(
        config: ApiConfig.fromEnvironment(baseUrl: 'https://api.example.test'),
        client: transport,
      );

      await api.createClient(
        const ClientCreateRequest(nome: 'Ana', senha: 'sigilosa'),
      );
      await api.createAddress(const AddressCreateRequest(logradouro: 'Rua A'));
      await api.createPet(const PetCreateRequest(nome: 'Bidu'));

      expect(seen.map((request) => request.method), everyElement('POST'));
      expect(seen.map((request) => request.url.path), [
        '/cliente',
        '/cliente/endereco',
        '/cliente/pet',
      ]);
      expect(
        seen.map((request) => request.headers['content-type']),
        everyElement('application/json; charset=UTF-8'),
      );
      expect(jsonDecode(seen.first.body), containsPair('nome', 'Ana'));
    });

    test('erro HTTP é sanitizado e não expõe corpo, CPF ou senha', () async {
      final api = VetHomeApiClient(
        config: ApiConfig.fromEnvironment(baseUrl: 'https://api.example.test'),
        client: MockClient(
          (_) async => http.Response(
            'senha=sigilosa cpf=53435687494 detalhe-interno',
            422,
          ),
        ),
      );

      Object? captured;
      try {
        await api.createClient(
          const ClientCreateRequest(cpf: '534.356.874-94', senha: 'sigilosa'),
        );
      } catch (error) {
        captured = error;
      }

      expect(captured, isA<ApiException>());
      final error = captured! as ApiException;
      expect(error.kind, ApiExceptionKind.http);
      expect(error.statusCode, 422);
      expect(error.toString(), isNot(contains('sigilosa')));
      expect(error.toString(), isNot(contains('53435687494')));
      expect(error.toString(), isNot(contains('detalhe-interno')));
    });

    test('timeout é distinguido de erro HTTP', () async {
      final api = VetHomeApiClient(
        config: ApiConfig.fromEnvironment(
          baseUrl: 'https://api.example.test',
          timeout: const Duration(milliseconds: 1),
        ),
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return http.Response('{}', 200);
        }),
      );

      await expectLater(
        api.createPet(const PetCreateRequest(nome: 'Bidu')),
        throwsA(
          isA<ApiException>().having(
            (error) => error.kind,
            'kind',
            ApiExceptionKind.timeout,
          ),
        ),
      );
    });

    test(
      'falha de transporte é categorizada sem dados da requisição',
      () async {
        final api = VetHomeApiClient(
          config: ApiConfig.fromEnvironment(
            baseUrl: 'https://api.example.test',
          ),
          client: MockClient(
            (_) async => throw http.ClientException('offline'),
          ),
        );

        await expectLater(
          api.createAddress(
            const AddressCreateRequest(cpfCliente: '534.356.874-94'),
          ),
          throwsA(
            isA<ApiException>()
                .having((error) => error.kind, 'kind', ApiExceptionKind.network)
                .having(
                  (error) => error.toString(),
                  'mensagem sanitizada',
                  isNot(contains('53435687494')),
                ),
          ),
        );
      },
    );
  });
}
