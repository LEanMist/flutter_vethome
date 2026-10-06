import '../models/pet.dart';

abstract class PetRepository {
  List<Pet> findAll();
  Pet? findById(String id);
  void save(Pet pet);
}

class InMemoryPetRepository implements PetRepository {
  InMemoryPetRepository();
  static final InMemoryPetRepository instance = InMemoryPetRepository();

  final Map<String, Pet> _pets = <String, Pet>{};

  @override
  List<Pet> findAll() => List<Pet>.unmodifiable(_pets.values);

  @override
  Pet? findById(String id) => _pets[id];

  @override
  void save(Pet pet) {
    if (pet.errors.isNotEmpty) {
      throw ArgumentError('Pet inválido: ${pet.errors.join('; ')}');
    }

    final id = pet.id ?? 'pet-${DateTime.now().microsecondsSinceEpoch}-${_pets.length}';
    _pets[id] = pet.copyWith(id: id);
  }
}
