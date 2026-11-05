import '../models/agendamento.dart';

abstract class AgendamentoRepository {
  Future<List<Agendamento>> findAll();
  Future<List<Agendamento>> findByUsuarioId(String usuarioId);
  Future<List<Agendamento>> findByPetId(String petId);
  Future<Agendamento?> findById(String id);
  Future<Agendamento> save(Agendamento agendamento);
  Future<void> delete(String id);
}

class InMemoryAgendamentoRepository implements AgendamentoRepository {
  InMemoryAgendamentoRepository();

  static final InMemoryAgendamentoRepository instance =
      InMemoryAgendamentoRepository();

  final Map<String, Agendamento> _agendamentos = <String, Agendamento>{};

  @override
  Future<List<Agendamento>> findAll() async =>
      List<Agendamento>.unmodifiable(_agendamentos.values);

  @override
  Future<List<Agendamento>> findByUsuarioId(String usuarioId) async =>
      List<Agendamento>.unmodifiable(
        _agendamentos.values.where(
          (agendamento) => agendamento.usuarioId == usuarioId,
        ),
      );

  @override
  Future<List<Agendamento>> findByPetId(String petId) async =>
      List<Agendamento>.unmodifiable(
        _agendamentos.values.where(
          (agendamento) => agendamento.petId == petId,
        ),
      );

  @override
  Future<Agendamento?> findById(String id) async => _agendamentos[id];

  @override
  Future<Agendamento> save(Agendamento agendamento) async {
    if (agendamento.errors.isNotEmpty) {
      throw ArgumentError(
        'Agendamento inválido: ${agendamento.errors.join('; ')}',
      );
    }

    final id =
        agendamento.id ??
        'agendamento-${DateTime.now().microsecondsSinceEpoch}-${_agendamentos.length}';
    final salvo = agendamento.copyWith(id: id);
    _agendamentos[id] = salvo;
    return salvo;
  }

  @override
  Future<void> delete(String id) async {
    _agendamentos.remove(id);
  }
}
