import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/teste_page.dart';

void main() {
  testWidgets('catalogo de telas abre com os pets de exemplo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TestePage()));

    expect(find.text('Telas do projeto'), findsOneWidget);
    expect(find.text('Detalhes do pet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('atalhos da Gabriela abrem as rotas correspondentes', (
    tester,
  ) async {
    const destinations = {
      'Gabriela - Login': '/gabriela/login',
      'Gabriela - Perfil': '/gabriela/perfil',
      'Gabriela - WhatsApp': '/gabriela/mensagens',
      'Gabriela - Agenda': '/gabriela/agenda',
      'Gabriela - Configurações': '/gabriela/configuracoes',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: const TestePage(),
        routes: {
          for (final route in destinations.values)
            route: (_) => Scaffold(body: Text(route)),
        },
      ),
    );

    for (final entry in destinations.entries) {
      final button = find.widgetWithText(OutlinedButton, entry.key);
      await tester.scrollUntilVisible(button, 300);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      Navigator.of(tester.element(find.text(entry.value))).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('nova consulta abre servicos sem escolher pet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/details',
        routes: {
          '/details': (_) => DetalhesPetPage(pet: VetRepository.pets.first),
          '/servicos': (_) => const Scaffold(body: Text('Serviços')),
          '/escolhaPet': (_) => const Scaffold(body: Text('Escolha seu Pet')),
        },
      ),
    );

    expect(find.text('Nova Consulta'), findsOneWidget);
    await tester.ensureVisible(find.text('Nova Consulta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova Consulta'));
    await tester.pumpAndSettle();

    expect(find.text('Serviços'), findsOneWidget);
    expect(find.text('Escolha seu Pet'), findsNothing);
  });
}
