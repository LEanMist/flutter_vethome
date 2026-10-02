import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/teste_page.dart';

void main() {
  testWidgets('catalogo de telas abre com os pets de exemplo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TestePage()));

    expect(find.text('Telas do projeto'), findsOneWidget);
    expect(find.text('Detalhes do pet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
