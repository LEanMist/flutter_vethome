import 'pet_model.dart';

class ServiceCatalog {
  ServiceCatalog._();

  static const commonExams = [
    'Hemograma',
    'Ureia',
    'Creatinina',
    'ALT',
    'GGT',
    'Fosfatase alcalina',
    'Colesterol',
    'Triglicerídeos',
    'Urina tipo 1',
    'Coproparasitológico',
  ];
  static const felineExam = 'FIV e FeLV';
  static const dogVaccines = [
    'V8',
    'V10',
    'Antirrábica',
    'Giardia',
    'Gripe injetável',
    'Gripe oral ou intranasal',
  ];
  static const catVaccines = ['V5', 'V4', 'V3', 'Antirrábica'];

  static List<String> vaccinesFor(PetSpecies? species) => switch (species) {
    PetSpecies.dog => dogVaccines,
    PetSpecies.cat => catVaccines,
    null => const [],
  };

  static Map<String, List<String>> categoriesFor(PetSpecies? species) => {
    'Exames': species == PetSpecies.cat
        ? const [felineExam, ...commonExams]
        : commonExams,
    'Vacinas': vaccinesFor(species),
    'Microchipagem': const ['Microchipagem'],
    'Atestados': const ['Atestado'],
  };

  static String? detailType(String service) {
    if (dogVaccines.contains(service) || catVaccines.contains(service)) {
      return 'Vacina';
    }
    if (commonExams.contains(service) ||
        service == felineExam ||
        service == 'Urina') {
      return 'Exame';
    }
    return null;
  }
}
