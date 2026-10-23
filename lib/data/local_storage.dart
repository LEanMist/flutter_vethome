import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/json_fields.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../models/saved_address.dart';

enum LocalLoadStatus { empty, valid, invalid, unavailable }

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
    this.genderCustom = '',
    this.addresses = const [],
  });

  final String name, address, phone, email, gender;
  final String genderCustom;
  final List<SavedAddress> addresses;
  final DateTime birthDate;

  Map<String, dynamic> toJson() => {
    'name': name,
    'birthDate': birthDate.toIso8601String(),
    'address': address,
    'phone': phone,
    'email': email,
    'gender': gender,
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
    genderCustom: jsonOptionalString(json, 'genderCustom') ?? '',
    addresses: _addresses(json),
  );

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
  });

  final ClientData client;
  final List<PetModel> pets;
  final Map<String, List<Agendamento>> appointments;
  final Map<String, List<Vacina>> vaccinations;

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
    return LocalState(
      client: ClientData.fromJson(json['client'] as Map<String, dynamic>),
      pets: pets,
      appointments: appointments,
      vaccinations: vaccinations,
    );
  }

  static Map<String, dynamic> _object(dynamic value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Objeto JSON esperado');
    }
    return value;
  }
}

/// Snapshot local; não grava senha, foto do cliente ou mocks clínicos.
class LocalStorage {
  LocalStorage({
    Future<SharedPreferences> Function()? preferencesLoader,
    Future<void> Function(SharedPreferences)? reloadPreferences,
  }) : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance,
       _reloadPreferences =
           reloadPreferences ?? ((preferences) => preferences.reload());

  static const stateKey = 'vethome.state.v1';

  final Future<SharedPreferences> Function() _preferencesLoader;
  final Future<void> Function(SharedPreferences) _reloadPreferences;

  // API com mock oficial; reload evita ler um cache antigo na inicialização.
  Future<LocalLoadResult> load() async {
    late final Object? storedValue;
    try {
      final preferences = await _preferencesLoader();
      await _reloadPreferences(preferences);
      if (!preferences.containsKey(stateKey)) {
        return const LocalLoadResult.empty();
      }
      storedValue = preferences.get(stateKey);
    } catch (error) {
      debugPrint('VetHome: armazenamento local indisponível.');
      return LocalLoadResult.unavailable(error);
    }

    try {
      if (storedValue is! String) {
        throw const FormatException('Snapshot local não é texto JSON');
      }
      final decoded = jsonDecode(storedValue);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Snapshot não é um objeto');
      }
      return LocalLoadResult.valid(LocalState.fromJson(decoded));
    } catch (error) {
      // O valor original permanece intocado para recuperação explícita futura.
      debugPrint('VetHome: snapshot local inválido.');
      return LocalLoadResult.invalid(error);
    }
  }

  Future<void> save(LocalState state) async {
    final value = state.toValidatedJson();
    final preferences = await _preferencesLoader();
    if (!await preferences.setString(stateKey, value)) {
      throw StateError('Não foi possível salvar o estado local do VetHome.');
    }
  }

  Future<void> clear() async {
    final preferences = await _preferencesLoader();
    if (!await preferences.remove(stateKey)) {
      throw StateError('Não foi possível limpar o estado local do VetHome.');
    }
  }
}
