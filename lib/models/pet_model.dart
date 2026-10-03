// lib/models/pet_model.dart
// Modelo simples usado pela PetsPage e pelo PetCardWidget.

class PetModel {
  final String name;
  final String imagePath;
  final String description;
  final String? species;
  final String? sex;
  final double? weightKg;
  final DateTime? birthDate;
  final String? breed;
  final bool? neutered;

  const PetModel({
    required this.name,
    required this.imagePath,
    required this.description,
    this.species,
    this.sex,
    this.weightKg,
    this.birthDate,
    this.breed,
    this.neutered,
  });
}
