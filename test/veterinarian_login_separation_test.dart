import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_data_manager.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_area_page.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_splash_screen.dart';
import 'package:flutter_vethome/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      LocalDataManager.rememberedEmailKey: 'cliente@example.test',
    });
  });

  testWidgets(
    'splash abre o acesso veterinário e a demonstração abre o perfil',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await _open(tester, '/gabriela/splash');
      expect(find.byType(GabrielaSplashScreen), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1400));
      await tester.pumpAndSettle();

      expect(find.text('Área veterinária'), findsOneWidget);
      expect(find.text('Demonstração local'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('CADASTRE-SE'), findsNothing);
      expect(find.text('Lembre-se de mim'), findsNothing);
      final access = find.text('Entrar na demonstração');
      await tester.ensureVisible(access);
      await tester.tap(access);
      await tester.pumpAndSettle();

      expect(find.byType(GabrielaAreaPage), findsOneWidget);
      expect(find.text('Perfil').hitTestable(), findsOneWidget);
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(LocalDataManager.rememberedEmailKey),
        'cliente@example.test',
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [
    const Size(320, 640),
    const Size(390, 500),
    const Size(800, 900),
  ]) {
    testWidgets('ação veterinária acessível em $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await _open(tester, '/gabriela/login', textScale: 2);
      final access = find.text('Entrar na demonstração');
      await tester.ensureVisible(access);
      await tester.pumpAndSettle();
      expect(access.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('login do Cliente preserva formulário, e-mail e cadastro', (
    tester,
  ) async {
    await _open(tester, '/login');
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('cliente@example.test'), findsOneWidget);
    expect(find.text('CADASTRE-SE'), findsOneWidget);
    expect(find.text('Entrar na demonstração'), findsNothing);
  });
}

Future<void> _open(
  WidgetTester tester,
  String route, {
  double textScale = 1,
}) async {
  final routes = AppRoutes.routes..remove('/');
  await tester.pumpWidget(
    MaterialApp(
      routes: routes,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.pushNamed(context, route),
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}
