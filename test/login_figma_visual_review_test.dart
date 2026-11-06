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
    expect(loginText.color, VetColors.calendarTextOnRose);
    expect(
      tester
          .widget<ElevatedButton>(loginButton)
          .style
          ?.foregroundColor
          ?.resolve(const <WidgetState>{}),
      VetColors.calendarTextOnRose,
    );
    expect(tester.widget<Icon>(find.byIcon(Icons.login)).color, Colors.white);
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
    expect(separatorStyle.color, VetColors.brownOnRose);

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
    expect(registrationStyle.color, VetColors.brownOnRose);
    expect(
      tester
          .widget<Text>(find.text('Ainda não possui uma conta?'))
          .style
          ?.color,
      VetColors.brownOnRose,
    );

    // O protótipo usa 8 px nesses rótulos; o app preserva 12 px para leitura.
    expect(
      tester.widget<Text>(find.text('Lembre-se de mim')).style?.fontSize,
      12,
    );
    expect(
      tester.widget<Text>(find.text('Esqueceu sua senha?')).style?.fontSize,
      12,
    );
    expect(
      tester.widget<Text>(find.text('Esqueceu sua senha?')).style?.color,
      VetColors.brownOnRose,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('LOGIN_PAGE mantém a geometria do Figma com recorte do sistema', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

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

    final logo = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/imagens/figma/vethomepng-2.png',
    );
    final userField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Usuário',
    );
    final loginButton = find.widgetWithText(ElevatedButton, 'Entrar');
    expect(tester.getTopLeft(logo).dy, 180);
    expect(tester.getTopLeft(userField).dy, 333);
    expect(tester.getTopLeft(loginButton).dy, 518);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login em rota interna mantém Voltar abaixo da barra de status', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/inicio',
        routes: {
          '/inicio': (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Abrir Login'),
              ),
            ),
          ),
          '/login': (context) => const LoginPage(),
          '/pets': (_) => const Scaffold(body: Text('Pets de teste')),
          '/cadastro': (_) => const Scaffold(body: Text('Cadastro de teste')),
        },
      ),
    );
    await tester.tap(find.text('Abrir Login'));
    await tester.pumpAndSettle();

    final back = find.byTooltip('Voltar');
    expect(back, findsOneWidget);
    expect(tester.getTopLeft(back).dy, greaterThanOrEqualTo(24));
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

  testWidgets('LOGIN_PAGE: logotipo, redes e rodapé em 390x844', (
    tester,
  ) async {
    await showLogin(tester, const Size(390, 844));

    final logo = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/imagens/figma/vethomepng-2.png',
    );
    expect(logo, findsOneWidget);
    final logoRect = tester.getRect(logo);
    expect(logoRect.top, 180);
    expect(logoRect.size, const Size(166, 166));
    expect(logoRect.left, 111);

    for (final (name, left) in const [
      ('Google', 73.0),
      ('Facebook', 166.0),
      ('Instagram', 260.0),
    ]) {
      final control = find.byTooltip(name);
      final rect = tester.getRect(control);
      expect(rect.left, closeTo(left, 1));
      expect(rect.size, const Size(56, 56));
      expect(rect.top, 636);
    }

    for (final (name, top) in const [
      ('Ainda não possui uma conta?', 722.0),
      ('CADASTRE-SE', 743.0),
    ]) {
      final rect = tester.getRect(find.text(name));
      // O TextButton mantém área de toque ampliada: tolerar métricas da fonte.
      expect(rect.top, closeTo(top, name == 'CADASTRE-SE' ? 6 : 2));
    }

    expect(
      tester.getRect(find.byKey(const ValueKey('remember-me-marker'))),
      const Rect.fromLTWH(79, 458, 16, 15),
    );
    expect(tester.takeException(), isNull);
  });

  for (final (viewport, textScale) in const [
    (Size(320, 640), 1.5),
    (Size(320, 640), 2.0),
    (Size(390, 844), 1.5),
    (Size(390, 844), 2.0),
    (Size(1280, 800), 2.0),
  ]) {
    testWidgets(
      'Login em $viewport com texto ${textScale}x não corta digitação',
      (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: VetTheme.light(VH.primary),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: const LoginPage(),
          ),
        );
        await tester.pumpAndSettle();

        RenderEditable? locateEditable(RenderObject parent) {
          if (parent is RenderEditable) return parent;
          RenderEditable? found;
          parent.visitChildren((child) {
            found ??= locateEditable(child);
          });
          return found;
        }

        for (final field in find.byType(EditableText).evaluate()) {
          final editor = locateEditable(field.renderObject!);
          expect(editor, isNotNull);
          // Evita regressão: antes, 2x tinha apenas 18 px para uma linha de 45.
          expect(
            editor!.size.height,
            greaterThanOrEqualTo(editor.preferredLineHeight - 1),
          );
        }

        final remember = tester.getRect(find.text('Lembre-se de mim'));
        final forgot = tester.getRect(find.text('Esqueceu sua senha?'));
        expect(remember.bottom, lessThanOrEqualTo(forgot.top));
        await tester.ensureVisible(find.text('CADASTRE-SE'));
        await tester.pumpAndSettle();
        expect(find.text('CADASTRE-SE'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('CADASTRE-SE preserva a rota de cadastro', (tester) async {
    await showLogin(tester, const Size(390, 844));
    await tester.tap(find.text('CADASTRE-SE'));
    await tester.pumpAndSettle();
    expect(find.text('Cadastro de teste'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
