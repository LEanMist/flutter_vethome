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

  factory PetModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['nome'] ?? json['name'] ?? '';
    final rawSpecies = json['especie'] ?? json['species'];
    final rawSex = json['sexo'] ?? json['sex'];
    final rawWeight = json['peso'] ?? json['weightKg'] ?? json['weight'];
    final rawBreed = json['raca'] ?? json['breed'];
    final rawBirth = json['dataNasc'] ?? json['birthDate'] ?? json['nascimento'];

    final birthDate = rawBirth == null || rawBirth.toString().trim().isEmpty
        ? null
        : DateTime.tryParse(rawBirth.toString());

    final weightKg = rawWeight == null
        ? null
        : rawWeight is num
            ? rawWeight.toDouble()
            : double.tryParse(rawWeight.toString());

    final species = rawSpecies?.toString();
    final description = species == null || species.trim().isEmpty
        ? 'Pet'
        : '$species • ${birthDate == null ? 'idade não informada' : _describeAge(birthDate)}';

    return PetModel(
      name: rawName.toString(),
      imagePath: '',
      description: description,
      species: species,
      sex: rawSex?.toString(),
      weightKg: weightKg,
      birthDate: birthDate,
      breed: rawBreed?.toString(),
      neutered: null,
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': name,
        'especie': species,
        'sexo': sex,
        'peso': weightKg,
        'raca': breed,
        'dataNasc': birthDate?.toIso8601String(),
      };

  static String _describeAge(DateTime birthDate) {
    final now = DateTime.now();
    var years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return '$years anos';
  }
}
