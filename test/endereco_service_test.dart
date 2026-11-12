import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/service/endereco_service.dart';

void main() {
  group('EnderecoService', () {
    tearDown(() {
      EnderecoService.addresses.clear();
    });

    test('salva e remove endereços em memória', () async {
      final address = SavedAddress(
        id: 'address-1',
        street: 'Rua das Flores',
        name: 'Casa',
        number: '123',
        complement: 'Apto 1',
        city: 'São Paulo',
        cep: '01000-000',
      );

      EnderecoService.saveAddress(address);
      expect(EnderecoService.addresses, contains(address));

      EnderecoService.removeAddress(address.id);
      expect(EnderecoService.addresses, isNot(contains(address)));

      expect(await EnderecoService.flush(), isTrue);
    });
  });
}
