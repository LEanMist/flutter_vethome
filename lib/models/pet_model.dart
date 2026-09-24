// lib/models/pet_model.dart
// Modelo simples usado pela PetsPage e pelo PetCardWidget.

class PetModel {
  final String name;
  final String imagePath;
  final String description;

  const PetModel({
    required this.name,
    required this.imagePath,
    required this.description,
  });
}
