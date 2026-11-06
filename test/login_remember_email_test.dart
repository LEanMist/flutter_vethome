import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/home_page.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _rememberedEmailKey = 'vethome.login.rememberedEmail.v1';

Future<void> _pumpLogin(WidgetTester tester, {double textScale = 1}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const LoginPage(),
      routes: {
        '/home': (_) => const HomePage(),
        '/pets': (_) => const Scaffold(body: Text('Pets')),
      },
    ),
  );
  await tester.pumpAndSettle();
}

Finder _field(String hint) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.hintText == hint,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('lembra somente o email após login válido', (tester) async {
    await _pumpLogin(tester);

    await tester.enterText(_field('Usuário'), '  ana@example.test  ');
    await tester.enterText(_field('Senha'), 'senha-secreta');
    await tester.tap(find.byKey(const ValueKey('remember-me-control')));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-figma-frame')), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(_rememberedEmailKey), 'ana@example.test');
    expect(preferences.getKeys(), {_rememberedEmailKey});
  });

  testWidgets('restaura email e permite removê-lo desmarcando a opção', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      _rememberedEmailKey: 'ana@example.test',
    });
    await _pumpLogin(tester);

    expect(
      tester.widget<TextField>(_field('Usuário')).controller?.text,
      'ana@example.test',
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('remember-me-control')));
    await tester.pump();
    await tester.enterText(_field('Usuário'), 'bia@example.test');
    await tester.enterText(_field('Senha'), 'outra-senha');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(_rememberedEmailKey), isNull);
    expect(find.byKey(const ValueKey('home-figma-frame')), findsOneWidget);
  });

  testWidgets('textos auxiliares do login respeitam ampliação do sistema', (
    tester,
  ) async {
    await _pumpLogin(tester, textScale: 2);

    final rememberLabel = find.text('Lembre-se de mim');
    final forgotPasswordLabel = find.text('Esqueceu sua senha?');
    expect(tester.widget<Text>(rememberLabel).style?.fontSize, 12);
    expect(tester.widget<Text>(forgotPasswordLabel).style?.fontSize, 12);
    expect(tester.getSize(rememberLabel).height, greaterThan(20));
    expect(tester.getSize(forgotPasswordLabel).height, greaterThan(20));
    expect(tester.takeException(), isNull);
  });
}
