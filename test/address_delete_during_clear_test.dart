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

  testWidgets('excluir durante limpeza avisa sem derrubar a tela', (
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
    await storage.clearStarted.future.timeout(const Duration(seconds: 3));

    final deleteTarget = find.bySemanticsLabel(
      'Deletar endereço Casa, Rua Antiga, 12',
    );
    await tester.ensureVisible(deleteTarget);
    final targetRect = tester.getRect(deleteTarget);
    await tester.tapAt(Offset(targetRect.center.dx, targetRect.top + 5));
    await tester.pumpAndSettle();
    expect(find.text('Excluir endereço?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Excluir'),
      ),
    );
    await tester.pumpAndSettle();

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
