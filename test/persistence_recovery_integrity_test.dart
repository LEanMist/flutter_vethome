import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/main.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/critical_storage_error_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Armazenamento de teste: devolve resultados de leitura em sequência
/// (o último se repete) e conta leituras e gravações.
class _SequenceStorage extends LocalStorage {
  _SequenceStorage(this.results);

  final List<LocalLoadResult> results;
  int loadCalls = 0;
  int saveCalls = 0;

  @override
  Future<LocalLoadResult> load() async {
    final index = loadCalls < results.length ? loadCalls : results.length - 1;
    loadCalls++;
    return results[index];
  }

  @override
  Future<void> save(LocalState state) async {
    saveCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  LocalState stateWith({
    String name = 'Cliente salvo',
    List<SavedAddress> addresses = const [],
  }) => LocalState(
    client: ClientData(
      name: name,
      birthDate: DateTime(1990, 1, 2),
      address: '',
      phone: '',
      email: 'cliente@example.com',
      gender: '',
      addresses: addresses,
    ),
    pets: const [],
    appointments: const {},
  );

  setUp(() async {
    await VetRepository.flush();
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  tearDown(() async {
    await VetRepository.flush();
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  group('M1 — integridade do snapshot', () {
    test(
      'snapshot válido é salvo no formato v1 e carregado novamente',
      () async {
        final storage = LocalStorage();
        final state = stateWith(
          addresses: const [SavedAddress(id: 'a1', street: 'Rua A')],
        );

        await storage.save(state);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(LocalStorage.stateKey), state.toValidatedJson());
        final loaded = await storage.load();
        expect(loaded.status, LocalLoadStatus.valid);
        expect(loaded.state?.client.name, 'Cliente salvo');
        expect(loaded.state?.client.addresses.single.id, 'a1');
      },
    );

    for (final entry in {
      'ID de endereço vazio': const [SavedAddress(id: '', street: 'Rua')],
      'ID de endereço duplicado': const [
        SavedAddress(id: 'x', street: 'Rua 1'),
        SavedAddress(id: 'x', street: 'Rua 2'),
      ],
    }.entries) {
      test(
        'save() recusa ${entry.key} e preserva os bytes originais',
        () async {
          const original = 'bytes-originais-intactos';
          SharedPreferences.setMockInitialValues({
            LocalStorage.stateKey: original,
          });

          await expectLater(
            LocalStorage().save(stateWith(addresses: entry.value)),
            throwsA(isA<FormatException>()),
          );

          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString(LocalStorage.stateKey), original);
        },
      );
    }

    test('mutação com ID vazio é revertida e nada é gravado', () async {
      final storage = _SequenceStorage([const LocalLoadResult.empty()]);
      await VetRepository.initialize(storage: storage);

      expect(
        () => VetRepository.saveAddress(
          const SavedAddress(id: '', street: 'Rua inválida'),
        ),
        throwsA(isA<FormatException>()),
      );

      expect(VetRepository.addresses, isEmpty);
      expect(VetRepository.clientAddress, '');
      expect(await VetRepository.flush(), isTrue);
      expect(storage.saveCalls, 0);

      // O repositório continua utilizável depois da reversão.
      VetRepository.updateClient(name: 'Depois');
      expect(await VetRepository.flush(), isTrue);
      expect(storage.saveCalls, 1);
      expect(VetRepository.clientName, 'Depois');
    });

    test('ID de pet duplicado reverte toda a mutação pendente', () async {
      final storage = _SequenceStorage([const LocalLoadResult.empty()]);
      await VetRepository.initialize(storage: storage);
      final petsBefore = List.of(VetRepository.pets);
      // Acesso direto à lista pública, contornando as 11 mutações.
      VetRepository.pets.add(petsBefore.first.copyWith(name: 'Duplicado'));

      expect(
        () => VetRepository.updateClient(name: 'Não deve ficar'),
        throwsA(isA<FormatException>()),
      );

      expect(VetRepository.pets.map((pet) => pet.id), [
        for (final pet in petsBefore) pet.id,
      ]);
      expect(VetRepository.clientName, 'Liminha');
      expect(await VetRepository.flush(), isTrue);
      expect(storage.saveCalls, 0);
    });

    test('rollback de remoção restaura também a seleção do pet', () async {
      final storage = _SequenceStorage([const LocalLoadResult.empty()]);
      await VetRepository.initialize(storage: storage);
      final selected = VetRepository.pets.first;
      VetRepository.selectedPetId = selected.id;
      VetRepository.addresses.add(
        const SavedAddress(id: '', street: 'Estado inválido'),
      );

      expect(
        () => VetRepository.removePet(selected),
        throwsA(isA<FormatException>()),
      );

      expect(VetRepository.petById(selected.id), same(selected));
      expect(VetRepository.selectedPetId, selected.id);
      expect(VetRepository.addresses, isEmpty);
      expect(storage.saveCalls, 0);
    });
  });

  group('A1 — recuperação segura', () {
    testWidgets('falha transitória: tentar novamente recupera o app', (
      tester,
    ) async {
      final storage = _SequenceStorage([
        LocalLoadResult.unavailable(StateError('falha 1')),
        LocalLoadResult.unavailable(StateError('falha 2')),
        LocalLoadResult.valid(stateWith()),
      ]);
      await tester.runAsync(
        () async => VetRepository.initialize(storage: storage),
      );
      await tester.pumpWidget(const VetHomeApp());

      final retry = find.byKey(const ValueKey('critical-storage-retry'));
      expect(find.text('Tentar novamente'), findsOneWidget);

      await tester.runAsync(VetRepository.retryInitialization);
      await tester.pumpWidget(const VetHomeApp());
      expect(storage.loadCalls, 2);
      expect(VetRepository.persistenceStatus, LocalLoadStatus.unavailable);
      expect(find.byType(CriticalStorageErrorPage), findsOneWidget);
      expect(retry, findsOneWidget);
      expect(storage.saveCalls, 0);

      await tester.runAsync(VetRepository.retryInitialization);
      await tester.pumpWidget(const VetHomeApp());
      expect(storage.loadCalls, 3);
      expect(VetRepository.persistenceBlocked, isFalse);
      expect(VetRepository.clientName, 'Cliente salvo');
      expect(find.byType(CriticalStorageErrorPage), findsNothing);
      expect(storage.saveCalls, 0);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1500));
    });

    testWidgets('falha inesperada ao tentar novamente mantém a interface', (
      tester,
    ) async {
      var retryCalls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: CriticalStorageErrorPage(
            status: LocalLoadStatus.unavailable,
            onRetry: () async {
              retryCalls++;
              throw StateError('falha inesperada');
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('critical-storage-retry')));
      await tester.pump();
      await tester.pump();

      expect(retryCalls, 1);
      expect(find.byType(CriticalStorageErrorPage), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('snapshot inválido não oferece "Tentar novamente"', (
      tester,
    ) async {
      final storage = _SequenceStorage([
        const LocalLoadResult.invalid(FormatException('inválido')),
      ]);
      await tester.runAsync(
        () async => VetRepository.initialize(storage: storage),
      );
      await tester.pumpWidget(const VetHomeApp());

      expect(find.byType(CriticalStorageErrorPage), findsOneWidget);
      expect(find.text('Tentar novamente'), findsNothing);
      await VetRepository.retryInitialization();
      expect(storage.loadCalls, 1);
      expect(VetRepository.persistenceStatus, LocalLoadStatus.invalid);
      expect(storage.saveCalls, 0);
    });

    test('snapshot inválido mantém bloqueio e bytes originais', () async {
      const original = '{snapshot-corrompido';
      SharedPreferences.setMockInitialValues({LocalStorage.stateKey: original});
      await VetRepository.initialize();
      expect(VetRepository.persistenceStatus, LocalLoadStatus.invalid);

      await VetRepository.retryInitialization();

      expect(VetRepository.persistenceStatus, LocalLoadStatus.invalid);
      expect(VetRepository.persistenceBlocked, isTrue);
      expect(
        () => VetRepository.updateClient(name: 'Não pode salvar'),
        throwsA(isA<PersistenceBlockedException>()),
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocalStorage.stateKey), original);
    });

    test('indisponível que passa a inválido continua bloqueado', () async {
      final storage = _SequenceStorage([
        LocalLoadResult.unavailable(StateError('falha')),
        const LocalLoadResult.invalid(FormatException('corrompido')),
      ]);
      await VetRepository.initialize(storage: storage);

      await VetRepository.retryInitialization();

      expect(VetRepository.persistenceStatus, LocalLoadStatus.invalid);
      expect(VetRepository.persistenceBlocked, isTrue);
      expect(storage.loadCalls, 2);
      expect(storage.saveCalls, 0);
    });

    test(
      'nova leitura não grava nem libera escrita se ainda indisponível',
      () async {
        final storage = _SequenceStorage([
          LocalLoadResult.unavailable(StateError('falha')),
        ]);
        await VetRepository.initialize(storage: storage);

        await VetRepository.retryInitialization();

        expect(VetRepository.persistenceStatus, LocalLoadStatus.unavailable);
        expect(
          () => VetRepository.updateClient(name: 'Bloqueado'),
          throwsA(isA<PersistenceBlockedException>()),
        );
        expect(await VetRepository.flush(), isFalse);
        expect(storage.saveCalls, 0);
      },
    );
  });
}
