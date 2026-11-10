import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/sobre_page.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

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

  testWidgets('Sobre anuncia os contatos como fictícios', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const MaterialApp(home: SobreScreen()));
      await tester.pumpAndSettle();

      final phone = find.bySemanticsLabel(
        'Telefone fictício para demonstração: 11 9793-8918',
      );
      final email = find.bySemanticsLabel(
        'E-mail fictício para demonstração: Kelvinpro@gmail.com',
      );
      expect(phone, findsOneWidget);
      expect(email, findsOneWidget);
      expect(
        tester
            .getSemantics(phone)
            .getSemanticsData()
            .hasAction(SemanticsAction.longPress),
        isTrue,
      );
      expect(
        tester
            .getSemantics(email)
            .getSemanticsData()
            .hasAction(SemanticsAction.longPress),
        isTrue,
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('Sobre permite trocar de tela sem destacar uma aba', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SobreScreen()));
    await tester.pumpAndSettle();

    final navigation = find.byType(VetBottomNav);
    expect(navigation, findsOneWidget);
    for (final label in [
      'Pets',
      'Perfil',
      'Conversa',
      'Agenda',
      'Configurações',
    ]) {
      final destination = find.descendant(
        of: navigation,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == label &&
              widget.properties.selected == false,
        ),
      );
      expect(
        destination,
        findsOneWidget,
        reason: '$label não deve parecer ativa.',
      );
    }
  });
}
