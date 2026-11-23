import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pet validation', () {
    test('accepts a valid dog registration', () {
      final pet = Pet(
        usuarioId: 'usuario-1',
        tipo: PetType.cachorro,
        nome: 'Max',
        genero: PetGenero.macho,
        peso: 7.5,
        dataNascimento: DateTime(2020, 1, 1),
        raca: 'Labrador',
      );

      expect(pet.errors, isEmpty);
    });

    test('rejects an unsupported animal type', () {
      final pet = Pet(
        usuarioId: 'usuario-1',
        tipo: PetType.outro,
        nome: 'Max',
        genero: PetGenero.macho,
        peso: 7.5,
        dataNascimento: DateTime(2020, 1, 1),
        raca: 'Labrador',
      );

      expect(pet.errors, contains('Selecione um tipo de animal válido.'));
    });

    test('rejects future birth dates', () {
      final pet = Pet(
        usuarioId: 'usuario-1',
        tipo: PetType.gato,
        nome: 'Mimi',
        genero: PetGenero.femea,
        peso: 2.2,
        dataNascimento: DateTime.now().add(const Duration(days: 1)),
        raca: 'Siamês',
      );

      expect(pet.errors, contains('Data de nascimento não pode ser futura.'));
    });
  });

  group('InMemoryPetRepository', () {
    test('stores and retrieves registered pets', () {
      final repository = InMemoryPetRepository();
      final pet = Pet(
        usuarioId: 'usuario-1',
        tipo: PetType.cachorro,
        nome: 'Max',
        genero: PetGenero.macho,
        peso: 7.5,
        dataNascimento: DateTime(2020, 1, 1),
        raca: 'Labrador',
      );

      repository.save(pet);
      final pets = repository.findAll();

      expect(pets, hasLength(1));
      expect(pets.first.nome, 'Max');
      expect(pets.first.id, isNotEmpty);
    });

    test('does not save invalid pets', () {
      final repository = InMemoryPetRepository();
      final pet = Pet(
        usuarioId: 'usuario-1',
        tipo: PetType.gato,
        nome: '',
        genero: PetGenero.femea,
        peso: 0,
        dataNascimento: DateTime.now().add(const Duration(days: 1)),
        raca: '',
      );

      expect(() => repository.save(pet), throwsArgumentError);
      expect(repository.findAll(), isEmpty);
    });

    test('separa pets por usuário e impede mudança de proprietário', () {
      final repository = InMemoryPetRepository();
      Pet pet(String id, String usuario) => Pet(
        id: id,
        usuarioId: usuario,
        tipo: PetType.cachorro,
        nome: id,
        genero: PetGenero.macho,
        peso: 7,
        dataNascimento: DateTime(2020),
        raca: 'Labrador',
      );
      repository.save(pet('max', 'usuario-1'));
      repository.save(pet('luna', 'usuario-2'));
      expect(repository.findByUsuarioId('usuario-1').single.nome, 'max');
      expect(repository.findByUsuarioId('usuario-2').single.nome, 'luna');
      expect(repository.findByUsuarioId('usuario-3'), isEmpty);
      expect(
        () => repository.save(pet('max', 'usuario-2')),
        throwsArgumentError,
      );
      expect(
        () => repository.save(pet('sem-usuario', '')),
        throwsArgumentError,
      );
      expect(repository.findById('max')!.usuarioId, 'usuario-1');
      expect(
        repository.findById('max')!.copyWith(nome: 'Novo').usuarioId,
        'usuario-1',
      );
    });
  });
}
