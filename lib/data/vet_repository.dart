import 'dart:typed_data';

import 'package:flutter/foundation.dart'
    show ValueListenable, ValueNotifier, debugPrint;

import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../models/saved_address.dart';
import '../core/utils/pet_images.dart';
import '../core/utils/pet_photo.dart';
import '../core/utils/form_fields.dart';
import '../core/utils/formatters.dart';
import '../core/utils/date_parser.dart';
import 'agendamento_repository.dart';
import 'local/local_storage.dart';
import 'pet_repository.dart';
import 'session.dart';
import 'vacina_repository.dart';

class LocalProfileConflictException implements Exception {
  const LocalProfileConflictException();
}

class PersistenceClearingException implements Exception {
  const PersistenceClearingException();

  @override
  String toString() =>
      'Aguarde a exclusão dos dados locais terminar antes de alterar o perfil.';
}

/// Interface de dados das telas, com snapshot local após cada mutação suportada.
class VetRepository {
  VetRepository._();

  static LocalStorage? _storage;
  static LocalStorage? _lastLocal;
  // Último estado persistível validado; base para reverter mutações inválidas.
  static LocalState? _lastValid;
  static Future<bool> _pendingSave = Future.value(true);
  static Future<bool>? _pendingRetry;
  static int _saveSequence = 0;
  static int _repositoryVersion = 0;
  static int _reloadRequestSequence = 0;
  static int _initializeRequestSequence = 0;
  static bool _clearInProgress = false;
  static final _unsavedChanges = ValueNotifier(false);
  static final _savingChanges = ValueNotifier(false);
  static Object? lastPersistenceError;
  static LocalLoadStatus _persistenceStatus = LocalLoadStatus.empty;

  static LocalLoadStatus get persistenceStatus => _persistenceStatus;
  static ValueListenable<bool> get unsavedChanges => _unsavedChanges;
  static ValueListenable<bool> get savingChanges => _savingChanges;

  static bool get persistenceBlocked =>
      _persistenceStatus == LocalLoadStatus.invalid ||
      _persistenceStatus == LocalLoadStatus.unavailable;

  /// Deve terminar antes de runApp. Também permite simular reinício nos testes.
  static Future<void> initialize({LocalStorage? storage}) async {
    final requestSequence = ++_initializeRequestSequence;
    final repositoryVersion = _repositoryVersion;
    if (_clearInProgress) return;

    await flush();
    if (requestSequence != _initializeRequestSequence ||
        repositoryVersion != _repositoryVersion ||
        _clearInProgress ||
        _savingChanges.value ||
        _unsavedChanges.value) {
      return;
    }

    final local = storage ?? LocalStorage();
    final result = await local.load();
    if (requestSequence != _initializeRequestSequence ||
        repositoryVersion != _repositoryVersion ||
        _clearInProgress ||
        _savingChanges.value ||
        _unsavedChanges.value) {
      return;
    }

    _applyLoadResult(local, result);
  }

  /// Substitui o estado desta sessão pela revisão salva por outra janela.
  /// Em caso de falha, conserva a sessão atual e suas alterações pendentes.
  static Future<bool> reloadLatestAfterConflict() async {
    if (lastPersistenceError is! LocalStorageConflictException ||
        _savingChanges.value ||
        _clearInProgress) {
      return false;
    }

    final previousLocal = _lastLocal;
    if (previousLocal == null) return false;
    final repositoryVersion = _repositoryVersion;
    final requestSequence = ++_reloadRequestSequence;
    final local = previousLocal.createReloadInstance();
    final result = await local.load();
    if (result.status == LocalLoadStatus.invalid ||
        result.status == LocalLoadStatus.unavailable) {
      return false;
    }
    // A sessão pode mudar enquanto a leitura aguarda o armazenamento. Não deixe
    // um snapshot antigo sobrescrever mutações, exclusões ou outra recarga.
    if (requestSequence != _reloadRequestSequence ||
        repositoryVersion != _repositoryVersion ||
        _savingChanges.value ||
        _clearInProgress ||
        !identical(_lastLocal, previousLocal) ||
        lastPersistenceError is! LocalStorageConflictException) {
      return false;
    }
    _applyLoadResult(local, result);
    return true;
  }

  static void _applyLoadResult(LocalStorage local, LocalLoadResult result) {
    _repositoryVersion++;
    _storage = null;
    _lastLocal = local;
    _lastValid = null;
    final state = result.state;
    clientName = state?.client.name ?? Session.defaultClientName;
    clientBirthDate =
        state?.client.birthDate ?? Session.defaultClientBirthDate;
    clientAddress = state?.client.address ?? '';
    clientPhone = state?.client.phone ?? '';
    clientEmail = state?.client.email ?? '';
    clientGender = state?.client.gender ?? '';
    clientGenderCustom = state?.client.genderCustom ?? '';
    clientPhotoBase64 = state?.client.photoBase64;
    addresses
      ..clear()
      ..addAll(state?.client.addresses ?? []);
    clientPhotoPath = null;
    clientPhotoBytes = null;
    selectedPetId = null;
    pets
      ..clear()
      ..addAll(state?.pets ?? PetRepository.demoPets());
    AgendamentoRepository.restore(
      state?.appointments ?? <String, List<Agendamento>>{},
    );
    VacinaRepository.restore(
      state?.vaccinations ?? <String, List<Vacina>>{},
      state?.vaccinationDemoDismissedPetIds ?? const <String>{},
    );
    _persistenceStatus = result.status;
    lastPersistenceError = persistenceBlocked ? result.error : null;
    _pendingSave = Future.value(!persistenceBlocked);
    _storage = persistenceBlocked ? null : local;
    _lastValid = _storage == null ? null : _buildState();
    _unsavedChanges.value = false;
    _savingChanges.value = false;
  }

  /// Nova leitura pelo fluxo de [initialize], só quando o armazenamento estava
  /// indisponível. Não grava nada; snapshot inválido continua bloqueado.
  static Future<void> retryInitialization() async {
    if (_persistenceStatus != LocalLoadStatus.unavailable) return;
    await initialize(storage: _lastLocal);
  }

  /// Aguarda a fila; false indica falha, sem lançar erro assíncrono nas telas.
  static Future<bool> flush() => _pendingSave;

  /// Remove o snapshot local e retorna à demonstração padrão em memória.
  /// Dados demonstrativos não são gravados novamente até a próxima alteração.
  static Future<bool> clearLocalData() async {
    final storage = _lastLocal;
    if (storage == null || _clearInProgress) return false;
    _clearInProgress = true;
    // Invalida qualquer recarga assíncrona iniciada antes da exclusão.
    _repositoryVersion++;
    try {
      // Bloqueia novas mutações antes de esperar a fila, para que nenhuma
      // gravação posterior possa recriar o snapshot depois do tombstone.
      await flush();
      try {
        await storage.clear();
      } catch (error) {
        lastPersistenceError = error;
        return false;
      }

      Session.resetLocalClient();
      addresses.clear();
      PetRepository.resetToDemo();
      AgendamentoRepository.clear();
      VacinaRepository.clear();

      _storage = storage;
      _lastValid = null;
      _pendingSave = Future.value(true);
      _pendingRetry = null;
      _persistenceStatus = LocalLoadStatus.empty;
      lastPersistenceError = null;
      _unsavedChanges.value = false;
      _savingChanges.value = false;
      return true;
    } finally {
      _clearInProgress = false;
    }
  }

  /// Tenta gravar o último estado válido sem reaplicar a ação que o gerou.
  static Future<bool> retrySave() {
    final retry = _pendingRetry;
    if (retry != null) return retry;
    if (_clearInProgress) return Future<bool>.value(false);
    final storage = _storage;
    final state = _lastValid;
    if (storage == null || state == null || !_unsavedChanges.value) {
      return flush();
    }
    _queueSave(storage, state, onlyAfterFailure: true);
    return _pendingRetry = flush().whenComplete(() => _pendingRetry = null);
  }

  static void _ensurePersistenceWritable() {
    if (_clearInProgress) {
      throw const PersistenceClearingException();
    }
    if (persistenceBlocked) {
      throw const PersistenceBlockedException();
    }
  }

  static LocalState _buildState() => LocalState(
    client: ClientData(
      name: clientName,
      birthDate: clientBirthDate,
      address: clientAddress,
      phone: clientPhone,
      email: clientEmail,
      gender: clientGender,
      genderCustom: clientGenderCustom,
      photoBase64: clientPhotoBase64,
      addresses: List.of(addresses),
    ),
    pets: List.of(pets),
    appointments: AgendamentoRepository.snapshot(),
    vaccinations: VacinaRepository.snapshot(),
    vaccinationDemoDismissedPetIds: VacinaRepository.demoDispensadasSnapshot(),
  );

  static void _restore(LocalState state) {
    clientName = state.client.name;
    clientBirthDate = state.client.birthDate;
    clientAddress = state.client.address;
    clientPhone = state.client.phone;
    clientEmail = state.client.email;
    clientGender = state.client.gender;
    clientGenderCustom = state.client.genderCustom;
    clientPhotoBase64 = state.client.photoBase64;
    addresses
      ..clear()
      ..addAll(state.client.addresses);
    pets
      ..clear()
      ..addAll(state.pets);
    AgendamentoRepository.restore(state.appointments);
    VacinaRepository.restore(
      state.vaccinations,
      state.vaccinationDemoDismissedPetIds,
    );
  }

  static void _save() {
    _ensurePersistenceWritable();
    final storage = _storage;
    // Testes/telas isolados continuam podendo usar o repositório em memória.
    if (storage == null) return;
    final state = _buildState();
    try {
      state.toValidatedJson();
    } catch (error) {
      // Mutação inválida: devolve a memória ao último estado validado.
      final rollback = _lastValid;
      if (rollback != null) _restore(rollback);
      lastPersistenceError = error;
      debugPrint('VetHome: mutação revertida por snapshot inválido.');
      rethrow;
    }
    _lastValid = state;
    _queueSave(storage, state);
  }

  static void _queueSave(
    LocalStorage storage,
    LocalState state, {
    bool onlyAfterFailure = false,
  }) {
    // Captura cada estado e serializa as gravações para evitar inversão de ordem.
    final sequence = ++_saveSequence;
    _repositoryVersion++;
    _unsavedChanges.value = true;
    _savingChanges.value = true;
    _pendingSave = _pendingSave.then((previousSaved) async {
      if (onlyAfterFailure && previousSaved) {
        if (sequence == _saveSequence) {
          _savingChanges.value = false;
          _unsavedChanges.value = false;
        }
        return true;
      }
      try {
        await storage.save(state);
        lastPersistenceError = null;
        if (sequence == _saveSequence) {
          _savingChanges.value = false;
          _unsavedChanges.value = false;
        }
        return true;
      } catch (error) {
        lastPersistenceError = error;
        if (sequence == _saveSequence) {
          _savingChanges.value = false;
          _unsavedChanges.value = true;
        }
        debugPrint('VetHome: falha ao salvar estado local.');
        return false;
      }
    });
  }

  // Dados do cliente: a fonte única é [Session]. Estes acessos existem para
  // as telas e testes que ainda usam VetRepository.
  static String get clientName => Session.clientName;
  static set clientName(String value) => Session.clientName = value;

  static DateTime get clientBirthDate => Session.clientBirthDate;
  static set clientBirthDate(DateTime value) =>
      Session.clientBirthDate = value;

  static String get clientEmail => Session.clientEmail;
  static set clientEmail(String value) => Session.clientEmail = value;

  static String get clientAddress => Session.clientAddress;
  static set clientAddress(String value) => Session.clientAddress = value;

  static String get clientPhone => Session.clientPhone;
  static set clientPhone(String value) => Session.clientPhone = value;

  static String get clientGender => Session.clientGender;
  static set clientGender(String value) => Session.clientGender = value;

  static String get clientGenderCustom => Session.clientGenderCustom;
  static set clientGenderCustom(String value) =>
      Session.clientGenderCustom = value;

  static String? get clientPhotoBase64 => Session.clientPhotoBase64;
  static set clientPhotoBase64(String? value) =>
      Session.clientPhotoBase64 = value;

  static String? get clientPhotoPath => Session.clientPhotoPath;
  static set clientPhotoPath(String? value) => Session.clientPhotoPath = value;

  // No Web, o caminho do picker é temporário; conserva a foto nesta sessão.
  static Uint8List? get clientPhotoBytes => Session.clientPhotoBytes;
  static set clientPhotoBytes(Uint8List? value) =>
      Session.clientPhotoBytes = value;

  static final List<SavedAddress> addresses = [];

  // Pets: a fonte única é [PetRepository].
  static List<PetModel> get pets => PetRepository.pets;

  static String? get selectedPetId => PetRepository.selectedPetId;
  static set selectedPetId(String? value) =>
      PetRepository.selectedPetId = value;

  static PetModel? petById(String id) => PetRepository.petById(id);

  static PetModel? get selectedPet => PetRepository.selectedPet;

  // Compatibilidade com as telas antigas; a seleção é armazenada por ID.
  static int get selectedPetIndex => PetRepository.selectedPetIndex;
  static set selectedPetIndex(int index) =>
      PetRepository.selectedPetIndex = index;


  static const contactVeterinarianName = 'Gabriela Falcão';
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

  static PetProfile perfil(String petId) => PetRepository.perfil(petId);

  static bool authenticate(String email, String password) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim()) &&
      password.trim().isNotEmpty &&
      password.length >= 6 &&
      !hasDifferentLocalClientEmail(email);

  /// Esta demonstração mantém um único perfil local por instalação.
  static bool hasDifferentLocalClientEmail(String? email) =>
      Session.hasDifferentLocalClientEmail(email);

  /// Detecta uma tentativa de trocar o perfil sem fornecer o e-mail salvo.
  static bool hasLocalClientIdentityConflict({String? email, String? name}) =>
      Session.hasLocalClientIdentityConflict(email: email, name: name);

  static void registerClient(Map<String, String> values) {
    _ensurePersistenceWritable();
    if (!values.keys.any((key) => key.startsWith('client.'))) return;
    if (hasLocalClientIdentityConflict(
      email: values['client.E-mail'],
      name: values['client.Nome Completo'],
    )) {
      throw const LocalProfileConflictException();
    }
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
        name: values.containsKey('client.Nome do Endereço')
            ? values['client.Nome do Endereço']!.trim()
            : addresses.firstOrNull?.name ?? '',
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
    if (birth != null) {
      clientBirthDate = parseFlexibleDate(birth) ?? clientBirthDate;
    }
    _save();
  }

  /// Atualiza o perfil local selecionado; a edição do e-mail faz parte dessa
  /// edição, enquanto [registerClient] protege o fluxo de um novo cadastro.
  static void updateClient({
    String? name,
    DateTime? birthDate,
    String? address,
    String? phone,
    String? email,
  }) {
    _ensurePersistenceWritable();
    if (name != null) clientName = name;
    if (birthDate != null) clientBirthDate = birthDate;
    if (address != null) {
      clientAddress = address;
      if (address.isNotEmpty) {
        final item = SavedAddress(
          id: addresses.firstOrNull?.id ?? 'address-legacy',
          street: address,
          name: addresses.firstOrNull?.name ?? '',
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
    _ensurePersistenceWritable();
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
    _ensurePersistenceWritable();
    addresses.removeWhere((a) => a.id == id);
    clientAddress = addresses.firstOrNull?.summary ?? '';
    _save();
  }

  static List<Agendamento> realAppointments(String petId) =>
      AgendamentoRepository.reais(petId);

  static void _checkPhoto(
    String? photo, {
    String? exceptId,
    bool replacingClientPhoto = false,
  }) {
    if (photo == null) return;
    final petPhotosSize = pets
        .where((p) => p.id != exceptId)
        .fold<int>(0, (total, p) => total + (p.photoBase64?.length ?? 0));
    final clientPhotoSize = replacingClientPhoto
        ? 0
        : clientPhotoBase64?.length ?? 0;
    if (!PetPhoto.isValid(photo) ||
        petPhotosSize + clientPhotoSize + photo.length >
            PetPhoto.maxTotalEncodedLength) {
      throw const FormatException(
        'Limite local de fotos atingido. Escolha uma imagem menor.',
      );
    }
  }

  static Future<bool> updateClientPhoto(String photoBase64) async {
    _ensurePersistenceWritable();
    _checkPhoto(photoBase64, replacingClientPhoto: true);
    clientPhotoBase64 = photoBase64;
    _save();
    return flush();
  }

  static Future<bool> updatePetPhoto(String id, String photo) async {
    _ensurePersistenceWritable();
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
    _ensurePersistenceWritable();
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
    final age = ageInYears(birthDate, DateTime.now());
    final pet = PetModel(
      photoBase64: photoBase64,
      name: name.trim(),
      imagePath: PetImages.forSpecies(species) ?? '',
      description: '$species • $age anos • $sex',
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
    _ensurePersistenceWritable();
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
    _ensurePersistenceWritable();
    final previousSelectedPetId = selectedPetId;
    final selectedId = selectedPet?.id;
    pets.removeWhere((item) => item.id == pet.id);
    AgendamentoRepository.removeDoPet(pet.id);
    VacinaRepository.removeDoPet(pet.id);
    selectedPetId = selectedId == pet.id ? pets.firstOrNull?.id : selectedId;
    try {
      _save();
    } catch (_) {
      selectedPetId = previousSelectedPetId;
      rethrow;
    }
  }

  static void addAgendamento(String petId, Agendamento agendamento) {
    _ensurePersistenceWritable();
    AgendamentoRepository.adicionar(petId, agendamento);
    _save();
  }

  /// Confere conflitos somente contra consultas criadas pelo usuário.
  /// Eventos de demonstração não ocupam horários reais.
  static bool hasAppointmentConflict({
    required String petId,
    required String veterinarian,
    required DateTime start,
    required DateTime end,
  }) => AgendamentoRepository.temConflito(
    petId: petId,
    veterinarian: veterinarian,
    start: start,
    end: end,
  );

  /// Remove somente a mesma consulta salva; eventos de demonstração ficam fora
  /// da lista do repositório.
  static bool removeAgendamento(String petId, Agendamento agendamento) {
    _ensurePersistenceWritable();
    if (!AgendamentoRepository.remover(petId, agendamento)) return false;
    _save();
    return true;
  }

  static List<Consulta> consultas(String petId) =>
      AgendamentoRepository.consultas(petId);

  static List<Agendamento> agendamentos(String petId) =>
      AgendamentoRepository.listar(petId);

  static List<Vacina> realVaccines(String petId) =>
      VacinaRepository.reais(petId);

  static void saveVaccine(String petId, Vacina vaccine) {
    _ensurePersistenceWritable();
    VacinaRepository.salvar(petId, vaccine);
    _save();
  }

  static void removeVaccine(String petId, String vaccineId) {
    _ensurePersistenceWritable();
    VacinaRepository.remover(petId, vaccineId);
    _save();
  }

  static bool usesDemoVaccines(String petId) =>
      VacinaRepository.usaDemonstracao(petId);

  static List<Vacina> vacinas(String petId) => VacinaRepository.listar(petId);
}

class PersistenceBlockedException implements Exception {
  const PersistenceBlockedException();

  @override
  String toString() =>
      'O armazenamento local está protegido contra alterações nesta sessão.';
}
