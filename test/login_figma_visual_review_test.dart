import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> showLogin(WidgetTester tester, Size viewport) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: const LoginPage(),
        routes: {
          '/pets': (_) => const Scaffold(body: Text('Pets de teste')),
          '/cadastro': (_) => const Scaffold(body: Text('Cadastro de teste')),
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('LOGIN_PAGE 2783:1465: elementos visuais em 390 x 844', (
    tester,
  ) async {
    await showLogin(tester, const Size(390, 844));

    final surface = find.byKey(const ValueKey('login-surface'));
    expect(tester.getSize(surface).width, 390);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      VH.background,
    );
    expect(VH.background, const Color(0xFFFAD3D5));

    Finder field(String hint) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == hint,
    );
    expect(
      tester.getRect(field('Usuário')),
      const Rect.fromLTWH(74, 333, 242, 48),
    );
    expect(
      tester.getRect(field('Senha')),
      const Rect.fromLTWH(74, 398, 242, 48),
    );

    final loginButton = find.widgetWithText(ElevatedButton, 'Entrar');
    final loginRect = tester.getRect(loginButton);
    expect(loginRect.left, closeTo(43, 1));
    expect(loginRect.top, 518);
    expect(loginRect.size, const Size(303, 54));
    final loginText = tester
        .renderObject<RenderParagraph>(find.text('Entrar'))
        .text
        .style!;
    expect(loginText.fontFamily, VH.bodyFontFamily);
    expect(loginText.fontSize, 14);
    expect(loginText.fontWeight, FontWeight.bold);
    expect(
      tester
          .widget<ElevatedButton>(loginButton)
          .style
          ?.backgroundColor
          ?.resolve(const <WidgetState>{}),
      VetColors.rose,
    );

    final separator = find.text('Ou continue com');
    expect(tester.getTopLeft(separator).dy, 601);
    final separatorStyle = tester
        .renderObject<RenderParagraph>(separator)
        .text
        .style!;
    expect(separatorStyle.fontFamily, VH.bodyFontFamily);
    expect(separatorStyle.fontSize, 10);
    expect(separatorStyle.fontWeight, FontWeight.bold);
    expect(separatorStyle.color, VetColors.brownSecondary);

    for (final (name, left) in const [
      ('Google', 73.0),
      ('Facebook', 166.0),
      ('Instagram', 260.0),
    ]) {
      expect(tester.getTopLeft(find.byTooltip(name)).dx, closeTo(left, 1));
    }

    final registration = find.text('CADASTRE-SE');
    final registrationStyle = tester
        .renderObject<RenderParagraph>(registration)
        .text
        .style!;
    expect(registrationStyle.fontFamily, VH.bodyFontFamily);
    expect(registrationStyle.fontSize, 15);
    expect(registrationStyle.fontWeight, FontWeight.bold);
    expect(registrationStyle.color, VH.secondary);

    // O protótipo usa 8 px nesses rótulos; o app preserva 12 px para leitura.
    expect(
      tester.widget<Text>(find.text('Lembre-se de mim')).style?.fontSize,
      12,
    );
    expect(
      tester.widget<Text>(find.text('Esqueceu sua senha?')).style?.fontSize,
      12,
    );
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 640), const Size(1280, 800)]) {
    testWidgets('Login sem overflow e superfície limitada em $size', (
      tester,
    ) async {
      await showLogin(tester, size);
      expect(
        tester.getSize(find.byKey(const ValueKey('login-surface'))).width,
        lessThanOrEqualTo(390),
      );
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('CADASTRE-SE preserva a rota de cadastro', (tester) async {
    await showLogin(tester, const Size(390, 844));
    await tester.tap(find.text('CADASTRE-SE'));
    await tester.pumpAndSettle();
    expect(find.text('Cadastro de teste'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
