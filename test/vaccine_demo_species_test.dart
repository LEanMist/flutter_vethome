import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await VetRepository.flush();
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  tearDown(() async => VetRepository.flush());

  test(
    'exemplos acompanham a espécie e não substituem registros reais',
    () async {
      final dog = VetRepository.addPet(
        name: 'Cão teste',
        species: 'Cachorro',
        sex: 'M',
        weightKg: 5,
        birthDate: DateTime(2020),
        breed: 'SRD',
      );
      final cat = VetRepository.addPet(
        name: 'Gato teste',
        species: 'Gato',
        sex: 'F',
        weightKg: 4,
        birthDate: DateTime(2020),
        breed: 'SRD',
      );
      final unknown = VetRepository.addPet(
        name: 'Outro teste',
        species: 'Outro',
        sex: 'M',
        weightKg: 4,
        birthDate: DateTime(2020),
        breed: 'SRD',
      );
      expect(VetRepository.vacinas(dog.id).map((v) => v.nome), [
        'V10',
        'Antirrábica',
        'Giardia',
      ]);
      expect(VetRepository.vacinas(cat.id).map((v) => v.nome), [
        'Antirrábica',
        'V4',
      ]);
      expect(VetRepository.usesDemoVaccines(unknown.id), isFalse);
      expect(VetRepository.vacinas(unknown.id), isEmpty);
      VetRepository.saveVaccine(
        cat.id,
        Vacina(nome: 'Registro real', aplicada: DateTime(2025)),
      );
      await VetRepository.flush();
      await VetRepository.initialize();
      expect(VetRepository.usesDemoVaccines(cat.id), isFalse);
      expect(VetRepository.vacinas(cat.id).single.nome, 'Registro real');
      expect(VetRepository.vacinas(dog.id).map((v) => v.nome), contains('V10'));
    },
  );
}
