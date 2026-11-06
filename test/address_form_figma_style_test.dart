import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';

void main() {
  const address = SavedAddress(
    id: 'figma-edit-address',
    name: 'Casa da Irmã',
    street: 'Rua das Flores',
    number: '73',
    complement: 'Caixa da Água',
    city: 'Perus - São Paulo',
    cep: '34556-234',
  );

  testWidgets('EDIT_ADRESS_WIDGET mantém campos e ações do Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const MaterialApp(home: AddressEditorPage(address: address)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Numero'), findsOneWidget);
    expect(find.text('Número'), findsNothing);
    expect(find.text('Complemento'), findsOneWidget);
    expect(find.text('Complemento (opcional)'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Excluir'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Salvar'), findsOneWidget);
    expect(find.text('Salvar endereço'), findsNothing);

    final icons = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
    );
    expect(icons, findsNWidgets(6));
    for (var index = 0; index < 6; index++) {
      expect(tester.getSize(icons.at(index)), const Size(58, 56));
    }

    final deleteButton = find.widgetWithText(OutlinedButton, 'Excluir');
    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar');
    expect(tester.getSize(deleteButton), const Size(90, 34));
    expect(tester.getSize(saveButton), const Size(90, 34));
    expect(
      tester.getTopLeft(saveButton).dx - tester.getTopRight(deleteButton).dx,
      closeTo(79, 1),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    expect(find.text('Excluir endereço?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(AddressEditorPage), findsOneWidget);
  });
}
