import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/core/utils/form_fields.dart';

void main() {
  test('CPF válido aceita formato puro e máscara brasileira', () {
    expect(isValidCpf('52998224725'), isTrue);
    expect(isValidCpf('529.982.247-25'), isTrue);
  });

  test('CPF inválido rejeita dígito alterado e sequências repetidas', () {
    expect(isValidCpf('529.982.247-24'), isFalse);
    expect(isValidCpf('000.000.000-00'), isFalse);
    expect(isValidCpf('11111111111'), isFalse);
  });

  test('CPF inválido rejeita tamanho e caracteres fora da máscara', () {
    expect(isValidCpf('5299822472'), isFalse);
    expect(isValidCpf('cpf 52998224725'), isFalse);
  });
}
