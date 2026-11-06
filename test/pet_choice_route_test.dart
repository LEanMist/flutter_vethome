import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/agenda_page.dart';
import 'package:flutter_vethome/routes/app_routes.dart';

void main() {
  testWidgets('rota móvel /escolhaPet abre o painel sobre a Agenda', (
    tester,
  ) async {
    final previousId = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previousId);
    final pet = VetRepository.pets.first;

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/escolhaPet'),
                child: const Text('Abrir escolha de pet'),
              ),
            ),
          ),
        ),
        routes: {
          '/escolhaPet': AppRoutes.routes['/escolhaPet']!,
          '/servicos': (_) => const Scaffold(body: Text('Serviços abertos')),
        },
      ),
    );

    await tester.tap(find.text('Abrir escolha de pet'));
    await tester.pumpAndSettle();

    expect(find.byType(AgendaScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('pet-choice-dialog')), findsOneWidget);
    expect(
      tester.getRect(find.byKey(const ValueKey('pet-choice-panel'))),
      const Rect.fromLTWH(0, 218, 390, 408),
    );

    await tester.tap(find.byKey(ValueKey('pet-choice-${pet.id}')));
    await tester.pumpAndSettle();

    expect(VetRepository.selectedPetId, pet.id);
    expect(find.text('Serviços abertos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rota desktop /escolhaPet preserva a página ampla', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/escolhaPet'),
                child: const Text('Abrir escolha de pet'),
              ),
            ),
          ),
        ),
        routes: {'/escolhaPet': AppRoutes.routes['/escolhaPet']!},
      ),
    );

    await tester.tap(find.text('Abrir escolha de pet'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('pet-choice-desktop-grid')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('pet-choice-dialog')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
