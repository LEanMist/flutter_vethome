// lib/models/pet_model.dart
// Modelo simples usado pela PetsPage e pelo PetCardWidget.

import 'json_fields.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imagePath': imagePath,
    'description': description,
    'species': species,
    'sex': sex,
    'weightKg': weightKg,
    'birthDate': birthDate?.toIso8601String(),
    'breed': breed,
    'neutered': neutered,
    'ageYears': ageYears,
  };

  factory PetModel.fromJson(Map<String, dynamic> json) {
    final id = jsonString(json, 'id');
    if (id.trim().isEmpty) throw const FormatException('ID do pet vazio');
    return PetModel(
      id: id,
      name: jsonString(json, 'name'),
      imagePath: jsonString(json, 'imagePath'),
      description: jsonString(json, 'description'),
      species: jsonOptionalString(json, 'species'),
      sex: jsonOptionalString(json, 'sex'),
      weightKg: jsonOptionalDouble(json, 'weightKg'),
      birthDate: json['birthDate'] == null ? null : jsonDate(json, 'birthDate'),
      breed: jsonOptionalString(json, 'breed'),
      neutered: jsonOptionalBool(json, 'neutered'),
      ageYears: jsonOptionalInt(json, 'ageYears'),
    );
  }

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
