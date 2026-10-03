import 'dart:typed_data';

import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../widgets/pets/pets_theme.dart';

/// Dados de exemplo. Quando houver API, só este arquivo muda.
class VetRepository {
  VetRepository._();

  static String clientName = 'Liminha';
  static DateTime clientBirthDate = DateTime(2007, 2, 5);
  static String clientEmail = '';
  static String clientAddress = '';
  static String clientPhone = '';
  static String? clientPhotoPath;
  // No Web, o caminho do picker é temporário; conserva a foto nesta sessão.
  static Uint8List? clientPhotoBytes;
  static int selectedPetIndex = 0;

  static final List<PetModel> pets = [
    PetModel(
      name: 'Fernando',
      imagePath: 'assets/imagens/figma/cachorroegatopng-3.png',
      description: _petSummary('Cachorro', 14, true),
      species: 'Cachorro',
      sex: 'M',
      weightKg: 24,
      birthDate: DateTime(2012, 3, 23),
      breed: 'Lulu-da-Pomerânia',
      neutered: true,
    ),
    PetModel(
      name: 'Kelly',
      imagePath: 'assets/imagens/figma/cachorroegatopng-2.png',
      description: _petSummary('Gato', 2, false),
      species: 'Gato',
      sex: 'Fêmea',
      weightKg: 4.2,
      breed: 'Sem raça definida',
      neutered: false,
    ),
    PetModel(
      name: 'Escarola',
      imagePath: 'assets/imagens/figma/cachorroegatopng-3.png',
      description: _petSummary('Cachorro', 6, true),
      species: 'Cachorro',
      sex: 'Fêmea',
      weightKg: 18,
      breed: 'Sem raça definida',
      neutered: true,
    ),
    PetModel(
      name: 'Eduardido',
      imagePath: 'assets/imagens/figma/cachorroegatopng-2.png',
      description: _petSummary('Gato', 1, false),
      species: 'Gato',
      sex: 'Macho',
      weightKg: 3.4,
      breed: 'Sem raça definida',
      neutered: false,
    ),
  ];

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
    final model = pets.where((item) => item.name == pet).firstOrNull;
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

  static bool authenticate(String email, String password) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim()) &&
      password.trim().length >= 6;

  static void registerClient(Map<String, String> values) {
    clientName = values['Nome Completo']?.trim().isNotEmpty == true
        ? values['Nome Completo']!.trim()
        : clientName;
    clientEmail = values['E-mail']?.trim() ?? clientEmail;
    clientPhone = values['Telefone/Celular']?.trim() ?? clientPhone;
    clientAddress = [
      values['Endereço'],
      values['Número'],
      values['Complemento'],
      values['Cidade'],
      values['CEP'],
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');
    final birth = values['Data de Nascimento'];
    if (birth != null) clientBirthDate = _parseDate(birth) ?? clientBirthDate;
  }

  static void updateClient({
    String? name,
    DateTime? birthDate,
    String? address,
    String? phone,
  }) {
    if (name != null) clientName = name;
    if (birthDate != null) clientBirthDate = birthDate;
    if (address != null) clientAddress = address;
    if (phone != null) clientPhone = phone;
  }

  static PetModel addPet({
    required String name,
    required String species,
    required String sex,
    required double weightKg,
    required DateTime birthDate,
    required String breed,
  }) {
    if (petNameExists(name)) {
      throw ArgumentError.value(
        name,
        'name',
        'Já existe um pet com esse nome.',
      );
    }
    final pet = PetModel(
      name: name.trim(),
      imagePath: species.toLowerCase().contains('gato')
          ? PetsTheme.imgCachorroegatoPng36x32
          : PetsTheme.imgCachorroegatoPng,
      description: '$species • ${_age(birthDate)} anos • $sex',
      species: species,
      sex: sex,
      weightKg: weightKg,
      birthDate: birthDate,
      breed: breed,
    );
    pets.add(pet);
    _perfis[pet.name] = PetProfile(
      especie: species,
      idadeAnos: _age(birthDate),
      castrado: false,
      pesoKg: weightKg,
    );
    return pet;
  }

  static bool petNameExists(String name, {String? except}) => pets.any(
    (pet) =>
        pet.name.toLowerCase() == name.trim().toLowerCase() &&
        pet.name.toLowerCase() != except?.toLowerCase(),
  );

  static void updatePet(PetModel previous, PetModel updated) {
    final index = pets.indexOf(previous);
    if (index < 0) return;
    pets[index] = updated;
    _perfis.remove(previous.name);
    final appointments = _novosAgendamentos.remove(previous.name);
    if (appointments != null) {
      _novosAgendamentos[updated.name] = appointments;
    }
    if (updated.weightKg != null) {
      _perfis[updated.name] = PetProfile(
        especie: updated.species ?? 'Cachorro',
        idadeAnos: updated.birthDate == null ? 0 : _age(updated.birthDate!),
        castrado: updated.neutered ?? false,
        pesoKg: updated.weightKg!,
      );
    }
  }

  static void removePet(PetModel pet) {
    pets.remove(pet);
    _perfis.remove(pet.name);
    _novosAgendamentos.remove(pet.name);
    selectedPetIndex = pets.isEmpty
        ? 0
        : selectedPetIndex.clamp(0, pets.length - 1).toInt();
  }

  static void addAgendamento(String pet, Agendamento agendamento) {
    _novosAgendamentos.putIfAbsent(pet, () => []).add(agendamento);
  }

  static DateTime? _parseDate(String value) {
    final parts = value.trim().split(RegExp(r'[/.-]'));
    if (parts.length != 3) return DateTime.tryParse(value);
    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    final c = int.tryParse(parts[2]);
    if (a == null || b == null || c == null) return null;
    final yearFirst = a > 31;
    final date = yearFirst ? DateTime(a, b, c) : DateTime(c, b, a);
    final expectedDay = yearFirst ? c : a;
    if (date.year < 1900 ||
        date.month != b ||
        date.day != expectedDay ||
        date.isAfter(DateTime.now())) {
      return null;
    }
    return date;
  }

  static int _age(DateTime date) {
    final today = DateTime.now();
    var years = today.year - date.year;
    if (today.month < date.month ||
        (today.month == date.month && today.day < date.day)) {
      years--;
    }
    return years;
  }

  static String _petSummary(String species, int age, bool neutered) {
    return '$species • $age ${age == 1 ? 'ano' : 'anos'} • '
        '${neutered ? 'Castrado' : 'Não castrado'}';
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
