import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_data_manager.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/config_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _storedSnapshot(SharedPreferences preferences) =>
    jsonDecode(preferences.getString(LocalStorage.stateKey)!)
        as Map<String, dynamic>;

Map<String, dynamic> _storedMetadata(SharedPreferences preferences) =>
    _storedSnapshot(preferences)[LocalStorage.storageMetadataKey]
        as Map<String, dynamic>;

class _FailingClearStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async => LocalLoadResult.valid(_savedState());

  @override
  Future<void> clear() async => throw StateError('falha ao remover');
}

LocalState _savedState() => LocalState(
  client: ClientData(
    name: 'Pessoa de teste',
    birthDate: DateTime(1990, 1, 2),
    address: 'Rua de teste, 10',
    phone: '11999990000',
    email: 'pessoa@example.test',
    gender: '',
    addresses: const [SavedAddress(id: 'teste', street: 'Rua de teste, 10')],
  ),
  pets: const [],
  appointments: const {},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      LocalDataManager.rememberedEmailKey: 'pessoa@example.test',
    });
    final storage = LocalStorage();
    await storage.load();
    await storage.save(_savedState());
    await VetRepository.initialize();
  });

  tearDown(() async {
    await VetRepository.flush();
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  void useNarrowViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  test('remove perfil salvo e e-mail lembrado sem apagar o tema', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('vethome.themeSeed.v1', 0xff68442e);

    expect(VetRepository.clientEmail, 'pessoa@example.test');
    expect(VetRepository.addresses.single.street, 'Rua de teste, 10');
    expect(await LocalDataManager.clearUserData(), isTrue);

    final stored = await LocalStorage().load();
    expect(stored.status, LocalLoadStatus.empty);
    expect(
      preferences.containsKey(LocalDataManager.rememberedEmailKey),
      isFalse,
    );
    expect(preferences.getInt('vethome.themeSeed.v1'), 0xff68442e);
    expect(VetRepository.clientName, 'Liminha');
    expect(VetRepository.clientEmail, isEmpty);
    expect(VetRepository.addresses, isEmpty);
    expect(VetRepository.pets, hasLength(4));
    expect(VetRepository.persistenceStatus, LocalLoadStatus.empty);
    expect(VetRepository.unsavedChanges.value, isFalse);
  });

  test(
    'limpar dados substitui o snapshot por um tombstone sem perfil',
    () async {
      final before = await SharedPreferences.getInstance();
      expect(before.getString(LocalStorage.stateKey), isNotNull);

      expect(await LocalDataManager.clearUserData(), isTrue);

      final after = await SharedPreferences.getInstance();
      expect(_storedSnapshot(after).containsKey('client'), isFalse);
      expect(_storedMetadata(after)['cleared'], isTrue);
    },
  );

  test(
    'sessão aberta não restaura snapshot depois de outra limpar dados',
    () async {
      final staleSession = LocalStorage();
      final deletingSession = LocalStorage();
      expect((await staleSession.load()).status, LocalLoadStatus.valid);
      expect((await deletingSession.load()).status, LocalLoadStatus.valid);

      await deletingSession.clear();
      await expectLater(
        staleSession.save(_savedState()),
        throwsA(isA<StateError>()),
      );

      final after = await LocalStorage().load();
      final preferences = await SharedPreferences.getInstance();
      expect(after.status, LocalLoadStatus.empty);
      expect(_storedSnapshot(preferences).containsKey('client'), isFalse);
      expect(_storedMetadata(preferences)['cleared'], isTrue);
      expect(_storedMetadata(preferences)['generation'], 1);
    },
  );

  test('falha ao limpar preserva perfil e e-mail lembrado', () async {
    SharedPreferences.setMockInitialValues({
      LocalDataManager.rememberedEmailKey: 'pessoa@example.test',
    });
    await VetRepository.initialize(storage: _FailingClearStorage());

    expect(await LocalDataManager.clearUserData(), isFalse);
    final preferences = await SharedPreferences.getInstance();
    expect(VetRepository.clientEmail, 'pessoa@example.test');
    expect(
      preferences.getString(LocalDataManager.rememberedEmailKey),
      'pessoa@example.test',
    );
  });

  testWidgets('sair mantém os dados locais e explica isso', (tester) async {
    useNarrowViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: const ConfigScreen(),
        routes: {'/login': (_) => const SizedBox(child: Text('Tela de login'))},
      ),
    );

    final signOut = find.widgetWithText(ListTile, 'Sair');
    await tester.ensureVisible(signOut);
    await tester.tap(signOut);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Os dados salvos continuam neste dispositivo.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Sair').last);
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(find.text('Tela de login'), findsOneWidget);
    expect(preferences.containsKey(LocalStorage.stateKey), isTrue);
    expect(
      preferences.containsKey(LocalDataManager.rememberedEmailKey),
      isTrue,
    );
  });

  testWidgets('apagar dados exige confirmação e permite cancelar', (
    tester,
  ) async {
    useNarrowViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: const ConfigScreen(),
        routes: {'/login': (_) => const SizedBox(child: Text('Tela de login'))},
      ),
    );

    final signOut = find.widgetWithText(ListTile, 'Sair');
    await tester.ensureVisible(signOut);
    await tester.tap(signOut);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar dados locais'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('perfil salvo, o e-mail lembrado'),
      findsOneWidget,
    );
    expect(
      find.textContaining('preferência de tema será mantida'),
      findsOneWidget,
    );
    final preferences = await SharedPreferences.getInstance();
    expect(find.text('Apagar os dados deste dispositivo?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Apagar os dados deste dispositivo?'), findsNothing);
    expect(find.text('Tela de login'), findsNothing);
    expect(preferences.containsKey(LocalStorage.stateKey), isTrue);
    expect(
      preferences.containsKey(LocalDataManager.rememberedEmailKey),
      isTrue,
    );
    expect(VetRepository.clientEmail, 'pessoa@example.test');
  });

  testWidgets('confirmação de apagar chama a limpeza antes de sair', (
    tester,
  ) async {
    useNarrowViewport(tester);
    var clearCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ConfigScreen(
          clearLocalUserData: () async {
            clearCalls++;
            return true;
          },
        ),
        routes: {'/login': (_) => const SizedBox(child: Text('Tela de login'))},
      ),
    );

    final signOut = find.widgetWithText(ListTile, 'Sair');
    await tester.ensureVisible(signOut);
    await tester.tap(signOut);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar dados locais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar dados'));
    await tester.pumpAndSettle();

    expect(clearCalls, 1);
    expect(find.text('Tela de login'), findsOneWidget);
  });

  testWidgets('falha ao apagar mantém a tela e informa o problema', (
    tester,
  ) async {
    useNarrowViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: ConfigScreen(clearLocalUserData: () async => false),
        routes: {'/login': (_) => const SizedBox(child: Text('Tela de login'))},
      ),
    );

    final signOut = find.widgetWithText(ListTile, 'Sair');
    await tester.ensureVisible(signOut);
    await tester.tap(signOut);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar dados locais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar dados'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível confirmar a remoção dos dados. Tente novamente.',
      ),
      findsOneWidget,
    );
    expect(find.text('Tela de login'), findsNothing);
    expect(VetRepository.clientEmail, 'pessoa@example.test');
    expect(tester.takeException(), isNull);
  });
}
