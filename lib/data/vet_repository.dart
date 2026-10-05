import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;

import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../models/saved_address.dart';
import '../core/utils/pet_images.dart';
import '../core/utils/pet_photo.dart';
import '../core/utils/form_fields.dart';
import 'local_storage.dart';

/// Interface de dados das telas, com snapshot local após cada mutação suportada.
class VetRepository {
  VetRepository._();

  static LocalStorage? _storage;
  static Future<bool> _pendingSave = Future.value(true);
  static Object? lastPersistenceError;

  /// Deve terminar antes de runApp. Também permite simular reinício nos testes.
  static Future<void> initialize({LocalStorage? storage}) async {
    await flush();
    _storage = null;
    final local = storage ?? LocalStorage();
    final state = await local.load();
    clientName = state?.client.name ?? 'Liminha';
    clientBirthDate = state?.client.birthDate ?? DateTime(2007, 2, 5);
    clientAddress = state?.client.address ?? '';
    clientPhone = state?.client.phone ?? '';
    clientEmail = state?.client.email ?? '';
    clientGender = state?.client.gender ?? '';
    clientGenderCustom = state?.client.genderCustom ?? '';
    addresses
      ..clear()
      ..addAll(state?.client.addresses ?? []);
    clientPhotoPath = null;
    clientPhotoBytes = null;
    selectedPetId = null;
    pets
      ..clear()
      ..addAll(state?.pets ?? _demoPets());
    _novosAgendamentos
      ..clear()
      ..addAll(state?.appointments ?? {});
    _vaccines
      ..clear()
      ..addAll(state?.vaccinations ?? {});
    lastPersistenceError = null;
    _pendingSave = Future.value(true);
    _storage = local;
  }

  /// Aguarda a fila; false indica falha, sem lançar erro assíncrono nas telas.
  static Future<bool> flush() => _pendingSave;

  static void _save() {
    final storage = _storage;
    // Testes/telas isolados continuam podendo usar o repositório em memória.
    if (storage == null) return;
    final state = LocalState(
      client: ClientData(
        name: clientName,
        birthDate: clientBirthDate,
        address: clientAddress,
        phone: clientPhone,
        email: clientEmail,
        gender: clientGender,
        genderCustom: clientGenderCustom,
        addresses: List.of(addresses),
      ),
      pets: List.of(pets),
      appointments: {
        for (final entry in _novosAgendamentos.entries)
          entry.key: List.of(entry.value),
      },
      vaccinations: {
        for (final entry in _vaccines.entries) entry.key: List.of(entry.value),
      },
    );
    // Captura cada estado e serializa as gravações para evitar inversão de ordem.
    _pendingSave = _pendingSave.then((_) async {
      try {
        await storage.save(state);
        lastPersistenceError = null;
        return true;
      } catch (error) {
        lastPersistenceError = error;
        debugPrint('VetHome: falha ao salvar estado local.');
        return false;
      }
    });
  }

  static String clientName = 'Liminha';
  static DateTime clientBirthDate = DateTime(2007, 2, 5);
  static String clientEmail = '';
  static String clientAddress = '';
  static String clientPhone = '';
  static String clientGender = '';
  static String clientGenderCustom = '';
  static final List<SavedAddress> addresses = [];
  static String? clientPhotoPath;
  // No Web, o caminho do picker é temporário; conserva a foto nesta sessão.
  static Uint8List? clientPhotoBytes;
  static String? selectedPetId;

  static PetModel? petById(String id) =>
      pets.where((pet) => pet.id == id).firstOrNull;

  static PetModel? get selectedPet =>
      (selectedPetId == null ? null : petById(selectedPetId!)) ??
      pets.firstOrNull;

  // Compatibilidade com as telas antigas; a seleção é armazenada por ID.
  static int get selectedPetIndex =>
      pets.indexWhere((pet) => pet.id == selectedPet?.id);

  static set selectedPetIndex(int index) {
    selectedPetId = index >= 0 && index < pets.length ? pets[index].id : null;
  }

  static final List<PetModel> pets = _demoPets();

  static List<PetModel> _demoPets() => [
    PetModel(
      id: 'pet-demo-1',
      name: 'Fernando',
      imagePath: PetImages.dog,
      description: _petSummary('Cachorro', 14, true),
      species: 'Cachorro',
      sex: 'M',
      weightKg: 24,
      birthDate: DateTime(2012, 3, 23),
      breed: 'Lulu-da-Pomerânia',
      neutered: true,
    ),
    PetModel(
      id: 'pet-demo-2',
      name: 'Kelly',
      imagePath: PetImages.cat,
      description: _petSummary('Gato', 2, false),
      species: 'Gato',
      sex: 'Fêmea',
      weightKg: 4.2,
      breed: 'Sem raça definida',
      neutered: false,
      ageYears: 2,
    ),
    PetModel(
      id: 'pet-demo-3',
      name: 'Escarola',
      imagePath: PetImages.dog,
      description: _petSummary('Cachorro', 6, true),
      species: 'Cachorro',
      sex: 'Fêmea',
      weightKg: 18,
      breed: 'Sem raça definida',
      neutered: true,
      ageYears: 6,
    ),
    PetModel(
      id: 'pet-demo-4',
      name: 'Eduardido',
      imagePath: PetImages.cat,
      description: _petSummary('Gato', 1, false),
      species: 'Gato',
      sex: 'Macho',
      weightKg: 3.4,
      breed: 'Sem raça definida',
      neutered: false,
      ageYears: 1,
    ),
  ];

  static const PetProfile _padrao = PetProfile(
    especie: 'Cachorro',
    idadeAnos: 4,
    castrado: true,
    pesoKg: 12.5,
  );

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

  static PetProfile perfil(String petId) {
    final model = petById(petId);
    if (model == null) return _padrao;
    final age = model.birthDate == null
        ? model.ageYears ?? _padrao.idadeAnos
        : _age(model.birthDate!);
    return PetProfile(
      especie: model.species ?? _padrao.especie,
      idadeAnos: age,
      castrado: model.neutered,
      pesoKg: model.weightKg,
    );
  }

  static bool authenticate(String email, String password) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim()) &&
      password.trim().length >= 6;

  static void registerClient(Map<String, String> values) {
    if (!values.keys.any((key) => key.startsWith('client.'))) return;
    clientName = values['client.Nome Completo']?.trim().isNotEmpty == true
        ? values['client.Nome Completo']!.trim()
        : clientName;
    clientEmail = values['client.E-mail']?.trim() ?? clientEmail;
    clientPhone =
        values['client.Telefone/Celular']?.replaceAll(RegExp(r'\D'), '') ??
        clientPhone;
    clientGender = values['client.Gênero/Sexo']?.trim() ?? clientGender;
    if (values.containsKey('client.Gênero personalizado')) {
      clientGenderCustom = clientGender == 'Outro'
          ? values['client.Gênero personalizado']!.trim()
          : '';
    }
    if (values['client.Endereço']?.trim().isNotEmpty == true) {
      final address = SavedAddress(
        id:
            addresses.firstOrNull?.id ??
            'address-${DateTime.now().microsecondsSinceEpoch}',
        street: values['client.Endereço']!.trim(),
        number: values['client.Número']?.trim() ?? '',
        complement: values['client.Complemento']?.trim() ?? '',
        city: values['client.Cidade']?.trim() ?? '',
        cep: values['client.CEP']?.trim() ?? '',
      );
      if (addresses.isEmpty) {
        addresses.add(address);
      } else {
        addresses[0] = address;
      }
      clientAddress = address.summary;
    }
    final birth = values['client.Data de Nascimento'];
    if (birth != null) clientBirthDate = _parseDate(birth) ?? clientBirthDate;
    _save();
  }

  static void updateClient({
    String? name,
    DateTime? birthDate,
    String? address,
    String? phone,
    String? email,
  }) {
    if (name != null) clientName = name;
    if (birthDate != null) clientBirthDate = birthDate;
    if (address != null) {
      clientAddress = address;
      if (address.isNotEmpty) {
        final item = SavedAddress(
          id: addresses.firstOrNull?.id ?? 'address-legacy',
          street: address,
        );
        if (addresses.isEmpty) {
          addresses.add(item);
        } else {
          addresses[0] = item;
        }
      } else {
        addresses.clear();
      }
    }
    if (phone != null) clientPhone = phone;
    if (email != null) clientEmail = email;
    _save();
  }

  static void saveAddress(SavedAddress address) {
    final index = addresses.indexWhere((a) => a.id == address.id);
    if (index < 0) {
      addresses.add(address);
    } else {
      addresses[index] = address;
    }
    clientAddress = addresses.firstOrNull?.summary ?? '';
    _save();
  }

  static void removeAddress(String id) {
    addresses.removeWhere((a) => a.id == id);
    clientAddress = addresses.firstOrNull?.summary ?? '';
    _save();
  }

  static List<Agendamento> realAppointments(String petId) =>
      petById(petId) == null
      ? []
      : List.unmodifiable(_novosAgendamentos[petId] ?? []);

  static void _checkPhoto(String? photo, {String? exceptId}) {
    if (photo == null) return;
    final size = pets
        .where((p) => p.id != exceptId)
        .fold<int>(0, (total, p) => total + (p.photoBase64?.length ?? 0));
    if (!PetPhoto.isValid(photo) ||
        size + photo.length > PetPhoto.maxTotalEncodedLength) {
      throw const FormatException(
        'Limite local de fotos atingido. Escolha uma imagem menor.',
      );
    }
  }

  static Future<bool> updatePetPhoto(String id, String photo) async {
    final pet = petById(id);
    if (pet == null) return false;
    _checkPhoto(photo, exceptId: id);
    updatePet(pet, pet.copyWith(photoBase64: photo));
    return flush();
  }

  static PetModel addPet({
    String? photoBase64,
    bool? neutered,
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
    if (!isValidPetWeight(weightKg)) {
      throw const FormatException('Informe um peso válido em kg (até 250).');
    }
    _checkPhoto(photoBase64);
    final pet = PetModel(
      photoBase64: photoBase64,
      name: name.trim(),
      imagePath: PetImages.forSpecies(species) ?? '',
      description: '$species • ${_age(birthDate)} anos • $sex',
      species: species,
      sex: sex,
      weightKg: weightKg,
      birthDate: birthDate,
      breed: breed,
      neutered: neutered,
    );
    pets.add(pet);
    _save();
    return pet;
  }

  static bool petNameExists(String name, {String? except}) => pets.any(
    (pet) =>
        pet.name.toLowerCase() == name.trim().toLowerCase() &&
        pet.name.toLowerCase() != except?.toLowerCase(),
  );

  static void updatePet(PetModel previous, PetModel updated) {
    final index = pets.indexWhere((pet) => pet.id == previous.id);
    if (index < 0) return;
    if (updated.id != previous.id) {
      throw ArgumentError('A edição deve preservar o ID do pet.');
    }
    if (updated.weightKg != pets[index].weightKg &&
        updated.weightKg != null &&
        !isValidPetWeight(updated.weightKg)) {
      throw const FormatException('Informe um peso válido em kg (até 250).');
    }
    _checkPhoto(updated.photoBase64, exceptId: updated.id);
    pets[index] = updated;
    _save();
  }

  static void removePet(PetModel pet) {
    final selectedId = selectedPet?.id;
    pets.removeWhere((item) => item.id == pet.id);
    _novosAgendamentos.remove(pet.id);
    _vaccines.remove(pet.id);
    selectedPetId = selectedId == pet.id ? pets.firstOrNull?.id : selectedId;
    _save();
  }

  static void addAgendamento(String petId, Agendamento agendamento) {
    if (petById(petId) == null) {
      throw ArgumentError('Pet não encontrado.');
    }
    _novosAgendamentos.putIfAbsent(petId, () => []).add(agendamento);
    _save();
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

  static List<Consulta> consultas(String petId) => [
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

  static final Map<String, List<Vacina>> _vaccines = {};
  static int _vaccineCounter = 0;

  static List<Vacina> realVaccines(String petId) =>
      petById(petId) == null ? [] : List.unmodifiable(_vaccines[petId] ?? []);

  static void saveVaccine(String petId, Vacina vaccine) {
    if (petById(petId) == null) throw ArgumentError('Pet não encontrado.');
    if (vaccine.id != null &&
        (vaccine.id!.trim().isEmpty ||
            _vaccines.entries.any(
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
    final records = _vaccines.putIfAbsent(petId, () => []);
    final id =
        vaccine.id ??
        'vaccine-${DateTime.now().microsecondsSinceEpoch}-${_vaccineCounter++}';
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
    _save();
  }

  static void removeVaccine(String petId, String vaccineId) {
    _vaccines[petId]?.removeWhere((v) => v.id == vaccineId);
    _save();
  }

  static List<Vacina> vacinas(String petId) {
    if (petById(petId) == null) return [];
    final real = realVaccines(petId);
    return real.isNotEmpty ? real : _demoVaccines();
  }

  static List<Vacina> _demoVaccines() => [
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

  static List<Despesa> despesas(String petId) {
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

  static List<Agendamento> agendamentos(String petId) => petById(petId) == null
      ? []
      : [
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
          ...?_novosAgendamentos[petId],
        ];
}
