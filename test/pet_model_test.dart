import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/pet_model.dart';

void main() {
  test('PetModel.fromJson converte uma resposta do backend corretamente', () {
    final pet = PetModel.fromJson({
      'id': 42,
      'nome': 'Fernando',
      'dataNasc': '2012-03-23',
      'especie': 'Cachorro',
      'sexo': 'M',
      'peso': 24.0,
      'raca': 'Lulu-da-Pomerânia',
    });

    expect(pet.name, 'Fernando');
    expect(pet.species, 'Cachorro');
    expect(pet.sex, 'M');
    expect(pet.weightKg, 24.0);
    expect(pet.breed, 'Lulu-da-Pomerânia');
    expect(pet.birthDate, DateTime(2012, 3, 23));
  });
}
