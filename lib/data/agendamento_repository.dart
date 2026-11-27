import '../models/vet_models.dart';
import 'mock/vet_demo_data.dart';
import 'pet_repository.dart';

/// Consultas agendadas pelo usuário, por pet. Guarda só os agendamentos reais;
/// os eventos de exemplo vêm de [VetDemoData]. Não grava nada em disco: quem
/// persiste é o [VetRepository], que chama estes métodos e depois salva.
class AgendamentoRepository {
  AgendamentoRepository._();

  static final Map<String, List<Agendamento>> _porPet = {};

  /// Somente os agendamentos criados pelo usuário.
  static List<Agendamento> reais(String petId) {
    if (PetRepository.petById(petId) == null) return [];
    return List.unmodifiable(_porPet[petId] ?? []);
  }

  /// Eventos de exemplo + agendamentos reais do pet.
  static List<Agendamento> listar(String petId) {
    if (PetRepository.petById(petId) == null) return [];
    return [...VetDemoData.agendamentos(), ...?_porPet[petId]];
  }

  /// Histórico de consultas de exemplo (igual para todos os pets).
  static List<Consulta> consultas(String petId) => VetDemoData.consultas();

  static void adicionar(String petId, Agendamento agendamento) {
    if (PetRepository.petById(petId) == null) {
      throw ArgumentError('Pet não encontrado.');
    }
    _porPet.putIfAbsent(petId, () => []).add(agendamento);
  }

  /// Remove somente a mesma consulta salva (por identidade); eventos de
  /// demonstração não ficam na lista do repositório.
  static bool remover(String petId, Agendamento agendamento) {
    final appointments = _porPet[petId];
    if (appointments == null) return false;
    final index = appointments.indexWhere(
      (candidate) => identical(candidate, agendamento),
    );
    if (index < 0) return false;
    appointments.removeAt(index);
    if (appointments.isEmpty) _porPet.remove(petId);
    return true;
  }

  /// Confere conflitos somente contra consultas criadas pelo usuário.
  /// Eventos de demonstração não ocupam horários reais.
  static bool temConflito({
    required String petId,
    required String veterinarian,
    required DateTime start,
    required DateTime end,
  }) {
    if (!end.isAfter(start)) return true;
    final requestedVeterinarian = veterinarian.trim().toLowerCase();
    for (final entry in _porPet.entries) {
      for (final existing in entry.value) {
        final samePet = entry.key == petId;
        final sameVeterinarian =
            existing.veterinario.trim().toLowerCase() == requestedVeterinarian;
        if (!samePet && !sameVeterinarian) continue;
        final existingEnd =
            existing.endDate ?? existing.data.add(const Duration(hours: 1));
        if (start.isBefore(existingEnd) && existing.data.isBefore(end)) {
          return true;
        }
      }
    }
    return false;
  }

  static void removeDoPet(String petId) => _porPet.remove(petId);

  static void clear() => _porPet.clear();

  /// Cópia dos agendamentos, para gravar no armazenamento local.
  static Map<String, List<Agendamento>> snapshot() => {
    for (final entry in _porPet.entries) entry.key: List.of(entry.value),
  };

  /// Substitui tudo pelo conteúdo lido do armazenamento local.
  static void restore(Map<String, List<Agendamento>> data) {
    _porPet
      ..clear()
      ..addAll({
        for (final entry in data.entries) entry.key: List.of(entry.value),
      });
  }
}
