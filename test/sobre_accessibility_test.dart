import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/sobre_page.dart';

void main() {
  testWidgets('o logotipo da veterinária tem descrição acessível', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const MaterialApp(home: SobreScreen()));
      await tester.pumpAndSettle();

      final logo = find.bySemanticsLabel(
        'Logotipo VetHome, Serviços Veterinários',
      );
      expect(logo, findsOneWidget);
      expect(tester.getSemantics(logo).flagsCollection.isImage, isTrue);
    } finally {
      semantics.dispose();
    }
  });
}
