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

const _blockedMessage =
    'O endereço não foi salvo porque o armazenamento local está bloqueado. '
    'Os dados digitados continuam no formulário.';

class _BlockedAddressStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async =>
      const LocalLoadResult.invalid(FormatException('snapshot bloqueado'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('salvamento bloqueado mantém formulário e explica o motivo', (
    tester,
  ) async {
    await VetRepository.initialize(storage: _BlockedAddressStorage());
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: AddressEditorPage(address: _address)),
    );
    await tester.pumpAndSettle();
    final streetField = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Logradouro',
      ),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(streetField, 'Rua Nova');
    final save = find.bySemanticsLabel('Salvar endereço');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text(_blockedMessage), findsOneWidget);
    expect(
      tester.widget<TextFormField>(streetField).controller!.text,
      'Rua Nova',
    );
    expect(VetRepository.addresses, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
