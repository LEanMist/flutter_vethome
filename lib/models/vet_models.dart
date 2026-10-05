import 'package:flutter/material.dart';

import 'json_fields.dart';

class PetProfile {
  const PetProfile({
    required this.especie,
    required this.idadeAnos,
    required this.castrado,
    required this.pesoKg,
  });

  final String especie;
  final int idadeAnos;
  final bool castrado;
  final double pesoKg;

  String get resumo =>
      '$especie • $idadeAnos ${idadeAnos == 1 ? 'ano' : 'anos'} • '
      '${castrado ? 'Castrado' : 'Não castrado'}';
}

class Consulta {
  const Consulta({
    required this.data,
    required this.tipo,
    required this.veterinario,
    required this.descricao,
  });
  final DateTime data;
  final String tipo;
  final String veterinario;
  final String descricao;
}

enum VacinaStatus { emDia, vencendo, atrasada }

class Vacina {
  const Vacina({
    required this.nome,
    required this.aplicada,
    required this.proxima,
  });
  final String nome;
  final DateTime aplicada;
  final DateTime proxima;

  VacinaStatus get status {
    final now = DateTime.now();
    if (proxima.isBefore(now)) return VacinaStatus.atrasada;
    if (proxima.difference(now).inDays <= 30) return VacinaStatus.vencendo;
    return VacinaStatus.emDia;
  }
}

enum CategoriaDespesa {
  saude('Saúde', Icons.local_hospital),
  alimentacao('Alimentação', Icons.restaurant),
  higiene('Higiene', Icons.bathtub),
  outros('Outros', Icons.pets);

  const CategoriaDespesa(this.label, this.icone);
  final String label;
  final IconData icone;
}

class Despesa {
  const Despesa({
    required this.data,
    required this.descricao,
    required this.valor,
    required this.categoria,
  });
  final DateTime data;
  final String descricao;
  final double valor;
  final CategoriaDespesa categoria;
}

enum StatusAgendamento { confirmado, pendente }

class Agendamento {
  const Agendamento({
    required this.data,
    required this.tipo,
    required this.veterinario,
    required this.local,
    required this.status,
    this.descricao,
    this.endDate,
  });
  final DateTime data; // data + hora
  final String tipo;
  final String veterinario;
  final String local;
  final StatusAgendamento status;
  final String? descricao;
  final DateTime? endDate;

  // O proprietário continua sendo a chave por ID no repositório.
  Map<String, dynamic> toJson({required String petId}) => {
    'petId': petId,
    'data': data.toIso8601String(),
    'tipo': tipo,
    'veterinario': veterinario,
    'local': local,
    'status': status.name,
    'descricao': descricao,
    if (endDate != null) 'endDate': endDate!.toIso8601String(),
  };

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    final statusName = jsonString(json, 'status');
    final status = StatusAgendamento.values
        .where((value) => value.name == statusName)
        .firstOrNull;
    if (status == null) throw const FormatException('Status inválido');
    return Agendamento(
      data: jsonDate(json, 'data'),
      tipo: jsonString(json, 'tipo'),
      veterinario: jsonString(json, 'veterinario'),
      local: jsonString(json, 'local'),
      status: status,
      descricao: jsonOptionalString(json, 'descricao'),
      endDate: json['endDate'] == null ? null : jsonDate(json, 'endDate'),
    );
  }
}

class ChatMessage {
  const ChatMessage({required this.fromClient, required this.text});

  final bool fromClient;
  final String text;
}

// ── Cálculos derivados (nada de texto fixo nas telas) ───────────────────────

bool vacinasEmDia(List<Vacina> v) =>
    v.every((e) => e.status == VacinaStatus.emDia);

String resumoVacinas(List<Vacina> v) {
  final n = v.where((e) => e.status != VacinaStatus.emDia).length;
  if (n == 0) return 'Todas as vacinas estão em dia';
  return n == 1
      ? '1 vacina precisa de atenção'
      : '$n vacinas precisam de atenção';
}

Agendamento? proximoAgendamento(List<Agendamento> l) {
  final now = DateTime.now();
  final futuros = l.where((a) => a.data.isAfter(now)).toList()
    ..sort((a, b) => a.data.compareTo(b.data));
  return futuros.isEmpty ? null : futuros.first;
}

bool mesmoMes(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

double totalDoMes(List<Despesa> l, [DateTime? ref]) {
  final r = ref ?? DateTime.now();
  return l
      .where((d) => mesmoMes(d.data, r))
      .fold(0.0, (sum, d) => sum + d.valor);
}
