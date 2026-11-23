import 'package:flutter_vethome/auth/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/main.dart';
import 'package:flutter_vethome/pages/cadastro_page.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets/auth/demo_mode_notice.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/demo_auth.dart';

Finder field(String name) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.hintText == name,
);

class _EmptyLoginStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();
}

Future<void> openLogin(
  WidgetTester tester,
  Size viewport, {
  double textScale = 1,
  double safeTop = 0,
  bool withPreviousRoute = false,
}) async {
  tester.view
    ..physicalSize = viewport
    ..devicePixelRatio = 1
    ..viewPadding = FakeViewPadding(top: safeTop)
    ..padding = FakeViewPadding(top: safeTop);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewPadding);
  addTearDown(tester.view.resetPadding);

  await tester.pumpWidget(
    MaterialApp(
      theme: VetTheme.light(VH.primary),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      initialRoute: withPreviousRoute ? '/login' : '/',
      home: withPreviousRoute ? const Scaffold() : demoLogin(),
      routes: {
        '/pets': (_) => const Scaffold(body: Text('Pets de teste')),
        '/login': (_) => demoLogin(),
        '/cadastro': (_) => const CadastroScreen(),
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('aviso do Login não acompanha a navegação para Cadastro', (
    tester,
  ) async {
    await openLogin(tester, const Size(390, 1000));
    final instagram = find.byTooltip('Instagram');
    await tester.ensureVisible(instagram);
    await tester.tap(instagram);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    final register = find.text('CADASTRE-SE');
    await tester.ensureVisible(register);
    await tester.tap(register);
    await tester.pumpAndSettle();
    expect(find.byType(CadastroScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Continuar').hitTestable(), findsOneWidget);
  });

  testWidgets('janela de 240 px mantém botões sociais dentro da tela', (
    tester,
  ) async {
    await openLogin(tester, const Size(240, 600));
    expect(tester.takeException(), isNull);
    for (final name in ['Google', 'Facebook', 'Instagram']) {
      final button = find.byTooltip(name);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      final bounds = tester.getRect(button);
      expect(bounds.left, greaterThanOrEqualTo(0));
      expect(bounds.right, lessThanOrEqualTo(240));
      expect(bounds.size, const Size(56, 56));
      expect(button.hitTestable(), findsOneWidget);
    }
  });

  testWidgets('Login com rota anterior em 240 px separa a seta do aviso', (
    tester,
  ) async {
    await openLogin(tester, const Size(240, 600), withPreviousRoute: true);
    final back = find.byTooltip('Voltar');
    final notice = find.byType(DemoModeNotice);
    expect(
      tester.getRect(back).right,
      lessThanOrEqualTo(tester.getRect(notice).left),
    );
    expect(back.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tapAt(tester.getCenter(back));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsNothing);
  });

  testWidgets('link direto para Login não cria uma tela anterior', (
    tester,
  ) async {
    await VetRepository.initialize(storage: _EmptyLoginStorage());
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.defaultRouteNameTestValue = '/login';
    addTearDown(dispatcher.clearDefaultRouteNameTestValue);

    await tester.pumpWidget(const VetHomeApp());
    await tester.pumpAndSettle();
    final login = find.byType(LoginPage);
    expect(login, findsOneWidget);
    expect(find.byTooltip('Voltar'), findsNothing);
    expect(Navigator.of(tester.element(login)).canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('toque na borda inferior da senha não marca o lembrete', (
    tester,
  ) async {
    await openLogin(tester, const Size(390, 844));
    final password = field('Senha');
    final bounds = tester.getRect(password);
    await tester.tapAt(Offset(bounds.left + 36, bounds.bottom - 4));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(password).focusNode!.hasFocus, isTrue);
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    await tester.tapAt(tester.getCenter(find.text('Lembre-se de mim')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await tester.tapAt(
      tester.getCenter(find.byKey(const ValueKey('remember-me-marker'))),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('janela de 514 x 667 mostra as ações sem rolar', (tester) async {
    await openLogin(tester, const Size(514, 667));

    for (final action in [
      find.widgetWithText(ElevatedButton, 'Entrar'),
      for (final name in ['Google', 'Facebook', 'Instagram'])
        find.byTooltip(name),
      find.widgetWithText(TextButton, 'CADASTRE-SE'),
    ]) {
      expect(tester.getRect(action).bottom, lessThanOrEqualTo(667));
      expect(action.hitTestable(), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  for (final (viewport, keyboard) in [
    (const Size(320, 480), 220.0),
    (const Size(667, 375), 180.0),
    (const Size(1280, 480), 240.0),
  ]) {
    testWidgets('Login $viewport com texto 200% e teclado fica utilizável', (
      tester,
    ) async {
      await openLogin(tester, viewport, textScale: 2, safeTop: 44);
      expect(tester.takeException(), isNull);
      final password = field('Senha');
      await tester.enterText(field('Usuário'), DemoAuthentication.clientEmail);
      await tester.enterText(password, DemoAuthentication.demoPassword);
      tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(password).focusNode!.hasFocus, isTrue);
      final submit = find.widgetWithText(ElevatedButton, 'Entrar');
      final button = tester.getRect(submit);
      expect(button.bottom, lessThanOrEqualTo(viewport.height - keyboard));
      expect(submit.hitTestable(), findsOneWidget);
      final notice = tester.getRect(find.byType(DemoModeNotice));
      final logo = tester.getRect(find.bySemanticsLabel('VetHome'));
      expect(notice.bottom, lessThanOrEqualTo(logo.top));
      expect(tester.takeException(), isNull);

      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Pets de teste'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('rótulos auxiliares continuam inteiros a 135% em 280 px', (
    tester,
  ) async {
    await openLogin(tester, const Size(280, 640), textScale: 1.35);
    for (final name in ['Lembre-se de mim', 'Esqueceu sua senha?']) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(name));
      expect(
        paragraph.size.height,
        greaterThanOrEqualTo(
          paragraph.getMaxIntrinsicHeight(paragraph.size.width) - .01,
        ),
      );
    }
    expect(tester.takeException(), isNull);
  });
}
