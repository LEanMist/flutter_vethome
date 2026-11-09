import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/teste_page.dart';
import 'package:flutter_vethome/widgets/debug_screen_switcher.dart';

class _MemoryStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) async {}
}

void main() {
  testWidgets('catalogo de telas abre com os pets de exemplo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TestePage()));

    expect(find.text('Telas do projeto'), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('seletor global abre uma tela e continua disponível', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await VetRepository.initialize(storage: _MemoryStorage());

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: Text('Tela inicial do teste')),
        builder: (context, child) => DebugScreenSwitcher(
          navigatorKey: navigatorKey,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final switcher = find.byKey(const ValueKey('debug-screen-switcher-button'));
    expect(switcher, findsOneWidget);
    await tester.tap(switcher);
    await tester.pumpAndSettle();
    expect(find.text('Telas do projeto'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Agenda'), 250);
    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('agenda-selected-date')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('debug-screen-switcher-button')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
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
