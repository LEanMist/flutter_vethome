import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/auth/demo_mode_notice.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/demo_auth.dart';

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

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
        home: demoLogin(),
        routes: {
          '/pets': (_) => const Scaffold(body: Text('Pets de teste')),
          '/cadastro': (_) => const Scaffold(body: Text('Cadastro de teste')),
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('LOGIN_PAGE 2564:1191: elementos visuais em 390 x 844', (
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
    for (final hint in ['Usuário', 'Senha']) {
      expect(
        tester.widget<TextField>(field(hint)).decoration?.hintStyle?.color,
        VH.foreground.withValues(alpha: .5),
      );
      final gradientStops = [
        VH.secondary.withValues(alpha: .25),
        VH.background,
      ];
      final surfaces = gradientStops.map(
        (stop) => Color.alphaBlend(stop, VH.background),
      );
      expect(
        surfaces
            .map((surface) => _contrastRatio(VH.foreground, surface))
            .reduce((a, b) => a < b ? a : b),
        greaterThanOrEqualTo(4.5),
      );
    }
    expect(
      tester.widget<Icon>(find.byIcon(Icons.visibility_outlined)).color,
      VH.foreground,
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
    expect(loginText.color, Colors.white);
    expect(
      tester
          .widget<ElevatedButton>(loginButton)
          .style
          ?.foregroundColor
          ?.resolve(const <WidgetState>{}),
      Colors.white,
    );
    final enterIcon = find.byKey(const ValueKey('login-enter-icon'));
    expect(
      tester.widget<SvgPicture>(enterIcon).bytesLoader,
      const SvgAssetLoader('assets/imagens/figma/login-enter.svg'),
    );
    expect(tester.getSize(enterIcon), const Size(21, 20));
    expect(tester.getTopLeft(enterIcon).dx, closeTo(227, 1));
    expect(tester.getCenter(find.text('Entrar')).dx, closeTo(195, 1));
    expect(
      tester
          .widget<ElevatedButton>(loginButton)
          .style
          ?.backgroundColor
          ?.resolve(const <WidgetState>{}),
      VetColors.brown,
    );
    // LOGIN_PAGE 2564:1193 uses #68442E with white text.
    expect(
      _contrastRatio(Colors.white, VetColors.brown),
      greaterThanOrEqualTo(4.5),
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
    final registrationContrast =
        (VH.background.computeLuminance() + 0.05) /
        (registrationStyle.color!.computeLuminance() + 0.05);
    expect(registrationContrast, greaterThanOrEqualTo(4.5));
    expect(
      tester
          .widget<Text>(find.text('Ainda não possui uma conta?'))
          .style
          ?.color,
      VetColors.brownSecondary,
    );

    // Os rótulos usam os 8 px da referência e acompanham a escala do sistema.
    expect(
      tester.widget<Text>(find.text('Lembre-se de mim')).style?.fontSize,
      8,
    );
    expect(
      tester.widget<Text>(find.text('Esqueceu sua senha?')).style?.fontSize,
      8,
    );
    expect(
      tester.widget<Text>(find.text('Esqueceu sua senha?')).style?.color,
      VetColors.brownSecondary,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('aviso do Login fica entre a barra de status e a pata', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    tester.view.viewPadding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(
      MaterialApp(theme: VetTheme.light(VH.primary), home: demoLogin()),
    );
    await tester.pumpAndSettle();

    final notice = tester.getRect(find.byType(DemoModeNotice));
    final paw = tester.getRect(
      find.image(const AssetImage('assets/imagens/figma/frame-35.png')),
    );
    expect(notice.top, 32);
    expect(notice.bottom, lessThanOrEqualTo(paw.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets('controle de senha anuncia a ação disponível', (tester) async {
    await showLogin(tester, const Size(390, 844));

    Finder passwordField() => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == 'Senha',
    );

    expect(find.byTooltip('Mostrar senha'), findsOneWidget);
    expect(tester.widget<TextField>(passwordField()).obscureText, isTrue);

    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();

    expect(find.byTooltip('Ocultar senha'), findsOneWidget);
    expect(tester.widget<TextField>(passwordField()).obscureText, isFalse);

    await tester.tap(find.byTooltip('Ocultar senha'));
    await tester.pump();

    expect(find.byTooltip('Mostrar senha'), findsOneWidget);
    expect(tester.widget<TextField>(passwordField()).obscureText, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Next no usuário foca Senha e Done preserva validação', (
    tester,
  ) async {
    await showLogin(tester, const Size(390, 844));

    Finder field(String hint) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == hint,
    );
    final userField = field('Usuário');
    final passwordField = field('Senha');

    expect(
      tester.widget<TextField>(userField).textInputAction,
      TextInputAction.next,
    );
    expect(
      tester.widget<TextField>(passwordField).textInputAction,
      TextInputAction.done,
    );

    await tester.tap(userField);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(tester.widget<TextField>(passwordField).focusNode!.hasFocus, isTrue);
    expect(find.text('E-mail ou senha inválidos.'), findsNothing);

    await tester.enterText(passwordField, '123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
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
        home: demoLogin(),
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
              'assets/imagens/figma/splash-start-logo.png',
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
          '/login': (context) => demoLogin(),
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

  testWidgets('ações auxiliares ficam na mesma linha de base do Login', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await (FontLoader(VH.bodyFontFamily)..addFont(
            rootBundle.load('assets/fonts/MontserratAlternatesRegular.ttf'),
          ))
          .load();
    });
    await showLogin(tester, const Size(390, 844));

    Rect singleLineBounds(String name) {
      final text = find.text(name);
      final paragraph = tester.renderObject<RenderParagraph>(text);
      expect(paragraph.size.height, paragraph.getMaxIntrinsicHeight(300));
      return tester.getRect(text);
    }

    final remember = singleLineBounds('Lembre-se de mim');
    final forgot = singleLineBounds('Esqueceu sua senha?');
    expect(remember.top, closeTo(forgot.top, .5));
    expect(remember.bottom, closeTo(forgot.bottom, .5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login curto mantém Entrar acima do teclado e o campo focado', (
    tester,
  ) async {
    await showLogin(tester, const Size(320, 640));
    final password = find.widgetWithText(TextField, 'Senha');
    await tester.ensureVisible(password);
    await tester.tap(password);
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: 310);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    final fixedSubmit = find.byKey(const ValueKey('login-fixed-submit'));
    expect(fixedSubmit, findsOneWidget);
    final submit = find.widgetWithText(ElevatedButton, 'Entrar');
    expect(tester.getRect(submit).bottom, lessThanOrEqualTo(330));
    expect(tester.widget<TextField>(password).focusNode!.hasFocus, isTrue);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('janela baixa mostra os dois campos e Entrar sem rolagem', (
    tester,
  ) async {
    await showLogin(tester, const Size(320, 410));
    final submit = tester.getRect(
      find.widgetWithText(ElevatedButton, 'Entrar'),
    );
    for (final name in ['Usuário', 'Senha']) {
      final field = find.widgetWithText(TextField, name);
      final bounds = tester.getRect(field);
      expect(bounds.top, greaterThanOrEqualTo(0));
      expect(bounds.bottom, lessThan(submit.top));
      expect(field.hitTestable(), findsOneWidget);
    }
    expect(submit.bottom, lessThanOrEqualTo(410));
  });

  testWidgets('Tab e Shift+Tab percorrem Usuário e Senha na ordem', (
    tester,
  ) async {
    await showLogin(tester, const Size(390, 844));
    final user = find.widgetWithText(TextField, 'Usuário');
    final password = find.widgetWithText(TextField, 'Senha');
    await tester.tap(user);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      tester.widget<TextField>(password).focusNode!.hasPrimaryFocus,
      isTrue,
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    final userEditor = tester.widget<EditableText>(
      find.descendant(of: user, matching: find.byType(EditableText)),
    );
    expect(userEditor.focusNode.hasPrimaryFocus, isTrue);
  });

  testWidgets('campos mantêm o nome acessível depois de preenchidos', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await showLogin(tester, const Size(390, 844));
      for (final (name, value) in const [
        ('Usuário', 'ana@example.test'),
        ('Senha', 'exemplo-123'),
      ]) {
        final field = find.widgetWithText(TextField, name);
        final editor = find.descendant(
          of: field,
          matching: find.byType(EditableText),
        );
        await tester.enterText(field, value);
        await tester.pumpAndSettle();
        final data = tester.getSemantics(editor).getSemanticsData();
        expect(data.label, name);
        expect(data.flagsCollection.isTextField, isTrue);
      }
      expect(find.byTooltip('Mostrar senha'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('aviso inteiro permanece legível com texto a 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: demoLogin(),
      ),
    );
    await tester.pumpAndSettle();
    final notice = find.text('Demonstração · use dados fictícios');
    final paragraph = tester.renderObject<RenderParagraph>(notice);
    final bounds = tester.getRect(notice);
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(
      bounds.height,
      greaterThanOrEqualTo(paragraph.getMaxIntrinsicHeight(bounds.width) - .01),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('LOGIN_PAGE: logotipo, redes e rodapé em 390x844', (
    tester,
  ) async {
    await showLogin(tester, const Size(390, 844));

    final logo = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/imagens/figma/splash-start-logo.png',
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
            home: demoLogin(),
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
