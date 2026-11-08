import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/pet_photo.dart';
import '../models/json_fields.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../models/saved_address.dart';
import 'local_storage_write_lock.dart';

enum LocalLoadStatus { empty, valid, invalid, unavailable }

enum LocalStorageConflictKind { cleared, modified }

class LocalStorageConflictException extends StateError {
  LocalStorageConflictException.cleared()
    : kind = LocalStorageConflictKind.cleared,
      super(
        'Os dados foram apagados em outra janela. Carregue os dados atuais antes de salvar.',
      );

  LocalStorageConflictException.modified()
    : kind = LocalStorageConflictKind.modified,
      super(
        'Os dados foram alterados em outra janela. Carregue os dados atuais antes de salvar.',
      );

  final LocalStorageConflictKind kind;
}

class LocalLoadResult {
  const LocalLoadResult._(this.status, {this.state, this.error});

  const LocalLoadResult.empty() : this._(LocalLoadStatus.empty);

  const LocalLoadResult.valid(LocalState state)
    : this._(LocalLoadStatus.valid, state: state);

  const LocalLoadResult.invalid(Object error)
    : this._(LocalLoadStatus.invalid, error: error);

  const LocalLoadResult.unavailable(Object error)
    : this._(LocalLoadStatus.unavailable, error: error);

  final LocalLoadStatus status;
  final LocalState? state;
  final Object? error;
}

class ClientData {
  const ClientData({
    required this.name,
    required this.birthDate,
    required this.address,
    required this.phone,
    required this.email,
    required this.gender,
    this.photoBase64,
    this.genderCustom = '',
    this.addresses = const [],
  });

  final String name, address, phone, email, gender;
  final String genderCustom;
  final String? photoBase64;
  final List<SavedAddress> addresses;
  final DateTime birthDate;

  Map<String, dynamic> toJson() => {
    'name': name,
    'birthDate': birthDate.toIso8601String(),
    'address': address,
    'phone': phone,
    'email': email,
    'gender': gender,
    if (photoBase64 != null) 'photoBase64': photoBase64,
    'genderCustom': genderCustom,
    'addresses': addresses.map((a) => a.toJson()).toList(),
  };

  factory ClientData.fromJson(Map<String, dynamic> json) => ClientData(
    name: jsonString(json, 'name'),
    birthDate: jsonDate(json, 'birthDate'),
    address: jsonString(json, 'address'),
    phone: jsonString(json, 'phone'),
    email: jsonString(json, 'email'),
    gender: jsonString(json, 'gender'),
    photoBase64: _photo(json),
    genderCustom: jsonOptionalString(json, 'genderCustom') ?? '',
    addresses: _addresses(json),
  );

  static String? _photo(Map<String, dynamic> json) {
    final value = json['photoBase64'];
    return value is String && PetPhoto.isValid(value) ? value : null;
  }

  static List<SavedAddress> _addresses(Map<String, dynamic> json) {
    if (!json.containsKey('addresses')) {
      final old = jsonString(json, 'address');
      return old.isEmpty
          ? []
          : [SavedAddress(id: 'address-legacy', street: old)];
    }
    final values = json['addresses'];
    if (values is! List) throw const FormatException('Endereços inválidos');
    final result = <SavedAddress>[];
    for (final value in values) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Endereço inválido');
      }
      final address = SavedAddress.fromJson(value);
      if (address.id.isEmpty || result.any((a) => a.id == address.id)) {
        throw const FormatException('ID de endereço inválido');
      }
      result.add(address);
    }
    return result;
  }
}

class LocalState {
  const LocalState({
    required this.client,
    required this.pets,
    required this.appointments,
    this.vaccinations = const {},
    this.vaccinationDemoDismissedPetIds = const {},
  });

  final ClientData client;
  final List<PetModel> pets;
  final Map<String, List<Agendamento>> appointments;
  final Map<String, List<Vacina>> vaccinations;
  final Set<String> vaccinationDemoDismissedPetIds;

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'client': client.toJson(),
    'pets': pets.map((pet) => pet.toJson()).toList(),
    'appointments': [
      for (final entry in appointments.entries)
        for (final event in entry.value) event.toJson(petId: entry.key),
    ],
    'vaccinations': [
      for (final entry in vaccinations.entries)
        for (final vaccine in entry.value) vaccine.toJson(petId: entry.key),
    ],
    'vaccinationDemoDismissedPetIds': vaccinationDemoDismissedPetIds.toList()
      ..sort(),
  };

  /// Serializa e confirma que [LocalState.fromJson] aceita o resultado.
  /// Impede gravar um snapshot que o próprio aplicativo não conseguiria ler.
  String toValidatedJson() {
    try {
      final encoded = jsonEncode(toJson());
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Snapshot não é um objeto');
      }
      LocalState.fromJson(decoded);
      return encoded;
    } catch (_) {
      throw const FormatException(
        'Os dados locais não passaram na validação de gravação.',
      );
    }
  }

  factory LocalState.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != 1 ||
        json['client'] is! Map<String, dynamic> ||
        json['pets'] is! List ||
        json['appointments'] is! List) {
      throw const FormatException('Snapshot inválido ou versão incompatível');
    }
    final pets = [
      for (final item in json['pets'] as List) PetModel.fromJson(_object(item)),
    ];
    final ids = pets.map((pet) => pet.id).toSet();
    if (ids.length != pets.length) {
      throw const FormatException('IDs duplicados');
    }
    final appointments = <String, List<Agendamento>>{};
    for (final item in json['appointments'] as List) {
      final event = _object(item);
      final petId = jsonString(event, 'petId');
      if (!ids.contains(petId)) {
        throw const FormatException('Agendamento sem pet correspondente');
      }
      appointments
          .putIfAbsent(petId, () => [])
          .add(Agendamento.fromJson(event));
    }
    final rawVaccinations = json['vaccinations'] ?? const [];
    if (rawVaccinations is! List) {
      throw const FormatException('Lista de vacinas inválida');
    }
    final vaccinations = <String, List<Vacina>>{};
    final vaccineIds = <String>{};
    for (final value in rawVaccinations) {
      final item = _object(value);
      final petId = jsonString(item, 'petId');
      final vaccine = Vacina.fromJson(item);
      if (!ids.contains(petId) || !vaccineIds.add(vaccine.id!)) {
        throw const FormatException('Vacina sem pet ou ID duplicado');
      }
      vaccinations.putIfAbsent(petId, () => []).add(vaccine);
    }
    final rawDismissedPetIds =
        json['vaccinationDemoDismissedPetIds'] ?? const [];
    if (rawDismissedPetIds is! List ||
        rawDismissedPetIds.any((value) => value is! String)) {
      throw const FormatException(
        'Lista de carteiras de vacinação vazias inválida',
      );
    }
    final dismissedPetIds = rawDismissedPetIds.cast<String>().toSet();
    if (dismissedPetIds.length != rawDismissedPetIds.length ||
        dismissedPetIds.any((petId) => !ids.contains(petId))) {
      throw const FormatException(
        'Carteira de vacinação vazia sem pet correspondente',
      );
    }
    return LocalState(
      client: ClientData.fromJson(json['client'] as Map<String, dynamic>),
      pets: pets,
      appointments: appointments,
      vaccinations: vaccinations,
      vaccinationDemoDismissedPetIds: dismissedPetIds,
    );
  }

  static Map<String, dynamic> _object(dynamic value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Objeto JSON esperado');
    }
    return value;
  }
}

/// Snapshot local; fotos ficam como miniaturas PNG Base64, sem senha ou mocks clínicos.
class LocalStorage {
  LocalStorage({
    Future<SharedPreferences> Function()? preferencesLoader,
    Future<void> Function(SharedPreferences)? reloadPreferences,
    Future<bool> Function(SharedPreferences, String, String)? snapshotWriter,
  }) : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance,
       _reloadPreferences =
           reloadPreferences ?? ((preferences) => preferences.reload()),
       _snapshotWriter =
           snapshotWriter ??
           ((preferences, key, value) => preferences.setString(key, value));

  static const stateKey = 'vethome.state.v1';
  static const revisionKey = 'vethome.state.revision.v1';
  static const generationKey = 'vethome.state.generation.v1';
  static const storageMetadataKey = '_vethomeStorage';

  final Future<SharedPreferences> Function() _preferencesLoader;
  final Future<void> Function(SharedPreferences) _reloadPreferences;
  final Future<bool> Function(SharedPreferences, String, String)
  _snapshotWriter;
  static Future<void> _mutationQueue = Future<void>.value();
  int? _knownGeneration;
  int? _knownRevision;
  LocalLoadStatus? _lastLoadStatus;

  static Future<T> _serializeMutation<T>(
    Future<T> Function() action, {
    bool requireCrossContextLock = true,
  }) async {
    final previousMutation = _mutationQueue;
    final release = Completer<void>();
    _mutationQueue = release.future;
    await previousMutation;
    try {
      return await withLocalStorageWriteLock(
        action,
        requireCrossContextLock: requireCrossContextLock,
      );
    } finally {
      release.complete();
    }
  }

  int _readGeneration(SharedPreferences preferences) {
    final value = preferences.get(generationKey);
    if (value == null) return 0;
    if (value is! int || value < 0) {
      throw const FormatException('Revisão dos dados locais inválida');
    }
    return value;
  }

  int _readRevision(SharedPreferences preferences) {
    final value = preferences.get(revisionKey);
    if (value == null) return 0;
    if (value is! int || value < 0) {
      throw const FormatException('Revisão dos dados locais inválida');
    }
    return value;
  }

  _LocalStorageMetadata _readLegacyMetadata(SharedPreferences preferences) =>
      _LocalStorageMetadata(
        generation: _readGeneration(preferences),
        revision: _readRevision(preferences),
      );

  _LocalStorageMetadata _readStoredMetadata(SharedPreferences preferences) {
    if (!preferences.containsKey(stateKey)) {
      return _readLegacyMetadata(preferences);
    }
    final storedValue = preferences.get(stateKey);
    if (storedValue is! String) {
      throw const FormatException('Snapshot local não é texto JSON');
    }
    final decoded = jsonDecode(storedValue);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Snapshot não é um objeto');
    }
    if (decoded.containsKey(storageMetadataKey)) {
      final metadata = _LocalStorageMetadata.fromJson(
        decoded[storageMetadataKey],
      );
      if (!metadata.cleared) LocalState.fromJson(decoded);
      return metadata;
    }
    LocalState.fromJson(decoded);
    return _readLegacyMetadata(preferences);
  }

  /// Creates an independent reader so a failed refresh does not invalidate the
  /// session's last-known-good revision metadata.
  LocalStorage createReloadInstance() => LocalStorage(
    preferencesLoader: _preferencesLoader,
    reloadPreferences: _reloadPreferences,
    snapshotWriter: _snapshotWriter,
  );

  // API com mock oficial; reload evita ler um cache antigo na inicialização.
  Future<LocalLoadResult> load() async {
    try {
      return await _serializeMutation(() async {
        late final Object? storedValue;
        late final bool hasStoredValue;
        late final SharedPreferences preferences;
        try {
          preferences = await _preferencesLoader();
          await _reloadPreferences(preferences);
          hasStoredValue = preferences.containsKey(stateKey);
          storedValue = hasStoredValue ? preferences.get(stateKey) : null;
        } catch (error) {
          _lastLoadStatus = LocalLoadStatus.unavailable;
          debugPrint('VetHome: armazenamento local indisponível.');
          return LocalLoadResult.unavailable(error);
        }

        try {
          if (!hasStoredValue) {
            final metadata = _readLegacyMetadata(preferences);
            _knownGeneration = metadata.generation;
            _knownRevision = metadata.revision;
            _lastLoadStatus = LocalLoadStatus.empty;
            return const LocalLoadResult.empty();
          }
          if (storedValue is! String) {
            throw const FormatException('Snapshot local não é texto JSON');
          }
          final decoded = jsonDecode(storedValue);
          if (decoded is! Map<String, dynamic>) {
            throw const FormatException('Snapshot não é um objeto');
          }
          final metadata = decoded.containsKey(storageMetadataKey)
              ? _LocalStorageMetadata.fromJson(decoded[storageMetadataKey])
              : _readLegacyMetadata(preferences);
          _knownGeneration = metadata.generation;
          _knownRevision = metadata.revision;
          if (metadata.cleared) {
            _lastLoadStatus = LocalLoadStatus.empty;
            return const LocalLoadResult.empty();
          }
          final state = LocalState.fromJson(decoded);
          _lastLoadStatus = LocalLoadStatus.valid;
          return LocalLoadResult.valid(state);
        } catch (error) {
          _lastLoadStatus = LocalLoadStatus.invalid;
          // O valor original permanece intocado para recuperação explícita futura.
          debugPrint('VetHome: snapshot local inválido.');
          return LocalLoadResult.invalid(error);
        }
      }, requireCrossContextLock: false);
    } catch (error) {
      _lastLoadStatus = LocalLoadStatus.unavailable;
      debugPrint('VetHome: bloqueio do armazenamento local indisponível.');
      return LocalLoadResult.unavailable(error);
    }
  }

  Future<void> save(LocalState state) async {
    final validated = state.toValidatedJson();
    if (_lastLoadStatus != LocalLoadStatus.empty &&
        _lastLoadStatus != LocalLoadStatus.valid) {
      throw StateError(
        'Carregue e valide os dados locais antes de salvar alterações.',
      );
    }
    final knownGeneration = _knownGeneration;
    final knownRevision = _knownRevision;
    if (knownGeneration == null || knownRevision == null) {
      throw StateError(
        'Carregue e valide os dados locais antes de salvar alterações.',
      );
    }
    final value = jsonDecode(validated) as Map<String, dynamic>;
    await _serializeMutation(() async {
      final preferences = await _preferencesLoader();
      await _reloadPreferences(preferences);
      final currentMetadata = _readStoredMetadata(preferences);
      if (knownGeneration != currentMetadata.generation) {
        throw LocalStorageConflictException.cleared();
      }
      if (knownRevision != currentMetadata.revision) {
        throw LocalStorageConflictException.modified();
      }
      final nextRevision = currentMetadata.revision + 1;
      final metadata = _LocalStorageMetadata(
        generation: currentMetadata.generation,
        revision: nextRevision,
      );
      final encoded = jsonEncode({
        ...value,
        storageMetadataKey: metadata.toJson(),
      });
      if (!await _snapshotWriter(preferences, stateKey, encoded)) {
        throw StateError('Não foi possível salvar o estado local do VetHome.');
      }
      _knownGeneration = currentMetadata.generation;
      _knownRevision = nextRevision;
    });
  }

  Future<void> clear() => _serializeMutation(() async {
    final preferences = await _preferencesLoader();
    await _reloadPreferences(preferences);
    final knownGeneration = _knownGeneration;
    final knownRevision = _knownRevision;
    late final _LocalStorageMetadata currentMetadata;
    var metadataWasCorrupt = false;
    try {
      currentMetadata = _readStoredMetadata(preferences);
    } on FormatException {
      // Revisão corrompida ainda permite uma exclusão explícita. O valor alto
      // impede sessões antigas com revisão válida de recriarem o snapshot.
      final invalidation = DateTime.now().microsecondsSinceEpoch;
      currentMetadata = _LocalStorageMetadata(
        generation: invalidation,
        revision: invalidation,
      );
      metadataWasCorrupt = true;
    }
    if (!metadataWasCorrupt &&
        knownGeneration != null &&
        knownGeneration != currentMetadata.generation) {
      throw LocalStorageConflictException.cleared();
    }
    if (!metadataWasCorrupt &&
        knownRevision != null &&
        knownRevision != currentMetadata.revision) {
      throw LocalStorageConflictException.modified();
    }
    final nextGeneration = currentMetadata.generation + 1;
    final nextRevision = currentMetadata.revision + 1;
    final tombstone = jsonEncode({
      storageMetadataKey: _LocalStorageMetadata(
        generation: nextGeneration,
        revision: nextRevision,
        cleared: true,
      ).toJson(),
    });
    if (!await _snapshotWriter(preferences, stateKey, tombstone)) {
      throw StateError('Não foi possível limpar o estado local do VetHome.');
    }
    _knownGeneration = nextGeneration;
    _knownRevision = nextRevision;
    _lastLoadStatus = LocalLoadStatus.empty;
  });
}

class _LocalStorageMetadata {
  const _LocalStorageMetadata({
    required this.generation,
    required this.revision,
    this.cleared = false,
  });

  static const _formatVersion = 1;

  final int generation;
  final int revision;
  final bool cleared;

  factory _LocalStorageMetadata.fromJson(Object? value) {
    if (value is! Map<String, dynamic> ||
        value['formatVersion'] != _formatVersion ||
        value['generation'] is! int ||
        value['revision'] is! int ||
        (value['generation'] as int) < 0 ||
        (value['revision'] as int) < 0 ||
        value['cleared'] is! bool) {
      throw const FormatException('Metadados dos dados locais inválidos');
    }
    return _LocalStorageMetadata(
      generation: value['generation'] as int,
      revision: value['revision'] as int,
      cleared: value['cleared'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'formatVersion': _formatVersion,
    'generation': generation,
    'revision': revision,
    'cleared': cleared,
  };
}
