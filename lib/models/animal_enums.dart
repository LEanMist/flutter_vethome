enum AnimalType {
  cachorro,
  gato,
}

extension AnimalTypeX on AnimalType {
  String get label => switch (this) {
        AnimalType.cachorro => 'Cachorro',
        AnimalType.gato => 'Gato',
      };

  static AnimalType fromLabel(String value) {
    return AnimalType.values.firstWhere(
      (animal) => animal.label.toLowerCase() == value.trim().toLowerCase(),
      orElse: () => AnimalType.cachorro,
    );
  }
}

enum AnimalSex {
  macho,
  femea,
}

extension AnimalSexX on AnimalSex {
  String get label => switch (this) {
        AnimalSex.macho => 'Macho',
        AnimalSex.femea => 'Fêmea',
      };

  static AnimalSex fromLabel(String value) {
    return AnimalSex.values.firstWhere(
      (animal) => animal.label.toLowerCase() == value.trim().toLowerCase(),
      orElse: () => AnimalSex.femea,
    );
  }
}
