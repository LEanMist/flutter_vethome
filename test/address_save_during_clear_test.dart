import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';
import 'package:flutter_vethome/widgets.dart';

const _address = SavedAddress(
  id: 'home',
  name: 'Casa',
  street: 'Rua Antiga',
  number: '12',
  city: 'São Paulo',
  cep: '01001-000',
);

const _clearingMessage =
    'O endereço não foi salvo porque os dados locais estão sendo limpos. '
    'Os dados digitados continuam no formulário.';

class _BlockingClearStorage extends LocalStorage {
  final clearStarted = Completer<void>();
  final finishClear = Completer<void>();

  @override
  Future<LocalLoadResult> load() async => LocalLoadResult.valid(
    LocalState(
      client: ClientData(
        name: 'Cliente de teste',
        birthDate: DateTime(1990, 1, 1),
        address: _address.summary,
        phone: '',
        email: '',
        gender: '',
        genderCustom: '',
        addresses: const [_address],
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

  Finder streetField() => find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == 'Logradouro',
    ),
    matching: find.byType(TextFormField),
  );

  testWidgets('salvamento durante limpeza mantém formulário e endereço', (
    tester,
  ) async {
    final storage = _BlockingClearStorage();
    await VetRepository.initialize(storage: storage);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: AddressEditorPage(address: _address)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(streetField(), 'Rua Nova');

    late Future<bool> clearing;
    await tester.runAsync(() async {
      clearing = VetRepository.clearLocalData();
      await storage.clearStarted.future.timeout(const Duration(seconds: 3));
    });
    addTearDown(() async {
      if (!storage.finishClear.isCompleted) storage.finishClear.complete();
      await clearing;
    });

    final save = find.bySemanticsLabel('Salvar endereço');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text(_clearingMessage), findsOneWidget);
    expect(
      tester.widget<TextFormField>(streetField()).controller!.text,
      'Rua Nova',
    );
    expect(VetRepository.addresses.single.street, 'Rua Antiga');
    expect(tester.takeException(), isNull);

    storage.finishClear.complete();
    await clearing;
    await tester.pumpAndSettle();
  });
}
