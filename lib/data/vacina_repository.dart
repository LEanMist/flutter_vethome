import '../models/pet_model.dart';
import '../models/vet_models.dart';
import 'mock/vet_demo_data.dart';
import 'pet_repository.dart';

/// Vacinas registradas pelo usuário, por pet. Enquanto o pet não tem registro
/// próprio, mostra vacinas de exemplo da espécie. Não grava nada em disco:
/// quem persiste é o [VetRepository], que chama estes métodos e depois salva.
class VacinaRepository {
  VacinaRepository._();

  static final Map<String, List<Vacina>> _porPet = {};
  static final Set<String> _demoDispensadasPetIds = {};
  static int _contador = 0;

  static List<Vacina> reais(String petId) => PetRepository.petById(petId) == null
      ? []
      : List.unmodifiable(_porPet[petId] ?? []);

  static void salvar(String petId, Vacina vaccine) {
    if (PetRepository.petById(petId) == null) {
      throw ArgumentError('Pet não encontrado.');
    }
    if (vaccine.id != null &&
        (vaccine.id!.trim().isEmpty ||
            _porPet.entries.any(
              (entry) =>
                  entry.key != petId &&
                  entry.value.any((v) => v.id == vaccine.id),
            ))) {
      throw const FormatException(
        'Vacina pertence a outro pet ou possui ID inválido.',
      );
    }
    final today = DateTime.now();
    final endToday = DateTime(today.year, today.month, today.day + 1);
    if (vaccine.nome.trim().isEmpty ||
        vaccine.aplicada.year < 1900 ||
        !vaccine.aplicada.isBefore(endToday) ||
        (vaccine.proxima != null &&
            vaccine.proxima!.isBefore(vaccine.aplicada))) {
      throw const FormatException('Confira as datas e o nome da vacina.');
    }
    final records = _porPet.putIfAbsent(petId, () => []);
    final id =
        vaccine.id ??
        'vaccine-${DateTime.now().microsecondsSinceEpoch}-${_contador++}';
    final index = records.indexWhere((v) => v.id == id);
    final record = Vacina(
      id: id,
      nome: vaccine.nome.trim(),
      aplicada: vaccine.aplicada,
      proxima: vaccine.proxima,
    );
    if (index < 0) {
      records.add(record);
    } else {
      records[index] = record;
    }
  }

  static void remover(String petId, String vaccineId) {
    final vaccines = _porPet[petId];
    final previousLength = vaccines?.length ?? 0;
    vaccines?.removeWhere((v) => v.id == vaccineId);
    if (vaccines != null &&
        vaccines.isEmpty &&
        vaccines.length < previousLength) {
      _demoDispensadasPetIds.add(petId);
    }
  }

  static bool usaDemonstracao(String petId) =>
      PetSpecies.parse(PetRepository.petById(petId)?.species) != null &&
      reais(petId).isEmpty &&
      !_demoDispensadasPetIds.contains(petId);

  /// Vacinas de exemplo (se o pet ainda não tem registro) ou as reais.
  static List<Vacina> listar(String petId) => usaDemonstracao(petId)
      ? VetDemoData.vacinas(
          PetSpecies.parse(PetRepository.petById(petId)?.species),
        )
      : reais(petId);

  static void removeDoPet(String petId) {
    _porPet.remove(petId);
    _demoDispensadasPetIds.remove(petId);
  }

  static void clear() {
    _porPet.clear();
    _demoDispensadasPetIds.clear();
  }

  /// Cópias para gravar no armazenamento local.
  static Map<String, List<Vacina>> snapshot() => {
    for (final entry in _porPet.entries) entry.key: List.of(entry.value),
  };

  static Set<String> demoDispensadasSnapshot() =>
      Set.of(_demoDispensadasPetIds);

  /// Substitui tudo pelo conteúdo lido do armazenamento local.
  static void restore(
    Map<String, List<Vacina>> vaccinations,
    Set<String> demoDispensadas,
  ) {
    _porPet
      ..clear()
      ..addAll({
        for (final entry in vaccinations.entries)
          entry.key: List.of(entry.value),
      });
    _demoDispensadasPetIds
      ..clear()
      ..addAll(demoDispensadas);
  }
}
