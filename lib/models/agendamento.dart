enum CategoriaServico {
  exames,
  vacinas,
  microchipagem,
  atestados;

  String get label => switch (this) {
    CategoriaServico.exames => 'Exames',
    CategoriaServico.vacinas => 'Vacinas',
    CategoriaServico.microchipagem => 'Microchipagem',
    CategoriaServico.atestados => 'Atestados',
  };
}

enum ConvenioAgendamento { petlove, doglife, particular }

enum StatusAgendamento { solicitado, confirmado, cancelado, concluido }

class ServicoAgendamento {
  const ServicoAgendamento({
    required this.id,
    required this.categoria,
    required this.nome,
  });

  final String id;
  final CategoriaServico categoria;
  final String nome;

  List<String> get errors => [
    if (id.trim().isEmpty) 'O serviço precisa de um identificador.',
    if (nome.trim().isEmpty) 'O serviço precisa de um nome.',
  ];

  Map<String, Object?> toMap() => {
    'id': id,
    'categoria': categoria.name,
    'nome': nome,
  };

  factory ServicoAgendamento.fromMap(Map<String, Object?> map) {
    return ServicoAgendamento(
      id: map['id'] as String,
      categoria: CategoriaServico.values.byName(map['categoria'] as String),
      nome: map['nome'] as String,
    );
  }
}

class AgendamentoRascunho {
  AgendamentoRascunho({
    required this.usuarioId,
    required this.petId,
    required DateTime data,
    required this.horario,
  }) : data = DateTime(data.year, data.month, data.day);

  final String usuarioId;
  final String petId;
  final DateTime data;
  final String horario;

  List<String> get errors {
    final validationErrors = <String>[];
    final hoje = DateTime.now();
    final dataSemHora = DateTime(hoje.year, hoje.month, hoje.day);

    if (usuarioId.trim().isEmpty) {
      validationErrors.add('O agendamento precisa de um usuário.');
    }
    if (petId.trim().isEmpty) {
      validationErrors.add('O agendamento precisa de um pet.');
    }
    if (data.isBefore(dataSemHora)) {
      validationErrors.add('A data do agendamento não pode estar no passado.');
    }
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(horario)) {
      validationErrors.add('Informe um horário válido no formato HH:mm.');
    }

    return List<String>.unmodifiable(validationErrors);
  }

  Agendamento finalizar({
    required List<ServicoAgendamento> servicos,
    required ConvenioAgendamento convenio,
  }) {
    return Agendamento(
      usuarioId: usuarioId,
      petId: petId,
      data: data,
      horario: horario,
      servicos: servicos,
      convenio: convenio,
    );
  }
}

class Agendamento {
  Agendamento({
    this.id,
    required this.usuarioId,
    required this.petId,
    required DateTime data,
    required this.horario,
    required List<ServicoAgendamento> servicos,
    required this.convenio,
    this.status = StatusAgendamento.solicitado,
    DateTime? criadoEm,
  }) : data = DateTime(data.year, data.month, data.day),
       servicos = List<ServicoAgendamento>.unmodifiable(servicos),
       criadoEm = criadoEm ?? DateTime.now();

  final String? id;
  final String usuarioId;
  final String petId;
  final DateTime data;
  final String horario;
  final List<ServicoAgendamento> servicos;
  final ConvenioAgendamento convenio;
  final StatusAgendamento status;
  final DateTime criadoEm;

  List<String> get errors {
    final validationErrors = <String>[];
    final hoje = DateTime.now();
    final dataSemHora = DateTime(hoje.year, hoje.month, hoje.day);

    if (usuarioId.trim().isEmpty) {
      validationErrors.add('O agendamento precisa de um usuário.');
    }
    if (petId.trim().isEmpty) {
      validationErrors.add('O agendamento precisa de um pet.');
    }
    if (data.isBefore(dataSemHora)) {
      validationErrors.add('A data do agendamento não pode estar no passado.');
    }
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(horario)) {
      validationErrors.add('Informe um horário válido no formato HH:mm.');
    }
    if (servicos.isEmpty) {
      validationErrors.add('Selecione pelo menos um serviço.');
    }
    for (final servico in servicos) {
      validationErrors.addAll(servico.errors);
    }
    if (servicos.map((servico) => servico.id).toSet().length !=
        servicos.length) {
      validationErrors.add('Não repita o mesmo serviço.');
    }

    return List<String>.unmodifiable(validationErrors);
  }

  Agendamento copyWith({
    String? id,
    String? usuarioId,
    String? petId,
    DateTime? data,
    String? horario,
    List<ServicoAgendamento>? servicos,
    ConvenioAgendamento? convenio,
    StatusAgendamento? status,
    DateTime? criadoEm,
  }) {
    return Agendamento(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      petId: petId ?? this.petId,
      data: data ?? this.data,
      horario: horario ?? this.horario,
      servicos: servicos ?? this.servicos,
      convenio: convenio ?? this.convenio,
      status: status ?? this.status,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'usuarioId': usuarioId,
    'petId': petId,
    'data': data.toIso8601String(),
    'horario': horario,
    'servicos': servicos.map((servico) => servico.toMap()).toList(),
    'convenio': convenio.name,
    'status': status.name,
    'criadoEm': criadoEm.toIso8601String(),
  };

  factory Agendamento.fromMap(Map<String, Object?> map) {
    final servicos = (map['servicos'] as List<Object?>? ?? const [])
        .map(
          (servico) => ServicoAgendamento.fromMap(
            Map<String, Object?>.from(servico! as Map),
          ),
        )
        .toList();

    return Agendamento(
      id: map['id'] as String?,
      usuarioId: map['usuarioId'] as String,
      petId: map['petId'] as String,
      data: DateTime.parse(map['data'] as String),
      horario: map['horario'] as String,
      servicos: servicos,
      convenio: ConvenioAgendamento.values.byName(map['convenio'] as String),
      status: StatusAgendamento.values.byName(
        map['status'] as String? ?? StatusAgendamento.solicitado.name,
      ),
      criadoEm: DateTime.parse(map['criadoEm'] as String),
    );
  }
}
