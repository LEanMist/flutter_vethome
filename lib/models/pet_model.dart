// lib/models/pet_model.dart
// Modelo simples usado pela PetsPage e pelo PetCardWidget.

import 'json_fields.dart';
import '../core/utils/pet_photo.dart';

enum PetSpecies {
  dog,
  cat;

  static PetSpecies? parse(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'cachorro' || 'cão' || 'cao' || 'dog' || 'canino' => dog,
        'gato' || 'cat' || 'felino' => cat,
        _ => null,
      };
}

class PetModel {
  static int _nextId = 0;

  final String id;
  final String name;
  final String imagePath;
  final String description;
  final String? photoBase64;
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
    this.photoBase64,
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
    if (photoBase64 != null) 'photoBase64': photoBase64,
    'species': species,
    'sex': sex,
    'weightKg': weightKg,
    'birthDate': birthDate?.toIso8601String(),
    'breed': breed,
    'neutered': neutered,
    'ageYears': ageYears,
  };

  factory PetModel.fromJson(Map<String, dynamic> json) {
    // A API Spring usa nome/id/dataNasc/especie/raca; snapshots locais
    // antigos usam name/id/birthDate/species/breed.
    final rawId = json['id'];
    final id = rawId?.toString() ?? '';
    if (id.trim().isEmpty) throw const FormatException('ID do pet vazio');

    final name = (json['nome'] ?? json['name'] ?? '').toString();
    final species = (json['especie'] ?? json['species'])?.toString();
    final sex = (json['sexo'] ?? json['sex'])?.toString();
    final breed = (json['raca'] ?? json['breed'])?.toString();
    final rawWeight = json['peso'] ?? json['weightKg'];
    final weight = rawWeight is num
        ? rawWeight.toDouble()
        : double.tryParse(rawWeight?.toString().replaceAll(',', '.') ?? '');
    final rawBirth = json['dataNasc'] ?? json['birthDate'];
    final birth = rawBirth == null
        ? null
        : DateTime.tryParse(rawBirth.toString());

    return PetModel(
      id: id,
      name: name,
      imagePath: (json['imagePath'] ??
              'assets/imagens/pets/img_cachorroegato_png.png')
          .toString(),
      description: (json['description'] ??
              [species, breed, sex].where((v) => v != null && v.toString().trim().isNotEmpty).join(' • '))
          .toString(),
      photoBase64: _photo(json),
      species: species,
      sex: sex,
      weightKg: weight,
      birthDate: birth,
      breed: breed,
      neutered: json['neutered'] is bool ? json['neutered'] as bool : null,
      ageYears: jsonOptionalInt(json, 'ageYears'),
    );
  }

  static String? _photo(Map<String, dynamic> json) {
    final value = json['photoBase64'];
    return value is String && PetPhoto.isValid(value) ? value : null;
  }

  PetModel copyWith({
    String? photoBase64,
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
    photoBase64: photoBase64 ?? this.photoBase64,
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
