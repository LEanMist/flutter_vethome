import 'package:flutter_vethome/auth/auth_session.dart';
import 'package:flutter_vethome/auth/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_area_page.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/pages/splashScreen.dart';
import 'package:flutter_vethome/pages/teste_page.dart';
import 'package:flutter_vethome/routes/app_routes.dart';
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
    expect(find.text('Splash'), findsOneWidget);
    expect(find.text('Início'), findsNothing);
    expect(find.text('Apresentação'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Gabriela - Perfil'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Splash do seletor continua para o login do Cliente', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          ...AppRoutes.routes,
          '/catalogo-teste': (_) => const TestePage(),
        },
        initialRoute: '/catalogo-teste',
      ),
    );
    await tester.tap(find.text('Splash'));
    await tester.pumpAndSettle();
    final splash = find.byType(SplashScreen);
    expect(splash, findsOneWidget);
    expect(ModalRoute.of(tester.element(splash))?.settings.name, '/');

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    final login = find.byType(LoginPage);
    expect(ModalRoute.of(tester.element(login))?.settings.name, '/login');
    expect(tester.takeException(), isNull);
  });

  testWidgets('atalho de sucesso mostra o perfil salvo', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      AuthScope(
        session: AuthSession(const DemoAuthentication())
          ..start(const AuthenticatedUser(id: 'teste', role: UserRole.cliente)),
        child: MaterialApp(
          home: const TestePage(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(accessibleNavigation: true),
            child: child ?? const SizedBox.shrink(),
          ),
          routes: {'/pets': (_) => const Scaffold(body: Text('Início'))},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final successShortcut = find.text('Sucesso no cadastro');
    await tester.ensureVisible(successShortcut);
    await tester.tap(successShortcut);
    await tester.pumpAndSettle();

    expect(find.text('Usuário\nCadastrado!'), findsOneWidget);
    expect(
      find.text(
        'Perfil salvo neste dispositivo. Esta demonstração não cria contas on-line.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('registration-success-continue')),
      findsOneWidget,
    );
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
      AuthScope(
        session: AuthSession(const DemoAuthentication())
          ..start(const AuthenticatedUser(id: 'teste', role: UserRole.cliente)),
        child: MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('Tela inicial do teste')),
          builder: (context, child) => DebugScreenSwitcher(
            navigatorKey: navigatorKey,
            child: child ?? const SizedBox.shrink(),
          ),
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

  testWidgets('atalhos da Gabriela abrem as rotas correspondentes', (
    tester,
  ) async {
    const destinations = {
      'Gabriela - Perfil': '/gabriela/perfil',
      'Gabriela - Chat': '/gabriela/mensagens',
      'Gabriela - Agenda': '/gabriela/agenda',
      'Gabriela - Configurações': '/gabriela/configuracoes',
    };

    await tester.pumpWidget(
      AuthScope(
        session: AuthSession(const DemoAuthentication())
          ..start(
            const AuthenticatedUser(id: 'teste', role: UserRole.veterinaria),
          ),
        child: MaterialApp(
          home: const TestePage(),
          routes: {
            for (final route in destinations.values)
              route: (_) => Scaffold(body: Text(route)),
          },
        ),
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

  testWidgets('rotas nomeadas abrem diretamente as abas da Gabriela', (
    tester,
  ) async {
    const destinations = {
      '/gabriela/perfil': 'Perfil',
      '/gabriela/mensagens': 'Chat',
      '/gabriela/agenda': 'Agenda',
      '/gabriela/configuracoes': 'Configurações',
    };
    for (final entry in destinations.entries) {
      final routes = Map<String, WidgetBuilder>.of(AppRoutes.routes)
        ..remove('/');
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.pushNamed(context, entry.key),
                child: const Text('Abrir aba'),
              ),
            ),
          ),
          routes: routes,
        ),
      );
      await tester.tap(find.text('Abrir aba'));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == entry.value &&
              widget.properties.selected == true,
        ),
        findsOneWidget,
      );
      Navigator.of(tester.element(find.byType(GabrielaAreaPage))).pop();
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
