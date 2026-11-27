import '../../models/pet_model.dart';
import '../../models/service_catalog.dart';
import '../../models/vet_models.dart';

/// Dados de exemplo (modo demonstração) de consultas, agenda e vacinas.
/// Nada daqui é salvo nem ocupa horários reais.
class VetDemoData {
  VetDemoData._();

  static DateTime get _hoje {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static List<Consulta> consultas() => [
    Consulta(
      data: _hoje.subtract(const Duration(days: 15)),
      tipo: 'Consulta Geral',
      veterinario: 'Dra. Ana Silva',
      descricao: 'Checkup completo. Tudo normal.',
      isDemonstration: true,
    ),
    Consulta(
      data: _hoje.subtract(const Duration(days: 60)),
      tipo: 'Vermifugação',
      veterinario: 'Dr. João Mendes',
      descricao: 'Tratamento realizado com sucesso.',
      isDemonstration: true,
    ),
    Consulta(
      data: _hoje.subtract(const Duration(days: 95)),
      tipo: 'Pesagem e avaliação',
      veterinario: 'Dra. Clara Lima',
      descricao: 'Peso estável e bem hidratado.',
      isDemonstration: true,
    ),
  ];

  /// Eventos fixos de exemplo; são recriados a cada chamada.
  static List<Agendamento> agendamentos() => [
    Agendamento(
      data: _hoje.add(const Duration(days: 5, hours: 14, minutes: 30)),
      tipo: 'Consulta Geral',
      veterinario: 'Dra. Ana Silva',
      local: 'Clínica VetHome',
      status: StatusAgendamento.confirmado,
    ),
    Agendamento(
      data: _hoje.add(const Duration(days: 20, hours: 10)),
      tipo: 'Vacinação',
      veterinario: 'Dr. João Mendes',
      local: 'Unidade Central',
      status: StatusAgendamento.pendente,
    ),
  ];

  static List<Vacina> vacinas(PetSpecies? species) =>
      [
            Vacina(
              nome: 'V10',
              aplicada: _hoje.subtract(const Duration(days: 200)),
              proxima: _hoje.add(const Duration(days: 165)),
            ),
            Vacina(
              nome: 'Antirrábica',
              aplicada: _hoje.subtract(const Duration(days: 120)),
              proxima: _hoje.add(const Duration(days: 245)),
            ),
            Vacina(
              nome: 'Giardia',
              aplicada: _hoje.subtract(const Duration(days: 150)),
              proxima: _hoje.add(const Duration(days: 20)),
            ),
            Vacina(
              nome: 'V4',
              aplicada: _hoje.subtract(const Duration(days: 150)),
              proxima: _hoje.add(const Duration(days: 20)),
            ),
          ]
          .where(
            (sample) =>
                ServiceCatalog.vaccinesFor(species).contains(sample.nome),
          )
          .toList();
}
