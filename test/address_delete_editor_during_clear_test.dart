import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';

class _BlockingClearStorage extends LocalStorage {
  _BlockingClearStorage(this.address);

  final SavedAddress address;
  final clearStarted = Completer<void>();
  final finishClear = Completer<void>();

  @override
  Future<LocalLoadResult> load() async => LocalLoadResult.valid(
    LocalState(
      client: ClientData(
        name: 'Cliente de teste',
        birthDate: DateTime(1990, 1, 1),
        address: address.summary,
        phone: '',
        email: '',
        gender: '',
        addresses: [address],
      ),
      pets: const [],
      appointments: const {},
    ),
  );

  @override
  Future<void> save(LocalState state) async {}

  @override
  Future<void> clear() async {
    clearStarted.complete();
    await finishClear.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('exclusão pelo editor distingue bloqueio de falha ao salvar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const address = SavedAddress(
      id: 'home',
      name: 'Casa',
      street: 'Rua Antiga',
      number: '12',
      city: 'São Paulo',
      cep: '01001-000',
    );
    final storage = _BlockingClearStorage(address);
    await VetRepository.initialize(storage: storage);

    await tester.pumpWidget(const MaterialApp(home: AddressesPage()));
    await tester.pumpAndSettle();

    final clearing = VetRepository.clearLocalData();
    await storage.clearStarted.future;

    await tester.tap(
      find.bySemanticsLabel('Editar endereço Casa, Rua Antiga, 12'),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 3),
    );
    expect(find.byKey(const ValueKey('address-editor-dialog')), findsOneWidget);

    final deleteButton = find.bySemanticsLabel('Excluir endereço');
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 3),
    );
    expect(find.text('Excluir endereço?'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Excluir'),
      ),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 3),
    );

    expect(find.byKey(const ValueKey('address-editor-dialog')), findsNothing);
    expect(VetRepository.addresses, hasLength(1));
    expect(
      find.text(
        'A exclusão individual foi bloqueada enquanto os dados estavam '
        'sendo limpos.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    storage.finishClear.complete();
    await clearing;
    await tester.pumpAndSettle();
    expect(VetRepository.addresses, isEmpty);
  });
}
