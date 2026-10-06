import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pet validation', () {
    test('accepts a valid dog registration', () {
      final pet = Pet(
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
  });
}
