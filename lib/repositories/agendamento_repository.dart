import '../models/agendamento.dart';

abstract class AgendamentoRepository {
  Future<List<Agendamento>> findAll();
  Future<List<Agendamento>> findByUsuarioId(String usuarioId);
  Future<List<Agendamento>> findByPetId(String petId);
  Future<Agendamento?> findById(String id);
  Future<Agendamento> save(Agendamento agendamento);
  Future<void> delete(String id);
}

class HorarioOcupadoException implements Exception {
  const HorarioOcupadoException();

  @override
  String toString() => 'Este horário já foi agendado. Escolha outro horário.';
}

class HorarioPassadoException implements Exception {
  const HorarioPassadoException();

  @override
  String toString() => 'Este horário já passou. Escolha outro horário.';
}

bool _mesmoDia(DateTime primeira, DateTime segunda) =>
    primeira.year == segunda.year &&
    primeira.month == segunda.month &&
    primeira.day == segunda.day;

extension HorariosAgendados on AgendamentoRepository {
  Future<Set<String>> horariosOcupados(DateTime data) async {
    final agendamentos = await findAll();
    return {
      for (final agendamento in agendamentos)
        if (agendamento.status != StatusAgendamento.cancelado &&
            _mesmoDia(agendamento.data, data))
          agendamento.horario,
    };
  }
}

class InMemoryAgendamentoRepository implements AgendamentoRepository {
  InMemoryAgendamentoRepository({DateTime Function()? agora})
    : _agora = agora ?? DateTime.now;

  static final InMemoryAgendamentoRepository instance =
      InMemoryAgendamentoRepository();

  final Map<String, Agendamento> _agendamentos = <String, Agendamento>{};
  final DateTime Function() _agora;

  void _atualizarStatus() {
    final agora = _agora();
    for (final entrada in _agendamentos.entries) {
      final agendamento = entrada.value;
      if (agendamento.status == StatusAgendamento.ativo &&
          !agendamento.dataHoraConclusao.isAfter(agora)) {
        _agendamentos[entrada.key] = agendamento.copyWith(
          status: StatusAgendamento.concluido,
        );
      }
    }
  }

  @override
  Future<List<Agendamento>> findAll() async {
    _atualizarStatus();
    return List<Agendamento>.unmodifiable(_agendamentos.values);
  }

  @override
  Future<List<Agendamento>> findByUsuarioId(String usuarioId) async {
    _atualizarStatus();
    return List<Agendamento>.unmodifiable(
      _agendamentos.values.where(
        (agendamento) => agendamento.usuarioId == usuarioId,
      ),
    );
  }

  @override
  Future<List<Agendamento>> findByPetId(String petId) async {
    _atualizarStatus();
    return List<Agendamento>.unmodifiable(
      _agendamentos.values.where((agendamento) => agendamento.petId == petId),
    );
  }

  @override
  Future<Agendamento?> findById(String id) async {
    _atualizarStatus();
    return _agendamentos[id];
  }

  @override
  Future<Agendamento> save(Agendamento agendamento) async {
    _atualizarStatus();
    if (agendamento.errors.isNotEmpty) {
      throw ArgumentError(
        'Agendamento inválido: ${agendamento.errors.join('; ')}',
      );
    }

    final existente = agendamento.id == null
        ? null
        : _agendamentos[agendamento.id];
    final horarioAlterado =
        existente == null ||
        !_mesmoDia(existente.data, agendamento.data) ||
        existente.horario != agendamento.horario;
    if (horarioAlterado &&
        horarioJaPassou(
          agendamento.data,
          agendamento.horario,
          agora: _agora(),
        )) {
      throw const HorarioPassadoException();
    }

    if (agendamento.status != StatusAgendamento.cancelado &&
        _agendamentos.values.any(
          (existente) =>
              existente.id != agendamento.id &&
              existente.status != StatusAgendamento.cancelado &&
              _mesmoDia(existente.data, agendamento.data) &&
              existente.horario == agendamento.horario,
        )) {
      throw const HorarioOcupadoException();
    }

    final id =
        agendamento.id ??
        'agendamento-${DateTime.now().microsecondsSinceEpoch}-${_agendamentos.length}';
    final deveConcluir = agendamento.status == StatusAgendamento.ativo &&
        ((!horarioAlterado && existente.status == StatusAgendamento.concluido) ||
            !agendamento.dataHoraConclusao.isAfter(_agora()));
    final salvo = agendamento.copyWith(
      id: id,
      status: deveConcluir ? StatusAgendamento.concluido : agendamento.status,
    );
    _agendamentos[id] = salvo;
    return salvo;
  }

  @override
  Future<void> delete(String id) async {
    _agendamentos.remove(id);
  }
}
