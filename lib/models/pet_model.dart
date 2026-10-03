// lib/models/pet_model.dart
// Modelo simples usado pela PetsPage e pelo PetCardWidget.

class PetModel {
  static int _nextId = 0;

  final String id;
  final String name;
  final String imagePath;
  final String description;
  final String? species;
  final String? sex;
  final double? weightKg;
  final DateTime? birthDate;
  final String? breed;
  final bool? neutered;
  // Apenas para exemplos antigos sem nascimento conhecido.
  final int? ageYears;

  PetModel({
    String? id,
    required this.name,
    required this.imagePath,
    required this.description,
    this.species,
    this.sex,
    this.weightKg,
    this.birthDate,
    this.breed,
    this.neutered,
    this.ageYears,
  }) : id = id ?? 'pet-${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';

  PetModel copyWith({
    String? name,
    String? imagePath,
    String? description,
    String? species,
    String? sex,
    double? weightKg,
    DateTime? birthDate,
    String? breed,
    bool? neutered,
  }) => PetModel(
    id: id,
    name: name ?? this.name,
    imagePath: imagePath ?? this.imagePath,
    description: description ?? this.description,
    species: species ?? this.species,
    sex: sex ?? this.sex,
    weightKg: weightKg ?? this.weightKg,
    birthDate: birthDate ?? this.birthDate,
    breed: breed ?? this.breed,
    neutered: neutered ?? this.neutered,
    ageYears: ageYears,
  );
}
