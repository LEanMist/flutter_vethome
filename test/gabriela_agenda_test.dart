import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_agenda_tab.dart';

void main() {
  testWidgets('consulta distingue cliente Rambo do pet Fernando', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GabrielaAgendaTab())),
    );

    await tester.ensureVisible(find.text('Rambo Augusto'));
    await tester.tap(find.text('Rambo Augusto'));
    await tester.pumpAndSettle();
    final dialog = find.byType(Dialog);
    Finder inDialog(String text) =>
        find.descendant(of: dialog, matching: find.text(text));
    expect(inDialog('Rambo'), findsOneWidget);
    expect(inDialog('Fernando'), findsOneWidget);
    expect(find.bySemanticsLabel('Foto de Fernando'), findsOneWidget);
    for (final field in [
      'Gênero/Sexo',
      'Peso',
      'Data de Nascimento',
      'Raça',
      'M',
      '24kg',
      '23 / 03 / 2012',
      'Lulu-da-Pomerânia',
      'Hemograma + 3',
      'R. Augusto Cury 123 - Vila Osasco',
    ]) {
      expect(inDialog(field), findsOneWidget);
    }
    Navigator.of(tester.element(inDialog('Fernando'))).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Nicolly Santos'));
    await tester.tap(find.text('Nicolly Santos'));
    await tester.pumpAndSettle();
    expect(inDialog('Fernando'), findsNothing);
    expect(inDialog('Lulu-da-Pomerânia'), findsNothing);
    expect(inDialog('24kg'), findsNothing);
    expect(find.bySemanticsLabel('Foto de Fernando'), findsNothing);
    semantics.dispose();
  });
}
