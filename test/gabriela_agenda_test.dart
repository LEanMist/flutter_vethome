import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_agenda_tab.dart';

void main() {
  testWidgets(
    'dados do paciente aparecem somente no atendimento correspondente',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GabrielaAgendaTab())),
      );

      await tester.tap(find.text('Rambo Augusto'));
      await tester.pumpAndSettle();
      expect(find.text('Lulu-da-Pomerânia'), findsOneWidget);
      expect(find.text('M  ·  24 kg  ·  23/03/2012'), findsOneWidget);
      Navigator.of(tester.element(find.text('Lulu-da-Pomerânia'))).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nicolly Santos'));
      await tester.pumpAndSettle();
      expect(find.text('Lulu-da-Pomerânia'), findsNothing);
      expect(find.text('M  ·  24 kg  ·  23/03/2012'), findsNothing);
      expect(find.text('Dados do paciente'), findsNothing);
    },
  );
}
