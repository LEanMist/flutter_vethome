import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/cadastro_pet_page.dart';

void main() {
  testWidgets('pet type and gender use bottom sheet selectors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CadastroPetPage(destinoBuilder: (_) => const SizedBox.shrink()),
      ),
    );

    final campos = find.byType(TextField);
    await tester.ensureVisible(campos.at(0));
    await tester.tap(campos.at(0));
    await tester.pumpAndSettle();

    expect(find.text('Selecione o tipo de animal'), findsOneWidget);
    await tester.tap(find.text('Gato'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(campos.at(0)).controller!.text, 'Gato');

    await tester.ensureVisible(campos.at(2));
    await tester.tap(campos.at(2));
    await tester.pumpAndSettle();

    expect(find.text('Selecione o gênero do pet'), findsOneWidget);
    await tester.tap(find.text('Fêmea'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(campos.at(2)).controller!.text, 'Fêmea');
  });
}
