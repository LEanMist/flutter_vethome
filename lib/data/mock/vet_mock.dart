import '../../models/vet_models.dart';
import '../pet_repository.dart';

/// Dados de exemplo (saúde, vacinas, despesas, agenda e chat) enquanto o backend
/// não tem esses endpoints. Cada grupo sai daqui quando ganhar uma API.
class VetMock {
  VetMock._();

  static const PetProfile _padrao = PetProfile(
    especie: 'Cachorro',
    idadeAnos: 4,
    castrado: true,
    pesoKg: 12.5,
  );

  static final Map<String, PetProfile> _perfis = {
    'Kelly': PetProfile(
      especie: 'Gato',
      idadeAnos: 2,
      castrado: false,
      pesoKg: 4.2,
    ),
    'Escarola': PetProfile(
      especie: 'Cachorro',
      idadeAnos: 6,
      castrado: true,
      pesoKg: 18.0,
    ),
    'Eduardido': PetProfile(
      especie: 'Gato',
      idadeAnos: 1,
      castrado: false,
      pesoKg: 3.4,
    ),
  };

  static final Map<String, List<Agendamento>> _novosAgendamentos = {};
  static final List<ChatMessage> chatMessages = [
    const ChatMessage(
      fromClient: false,
      text: 'Olá! Como está seu pet depois da última consulta?',
    ),
    const ChatMessage(
      fromClient: true,
      text: 'Está ótimo, comendo bem e brincando.',
    ),
    const ChatMessage(
      fromClient: false,
      text: 'Que bom! Lembre-se de agendar o retorno.',
    ),
  ];

  static void sendChatMessage(String text) {
    final message = text.trim();
    if (message.isNotEmpty) {
      chatMessages.add(ChatMessage(fromClient: true, text: message));
    }
  }

  static PetProfile perfil(String pet) {
    final saved = _perfis[pet];
    if (saved != null) return saved;
    final model =
        PetRepository.pets.where((item) => item.name == pet).firstOrNull;
    if (model == null) return _padrao;
    final age = model.birthDate == null
        ? _padrao.idadeAnos
        : DateTime.now().year - model.birthDate!.year;
    return PetProfile(
      especie: model.species ?? _padrao.especie,
      idadeAnos: age,
      castrado: model.neutered ?? _padrao.castrado,
      pesoKg: model.weightKg ?? _padrao.pesoKg,
    );
  }

  static void addAgendamento(String pet, Agendamento agendamento) {
    _novosAgendamentos.putIfAbsent(pet, () => []).add(agendamento);
  }

  static DateTime get _hoje {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static List<Consulta> consultas(String pet) => [
    Consulta(
      data: _hoje.subtract(const Duration(days: 15)),
      tipo: 'Consulta Geral',
      veterinario: 'Dra. Ana Silva',
      descricao: 'Checkup completo. Tudo normal.',
    ),
    Consulta(
      data: _hoje.subtract(const Duration(days: 60)),
      tipo: 'Vermifugação',
      veterinario: 'Dr. João Mendes',
      descricao: 'Tratamento realizado com sucesso.',
    ),
    Consulta(
      data: _hoje.subtract(const Duration(days: 95)),
      tipo: 'Pesagem e avaliação',
      veterinario: 'Dra. Clara Lima',
      descricao: 'Peso estável e bem hidratado.',
    ),
  ];

  static List<Vacina> vacinas(String pet) => [
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
  ];

  static List<Despesa> despesas(String pet) {
    final n = DateTime.now();
    final inicio = DateTime(n.year, n.month, 1);
    final lista = [
      Despesa(
        data: inicio.add(const Duration(days: 2)),
        descricao: 'Consulta Veterinária',
        valor: 150.00,
        categoria: CategoriaDespesa.saude,
      ),
      Despesa(
        data: inicio.add(const Duration(days: 1)),
        descricao: 'Ração premium',
        valor: 95.60,
        categoria: CategoriaDespesa.alimentacao,
      ),
      Despesa(
        data: inicio,
        descricao: 'Antipulgas',
        valor: 68.90,
        categoria: CategoriaDespesa.saude,
      ),
      Despesa(
        data: DateTime(n.year, n.month - 1, 20),
        descricao: 'Banho e tosa',
        valor: 80.00,
        categoria: CategoriaDespesa.higiene,
      ),
    ];
    lista.sort((a, b) => b.data.compareTo(a.data));
    return lista;
  }

  static List<Agendamento> agendamentos(String pet) => [
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
    ...?_novosAgendamentos[pet],
  ];
}
