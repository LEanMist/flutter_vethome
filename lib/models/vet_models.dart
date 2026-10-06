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
  final bool? castrado;
  final double? pesoKg;

  String get resumo =>
      '$especie • $idadeAnos ${idadeAnos == 1 ? 'ano' : 'anos'} • '
      '${castrado == null
          ? 'Castração não informada'
          : castrado!
          ? 'Castrado'
          : 'Não castrado'}';
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

enum VacinaStatus { emDia, vencendo, atrasada, semPrevisao }

class Vacina {
  const Vacina({
    this.id,
    required this.nome,
    required this.aplicada,
    this.proxima,
  });
  final String? id;
  final String nome;
  final DateTime aplicada;
  final DateTime? proxima;

  VacinaStatus get status {
    final next = proxima;
    if (next == null) return VacinaStatus.semPrevisao;
    final now = DateUtils.dateOnly(DateTime.now());
    final day = DateUtils.dateOnly(next);
    if (day.isBefore(now)) return VacinaStatus.atrasada;
    if (day.difference(now).inDays <= 30) return VacinaStatus.vencendo;
    return VacinaStatus.emDia;
  }

  Map<String, dynamic> toJson({required String petId}) => {
    'id': id,
    'petId': petId,
    'nome': nome,
    'aplicada': aplicada.toIso8601String(),
    if (proxima != null) 'proxima': proxima!.toIso8601String(),
  };

  factory Vacina.fromJson(Map<String, dynamic> json) {
    final id = jsonString(json, 'id');
    final name = jsonString(json, 'nome');
    final applied = jsonDate(json, 'aplicada');
    final next = json['proxima'] == null ? null : jsonDate(json, 'proxima');
    if (id.isEmpty ||
        name.trim().isEmpty ||
        (next != null && next.isBefore(applied))) {
      throw const FormatException('Vacina inválida');
    }
    return Vacina(id: id, nome: name, aplicada: applied, proxima: next);
  }
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

String contagemVacinas(List<Vacina> vaccines) {
  final good = vaccines.where((v) => v.status == VacinaStatus.emDia).length;
  final attention = vaccines.length - good;
  return '$good em dia · $attention ${attention == 1 ? 'precisa' : 'precisam'} de atenção';
}

Agendamento? proximoAgendamento(List<Agendamento> l) {
  final now = DateTime.now();
  final futuros = l.where((a) => a.data.isAfter(now)).toList()
    ..sort((a, b) => a.data.compareTo(b.data));
  return futuros.isEmpty ? null : futuros.first;
}
