import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/cadastroPet_page.dart';
import 'package:flutter_vethome/pages/endereco_page.dart';

class _ProfileStorage extends LocalStorage {
  int saveCalls = 0;

  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) async {
    saveCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = _ProfileStorage();

  setUpAll(() async {
    await VetRepository.initialize(storage: storage);
  });

  setUp(() {
    storage.saveCalls = 0;
    VetRepository.clientName = 'Liminha';
    VetRepository.clientEmail = '';
    VetRepository.clientPhone = '';
    VetRepository.clientAddress = '';
    VetRepository.addresses.clear();
  });

  void seedExistingLocalProfile() {
    const address = SavedAddress(
      id: 'pessoa-a-address',
      street: 'Rua da Pessoa A, 10',
    );
    VetRepository.clientName = 'Pessoa A';
    VetRepository.clientEmail = 'pessoa-a@example.test';
    VetRepository.clientAddress = address.summary;
    VetRepository.addresses
      ..clear()
      ..add(address);
  }

  Future<void> skip(WidgetTester tester) async {
    final button = find.widgetWithText(TextButton, 'Pular');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<void> tapSkipWhileShowingConflict(WidgetTester tester) async {
    final button = find.widgetWithText(TextButton, 'Pular');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  testWidgets('outro e-mail não herda endereço do perfil local', (
    tester,
  ) async {
    seedExistingLocalProfile();

    await tester.pumpWidget(
      MaterialApp(
        home: const EnderecoScreen(
          initialData: {
            'client.Nome Completo': 'Pessoa B',
            'client.E-mail': 'pessoa-b@example.test',
          },
        ),
        routes: {
          '/cadastroPet': (_) => const Scaffold(body: Text('Etapa pet')),
        },
      ),
    );
    await tapSkipWhileShowingConflict(tester);

    expect(
      find.byKey(const ValueKey('local-profile-conflict-dialog')),
      findsOneWidget,
    );
    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    expect(find.text('Etapa pet'), findsNothing);
    expect(VetRepository.clientName, 'Pessoa A');
    expect(VetRepository.clientEmail, 'pessoa-a@example.test');
    expect(VetRepository.clientAddress, 'Rua da Pessoa A, 10');
    expect(VetRepository.addresses.single.street, 'Rua da Pessoa A, 10');
    expect(storage.saveCalls, 0);
  });

  testWidgets('nome diferente sem e-mail não pode pular o endereço', (
    tester,
  ) async {
    seedExistingLocalProfile();

    await tester.pumpWidget(
      MaterialApp(
        home: const EnderecoScreen(
          initialData: {'client.Nome Completo': 'Pessoa B'},
        ),
        routes: {
          '/cadastroPet': (_) => const Scaffold(body: Text('Etapa pet')),
        },
      ),
    );
    await tapSkipWhileShowingConflict(tester);

    expect(
      find.byKey(const ValueKey('local-profile-conflict-dialog')),
      findsOneWidget,
    );
    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    expect(find.text('Etapa pet'), findsNothing);
    expect(VetRepository.clientName, 'Pessoa A');
    expect(VetRepository.clientEmail, 'pessoa-a@example.test');
    expect(VetRepository.clientAddress, 'Rua da Pessoa A, 10');
    expect(storage.saveCalls, 0);
  });

  testWidgets('mesmo e-mail mantém endereço quando a etapa é pulada', (
    tester,
  ) async {
    seedExistingLocalProfile();

    await tester.pumpWidget(
      MaterialApp(
        home: const EnderecoScreen(
          initialData: {
            'client.Nome Completo': 'Pessoa A',
            'client.E-mail': 'PESSOA-A@example.test',
          },
        ),
        routes: {
          '/cadastroPet': (_) => const Scaffold(body: Text('Etapa pet')),
        },
      ),
    );
    await skip(tester);

    expect(
      find.byKey(const ValueKey('local-profile-conflict-dialog')),
      findsNothing,
    );
    expect(find.text('Etapa pet'), findsOneWidget);
    expect(VetRepository.clientEmail, 'PESSOA-A@example.test');
    expect(VetRepository.clientAddress, 'Rua da Pessoa A, 10');
    expect(VetRepository.addresses.single.street, 'Rua da Pessoa A, 10');
    expect(storage.saveCalls, 1);
  });

  testWidgets('cadastro pet direto bloqueia outro perfil antes de salvar', (
    tester,
  ) async {
    seedExistingLocalProfile();
    final petIdsBeforeAttempt = VetRepository.pets
        .map((pet) => pet.id)
        .toList();

    await tester.pumpWidget(
      MaterialApp(
        home: const CadastroPetScreen(
          initialData: {
            'client.Nome Completo': 'Pessoa B',
            'client.E-mail': 'pessoa-b@example.test',
          },
        ),
        routes: {
          '/sucesso': (_) => const Scaffold(body: Text('Cadastro concluído')),
        },
      ),
    );
    await tapSkipWhileShowingConflict(tester);

    expect(
      find.byKey(const ValueKey('local-profile-conflict-dialog')),
      findsOneWidget,
    );
    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastro concluído'), findsNothing);
    expect(VetRepository.clientEmail, 'pessoa-a@example.test');
    expect(
      VetRepository.pets.map((pet) => pet.id).toList(),
      petIdsBeforeAttempt,
    );
    expect(storage.saveCalls, 0);
  });

  test('repositório rejeita substituição direta por outro e-mail', () {
    seedExistingLocalProfile();

    expect(
      () => VetRepository.registerClient({
        'client.Nome Completo': 'Pessoa B',
        'client.E-mail': 'pessoa-b@example.test',
      }),
      throwsA(isA<LocalProfileConflictException>()),
    );
    expect(VetRepository.clientName, 'Pessoa A');
    expect(VetRepository.clientEmail, 'pessoa-a@example.test');
    expect(VetRepository.clientAddress, 'Rua da Pessoa A, 10');
    expect(storage.saveCalls, 0);
  });

  test('repositório rejeita troca de nome sem e-mail de identificação', () {
    seedExistingLocalProfile();

    expect(
      () => VetRepository.registerClient({'client.Nome Completo': 'Pessoa B'}),
      throwsA(isA<LocalProfileConflictException>()),
    );
    expect(VetRepository.clientName, 'Pessoa A');
    expect(VetRepository.clientEmail, 'pessoa-a@example.test');
    expect(VetRepository.clientAddress, 'Rua da Pessoa A, 10');
    expect(storage.saveCalls, 0);
  });

  test('login aceita o e-mail do perfil local e rejeita outro', () {
    seedExistingLocalProfile();

    expect(
      VetRepository.authenticate('PESSOA-A@example.test', '123456'),
      isTrue,
    );
    expect(
      VetRepository.authenticate('pessoa-b@example.test', '123456'),
      isFalse,
    );
  });
}
