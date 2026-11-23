import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/auth/authentication.dart';
import 'package:flutter_vethome/data/gabriela_profile_repository.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/main.dart';
import 'package:flutter_vethome/pages/config_page.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_area_page.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/pages/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder get _login => find.byType(LoginPage);
Finder get _pets => find.byType(PetsPage);
Finder get _vet => find.byType(GabrielaAreaPage);
const _snapshotKey = 'vethome.state.v1';

Future<void> _open(
  WidgetTester tester,
  String route, {
  bool demo = true,
  Size size = const Size(390, 844),
}) async {
  final dispatcher = tester.binding.platformDispatcher;
  dispatcher.defaultRouteNameTestValue = route;
  addTearDown(dispatcher.clearDefaultRouteNameTestValue);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    VetHomeApp(authentication: demo ? const DemoAuthentication() : null),
  );
  await tester.pumpAndSettle();
}

NavigatorState _navigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator));

Future<void> _loginAs(
  WidgetTester tester,
  String email, {
  String password = DemoAuthentication.demoPassword,
}) async {
  final fields = find.descendant(of: _login, matching: find.byType(TextField));
  await tester.ensureVisible(fields.at(0));
  await tester.enterText(fields.at(0), email);
  await tester.ensureVisible(fields.at(1));
  await tester.enterText(fields.at(1), password);
  final submit = find.widgetWithText(ElevatedButton, 'Entrar');
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

String? _routeOf(WidgetTester tester, Finder page) =>
    ModalRoute.of(tester.element(page))?.settings.name;

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
    await GabrielaProfileRepository.initialize();
  });

  testWidgets('link da Splash antiga abre a única Splash e o único Login', (
    tester,
  ) async {
    await _open(tester, '/gabriela/splash');
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(_login, findsNothing);

    _navigator(tester).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Tela sobreposta')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Tela sobreposta'), findsOneWidget);
    expect(_login, findsNothing);

    _navigator(tester).pop();
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(_login, findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(_routeOf(tester, _login), '/login');
    expect(_navigator(tester).canPop(), isFalse);
  });

  for (final route in [
    '/gabriela/login',
    '/gabriela',
    '/gabriela/perfil',
    '/gabriela/mensagens',
    '/gabriela/agenda',
    '/gabriela/configuracoes',
    '/home',
    '/pets',
    '/sucesso',
  ]) {
    testWidgets('link direto $route exige a entrada única', (tester) async {
      await _open(tester, route);
      expect(_routeOf(tester, _login), '/login');
      expect(_vet, findsNothing);
      expect(_pets, findsNothing);
      expect(_navigator(tester).canPop(), isFalse);
    });
  }

  testWidgets('build sem demonstração rejeita credenciais fictícias', (
    tester,
  ) async {
    await _open(tester, '/login', demo: false);
    expect(find.text('Contas da demonstração'), findsNothing);
    await _loginAs(tester, DemoAuthentication.veterinarianEmail);
    expect(
      find.text('A autenticação está indisponível nesta versão.'),
      findsOneWidget,
    );
    expect(_vet, findsNothing);
  });

  testWidgets('senha incorreta e e-mail arbitrário ficam no Login', (
    tester,
  ) async {
    await _open(tester, '/login');
    for (final (email, password) in const [
      (DemoAuthentication.veterinarianEmail, 'errada'),
      ('outra@example.test', DemoAuthentication.demoPassword),
    ]) {
      await _loginAs(tester, email, password: password);
      expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
      expect(_login, findsOneWidget);
      expect(_vet, findsNothing);
      expect(_pets, findsNothing);
    }
  });

  testWidgets('papel protege as áreas e logout permite alternar contas', (
    tester,
  ) async {
    await tester.runAsync(() async {
      VetRepository.addPet(
        name: 'Pet persistido',
        species: 'Cachorro',
        sex: 'Macho',
        weightKg: 12,
        birthDate: DateTime(2022),
        breed: 'SRD',
      );
      expect(await VetRepository.flush(), isTrue);
      await GabrielaProfileRepository.updateName('Gabriela de teste');
    });
    final preferences = await SharedPreferences.getInstance();
    final storedSnapshot = preferences.getString(_snapshotKey);
    expect(storedSnapshot, isNotNull);

    await _open(tester, '/login', size: const Size(390, 960));
    await _loginAs(tester, DemoAuthentication.clientEmail);
    expect(_routeOf(tester, _pets), '/pets');
    expect(find.text('Pet persistido'), findsOneWidget);
    expect(_navigator(tester).canPop(), isFalse);

    _navigator(tester).pushReplacementNamed('/gabriela/agenda');
    await tester.pumpAndSettle();
    expect(_routeOf(tester, _pets), '/pets');
    expect(_vet, findsNothing);

    _navigator(tester).pushNamed('/config');
    await tester.pumpAndSettle();
    expect(find.byType(ConfigScreen), findsOneWidget);
    await tester.ensureVisible(find.text('Sair'));
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sair'));
    await tester.pumpAndSettle();
    expect(_routeOf(tester, _login), '/login');
    expect(_navigator(tester).canPop(), isFalse);

    await _loginAs(tester, DemoAuthentication.veterinarianEmail);
    expect(_routeOf(tester, _vet), '/gabriela');
    expect(find.text('Gabriela de teste'), findsOneWidget);
    expect(find.text('Demonstração · permissões simuladas'), findsOneWidget);

    _navigator(tester).pushReplacementNamed('/pets');
    await tester.pumpAndSettle();
    expect(_routeOf(tester, _vet), '/gabriela');
    expect(_pets, findsNothing);

    _navigator(tester).pushReplacementNamed('/gabriela/configuracoes');
    await tester.pumpAndSettle();
    expect(_routeOf(tester, _vet), '/gabriela/configuracoes');
    await tester.ensureVisible(find.text('Sair').hitTestable());
    await tester.tap(find.text('Sair').hitTestable());
    await tester.pumpAndSettle();
    expect(_routeOf(tester, _login), '/login');
    expect(_navigator(tester).canPop(), isFalse);

    _navigator(tester).pushReplacementNamed('/gabriela/perfil');
    await tester.pumpAndSettle();
    expect(_routeOf(tester, _login), '/login');
    expect(_vet, findsNothing);

    await _loginAs(tester, DemoAuthentication.clientEmail);
    expect(_routeOf(tester, _pets), '/pets');
    expect(preferences.getString(_snapshotKey), storedSnapshot);
    expect(preferences.getString('vethome.gabriela.name'), 'Gabriela de teste');
  });

  for (final size in [
    const Size(320, 640),
    const Size(390, 500),
    const Size(800, 900),
  ]) {
    testWidgets('Veterinária usa o Login único com texto a 200% em $size', (
      tester,
    ) async {
      final dispatcher = tester.binding.platformDispatcher;
      dispatcher.textScaleFactorTestValue = 2;
      addTearDown(dispatcher.clearTextScaleFactorTestValue);
      await _open(tester, '/gabriela/login', size: size);

      await _loginAs(tester, DemoAuthentication.veterinarianEmail);
      expect(_routeOf(tester, _vet), '/gabriela');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('contas fictícias têm instruções acessíveis no Login', (
    tester,
  ) async {
    await _open(tester, '/login', size: const Size(320, 500));
    final help = find.widgetWithText(TextButton, 'Contas da demonstração');
    await tester.ensureVisible(help);
    await tester.tap(help);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.textContaining(DemoAuthentication.veterinarianEmail),
      findsOneWidget,
    );
    expect(find.textContaining('permissões são simuladas'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Fechar'));
    await tester.pumpAndSettle();
    expect(_login, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
