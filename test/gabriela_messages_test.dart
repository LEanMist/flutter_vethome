import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_messages_tab.dart';

void main() {
  testWidgets(
    'rascunhos ficam em suas conversas e prévia mostra mensagem enviada',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GabrielaMessagesTab())),
      );

      await tester.tap(find.text('Nicolly'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Rascunho da Nicolly');
      await tester.tap(find.byTooltip('Voltar para as conversas'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Caio'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.enterText(find.byType(TextField), 'Mensagem para Caio');
      await tester.tap(find.byTooltip('Enviar mensagem'));
      await tester.pumpAndSettle();
      expect(find.text('Mensagem para Caio'), findsOneWidget);
      await tester.tap(find.byTooltip('Voltar para as conversas'));
      await tester.pumpAndSettle();
      expect(find.text('Mensagem para Caio'), findsOneWidget);

      await tester.tap(find.text('Nicolly'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Rascunho da Nicolly',
      );
    },
  );
}
