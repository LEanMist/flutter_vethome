import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';

void main() {
  group('Usuario validation', () {
    test('accepts a valid registration', () {
      expect(_usuarioValido().errors, isEmpty);
    });

    test('rejects invalid CPF, phone, CEP, and future birth date', () {
      final usuario = _usuarioValido(
        cpf: '111.111.111-11',
        telefone: '123',
        cep: '123',
        dataNascimento: DateTime.now().add(const Duration(days: 1)),
      );

      expect(
        usuario.errors.keys,
        containsAll(['cpf', 'telefone', 'cep', 'dataNascimento']),
      );
    });
  });

  group('InMemoryUsuarioRepository', () {
    test('stores users and finds normalized email and CPF', () {
      final repository = InMemoryUsuarioRepository();
      final usuario = _usuarioValido();

      repository.save(usuario);

      expect(repository.findAll(), hasLength(1));
      expect(repository.findAll().single.id, isNotEmpty);
      expect(repository.findByEmail(' ANA@example.com '), isNotNull);
      expect(repository.findByCpf('52998224725'), isNotNull);
    });

    test('rejects duplicate email and CPF', () {
      final repository = InMemoryUsuarioRepository();
      repository.save(_usuarioValido());

      expect(
        () => repository.save(
          _usuarioValido(email: 'ana@example.com', cpf: '168.995.350-09'),
        ),
        throwsArgumentError,
      );
      expect(
        () => repository.save(_usuarioValido(email: 'outra@example.com')),
        throwsArgumentError,
      );
      expect(repository.findAll(), hasLength(1));
    });

    test('does not store invalid users', () {
      final repository = InMemoryUsuarioRepository();

      expect(
        () => repository.save(_usuarioValido(cpf: '111.111.111-11')),
        throwsArgumentError,
      );
      expect(repository.findAll(), isEmpty);
    });
  });
}

Usuario _usuarioValido({
  String email = 'ana@example.com',
  String cpf = '529.982.247-25',
  String telefone = '11987654321',
  String cep = '01001000',
  DateTime? dataNascimento,
}) {
  return Usuario(
    nome: 'Ana Souza',
    dataNascimento: dataNascimento ?? DateTime(1990, 5, 20),
    genero: GeneroUsuario.feminino,
    cpf: cpf,
    telefone: telefone,
    cep: cep,
    endereco: 'Rua das Flores',
    numero: '42',
    complemento: '',
    cidade: 'São Paulo',
    email: email,
  );
}
