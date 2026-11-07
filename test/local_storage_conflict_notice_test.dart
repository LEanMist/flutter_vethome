import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/config_page.dart';

class _ConflictStorage extends LocalStorage {
  LocalState? externalState;
  bool failReload = false;
  int loadCalls = 0;

  @override
  LocalStorage createReloadInstance() => this;

  @override
  Future<LocalLoadResult> load() {
    loadCalls++;
    if (failReload) {
      return Future.value(
        LocalLoadResult.unavailable(StateError('Storage indisponível')),
      );
    }
    final state = externalState;
    return Future.value(
      state == null
          ? const LocalLoadResult.empty()
          : LocalLoadResult.valid(state),
    );
  }

  @override
  Future<void> save(LocalState state) async {
    throw LocalStorageConflictException.modified();
  }
}

LocalState _latestState({String name = 'Perfil da outra janela'}) => LocalState(
  client: ClientData(
    name: name,
    birthDate: DateTime(2007, 2, 5),
    address: '',
    phone: '',
    email: '',
    gender: '',
  ),
  pets: const [],
  appointments: const {},
);

Future<void> _causeConflict(WidgetTester tester) async {
  await tester.runAsync(() async {
    VetRepository.addPet(
      name: 'Pet em conflito',
      species: 'Cachorro',
      sex: 'Macho',
      weightKg: 10,
      birthDate: DateTime(2020),
      breed: 'SRD',
    );
    expect(await VetRepository.flush(), isFalse);
  });
  await tester.pumpAndSettle();
}

Future<void> _confirmReload(
  WidgetTester tester,
  _ConflictStorage storage,
) async {
  await tester.tap(
    find.widgetWithText(TextButton, 'Carregar dados atualizados'),
  );
  await tester.pumpAndSettle();
  expect(find.text('Carregar dados atualizados?'), findsOneWidget);
  expect(find.textContaining('serão descartadas'), findsOneWidget);
  await tester.tap(find.widgetWithText(TextButton, 'Carregar dados'));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Configurações carrega a versão atual após confirmar', (
    tester,
  ) async {
    final storage = _ConflictStorage();
    await VetRepository.initialize(storage: storage);
    await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));

    await _causeConflict(tester);

    expect(
      find.textContaining('Outra janela alterou os dados salvos.'),
      findsOneWidget,
    );
    final reload = find.widgetWithText(
      TextButton,
      'Carregar dados atualizados',
    );
    expect(reload, findsOneWidget);
    expect(tester.widget<TextButton>(reload).onPressed, isNotNull);

    storage.externalState = _latestState();
    expect(
      VetRepository.lastPersistenceError,
      isA<LocalStorageConflictException>(),
    );
    expect(VetRepository.savingChanges.value, isFalse);
    await _confirmReload(tester, storage);

    expect(storage.loadCalls, 2);
    expect(VetRepository.clientName, 'Perfil da outra janela');
    expect(VetRepository.pets, isEmpty);
    expect(VetRepository.unsavedChanges.value, isFalse);
    expect(
      find.textContaining('Outra janela alterou os dados salvos.'),
      findsNothing,
    );
    expect(
      find.textContaining('Dados atualizados carregados.'),
      findsOneWidget,
    );
    await _causeConflict(tester);
    storage.failReload = true;
    await _confirmReload(tester, storage);

    expect(
      VetRepository.pets.any((pet) => pet.name == 'Pet em conflito'),
      isTrue,
    );
    expect(VetRepository.unsavedChanges.value, isTrue);
    expect(
      VetRepository.lastPersistenceError,
      isA<LocalStorageConflictException>(),
    );
    expect(
      find.textContaining('As alterações desta janela foram mantidas.'),
      findsOneWidget,
    );

    storage.failReload = false;
    storage.externalState = _latestState(name: 'Versão preservada');
    await tester.pumpWidget(
      MaterialApp(
        home: ConfigScreen(
          clearLocalUserData: () async {
            VetRepository.lastPersistenceError =
                LocalStorageConflictException.modified();
            return false;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(ListTile, 'Sair'));
    await tester.tap(find.widgetWithText(ListTile, 'Sair'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar dados locais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar dados'));
    await tester.pumpAndSettle();
    expect(find.text('Dados atualizados em outra janela'), findsOneWidget);
    expect(find.textContaining('Nenhum dado foi apagado.'), findsOneWidget);

    await tester.tap(find.text('Carregar dados atuais'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(VetRepository.clientName, 'Versão preservada');
    expect(
      find.textContaining('Revise e confirme a exclusão novamente.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
