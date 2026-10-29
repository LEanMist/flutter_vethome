import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/service/consulta_service.dart';

void main() {
  test('buildPayload usa os dados reais da consulta para o backend', () {
    final payload = ConsultaService.buildPayload({
      'cpfCliente': '123.456.789-09',
      'idPet': 'pet-42',
      'servicos': 'Consulta Geral',
      'convenio': 'Particular',
      'data': '2026-10-29',
      'horarioInicio': '09:00',
      'horarioFim': '10:00',
      'descricao': 'Acompanhamento do pet',
    });

    expect(payload['cpfCliente'], '12345678909');
    expect(payload['idPet'], 'pet-42');
    expect(payload['servicos'], 'Consulta Geral');
    expect(payload['convenio'], 'Particular');
    expect(payload['data'], '2026-10-29');
    expect(payload['horarioInicio'], '09:00');
    expect(payload['horarioFim'], '10:00');
    expect(payload['descricao'], 'Acompanhamento do pet');
  });
}
