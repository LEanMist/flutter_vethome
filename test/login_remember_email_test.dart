import 'dart:async';
import 'dart:ui' show CheckedState, SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

const _rememberedEmailKey = 'vethome.login.rememberedEmail.v1';

class _GatedPreferencesStore extends InMemorySharedPreferencesStore {
  _GatedPreferencesStore(this.writeStarted, this.releaseWrite) : super.empty();

  final Completer<void> writeStarted;
  final Completer<void> releaseWrite;
  int writeCount = 0;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    writeCount++;
    if (!writeStarted.isCompleted) writeStarted.complete();
    await releaseWrite.future;
    return super.setValue(valueType, key, value);
  }
}

class _DelayedReadStore extends InMemorySharedPreferencesStore {
  _DelayedReadStore(this.releaseRead)
    : super.withData({'flutter.$_rememberedEmailKey': 'salvo@example.test'});

  final Completer<void> releaseRead;

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) async {
    await releaseRead.future;
    return super.getAllWithParameters(parameters);
  }
}

class _FailedRememberStore extends InMemorySharedPreferencesStore {
  _FailedRememberStore(String? recordedEmail)
    : super.withData({'flutter.$_rememberedEmailKey': ?recordedEmail});

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;

  @override
  Future<bool> remove(String key) async => false;
}

Future<void> _pumpLogin(
  WidgetTester tester, {
  double textScale = 1,
  GlobalKey<NavigatorState>? navigatorKey,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const LoginPage(),
      routes: {
        '/pets': (_) => const PetsPage(),
        '/cobrindo': (_) => const Scaffold(body: Text('Outra rota')),
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

    expect(find.byType(PetsPage), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(_rememberedEmailKey), 'ana@example.test');
    expect(preferences.getKeys(), {_rememberedEmailKey});
  });

  testWidgets('mostra carregamento e bloqueia alterações durante o login', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
    final writeStarted = Completer<void>();
    final releaseWrite = Completer<void>();
    SharedPreferencesStorePlatform.instance = _GatedPreferencesStore(
      writeStarted,
      releaseWrite,
    );

    await _pumpLogin(tester);
    await tester.enterText(_field('Usuário'), 'ana@example.test');
    await tester.enterText(_field('Senha'), 'senha-secreta');
    await tester.tap(find.byKey(const ValueKey('remember-me-control')));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump();

    expect(writeStarted.isCompleted, isTrue);
    expect(find.text('Entrando…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .getSemantics(find.text('Entrando…'))
          .getSemanticsData()
          .flagsCollection
          .isLiveRegion,
      isTrue,
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(tester.widget<TextField>(_field('Usuário')).enabled, isFalse);
    expect(tester.widget<TextField>(_field('Senha')).enabled, isFalse);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'CADASTRE-SE'))
          .onPressed,
      isNull,
    );
    final rememberSemantics = tester
        .getSemantics(find.byKey(const ValueKey('remember-me-control')))
        .getSemanticsData();
    expect(rememberSemantics.flagsCollection.isEnabled, Tristate.isFalse);

    releaseWrite.complete();
    await tester.pumpAndSettle();
    expect(find.byType(PetsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lembrete tem um único rótulo e ação acessível', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      SharedPreferences.setMockInitialValues({});
      await _pumpLogin(tester);

      final data = tester
          .getSemantics(find.byKey(const ValueKey('remember-me-control')))
          .getSemanticsData();
      expect(data.label, 'Lembre-se de mim');
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(data.flagsCollection.isChecked, CheckedState.isFalse);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('foco do lembrete indica o círculo sem simular seleção', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final previousHighlightStrategy = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() {
      FocusManager.instance.highlightStrategy = previousHighlightStrategy;
    });
    await _pumpLogin(tester);

    final control = find.byKey(const ValueKey('remember-me-control'));
    final label = find.text('Lembre-se de mim');
    expect(tester.widget<Text>(label).style?.decoration, isNull);

    final focusNode = tester
        .widget<FocusableActionDetector>(control)
        .focusNode!;
    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(focusNode.hasPrimaryFocus, isTrue);
    expect(FocusManager.instance.highlightMode, FocusHighlightMode.traditional);

    expect(tester.widget<Text>(label).style?.decoration, isNull);
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    final marker = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('remember-me-marker')),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(marker.decoration, isA<inset_shadow.BoxDecoration>());
    final decoration = marker.decoration as inset_shadow.BoxDecoration;
    expect(decoration.color, VetColors.brown);
    expect(decoration.border, isNull);
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
    expect(find.byType(PetsPage), findsOneWidget);
  });

  testWidgets('textos auxiliares do login respeitam ampliação do sistema', (
    tester,
  ) async {
    await _pumpLogin(tester, textScale: 2);

    final rememberLabel = find.text('Lembre-se de mim');
    final forgotPasswordLabel = find.text('Esqueceu sua senha?');
    expect(tester.widget<Text>(rememberLabel).style?.fontSize, 8);
    expect(tester.widget<Text>(forgotPasswordLabel).style?.fontSize, 8);
    expect(tester.getSize(rememberLabel).height, greaterThan(16));
    expect(tester.getSize(forgotPasswordLabel).height, greaterThan(16));
    expect(tester.takeException(), isNull);
  });

  for (final touchRemember in [false, true]) {
    testWidgets(
      'leitura atrasada não desfaz escolha local: marcador=$touchRemember',
      (tester) async {
        final releaseRead = Completer<void>();
        SharedPreferencesStorePlatform.instance = _DelayedReadStore(
          releaseRead,
        );
        await _pumpLogin(tester);
        final user = _field('Usuário');
        if (touchRemember) {
          final remember = find.byKey(const ValueKey('remember-me-control'));
          await tester.tap(remember);
          await tester.pump();
          await tester.tap(remember);
          await tester.pump();
        } else {
          await tester.enterText(user, 'novo');
          await tester.enterText(user, '');
        }
        releaseRead.complete();
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(user).controller!.text, isEmpty);
        expect(find.byIcon(Icons.check_rounded), findsNothing);
      },
    );
  }

  testWidgets('dois acionamentos rápidos alternam o marcador duas vezes', (
    tester,
  ) async {
    await _pumpLogin(tester);
    final control = find.byKey(const ValueKey('remember-me-control'));
    final gesture = tester.widget<GestureDetector>(
      find.descendant(of: control, matching: find.byType(GestureDetector)),
    );
    gesture.onTap!();
    gesture.onTap!();
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final recordedEmail in [null, 'salvo@example.test']) {
    testWidgets(
      'falha de persistência mantém a preferência gravada: $recordedEmail',
      (tester) async {
        SharedPreferencesStorePlatform.instance = _FailedRememberStore(
          recordedEmail,
        );
        final navigatorKey = GlobalKey<NavigatorState>();
        await _pumpLogin(tester, navigatorKey: navigatorKey);
        await tester.enterText(_field('Usuário'), 'ana@example.test');
        await tester.enterText(_field('Senha'), 'senha-secreta');
        await tester.tap(find.byKey(const ValueKey('remember-me-control')));
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pumpAndSettle();
        expect(find.byType(PetsPage), findsOneWidget);
        expect(
          find.textContaining(
            recordedEmail == null
                ? 'Não foi possível lembrar o usuário'
                : 'Não foi possível esquecer o e-mail',
          ),
          findsOneWidget,
        );

        navigatorKey.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(_field('Usuário')).controller!.text,
          recordedEmail ?? '',
        );
      },
    );
  }

  testWidgets('envio repetido grava uma vez e não troca a rota sobreposta', (
    tester,
  ) async {
    final store = _GatedPreferencesStore(Completer<void>(), Completer<void>());
    SharedPreferencesStorePlatform.instance = store;
    final navigatorKey = GlobalKey<NavigatorState>();
    await _pumpLogin(tester, navigatorKey: navigatorKey);
    await tester.enterText(_field('Usuário'), 'ana@example.test');
    await tester.enterText(_field('Senha'), 'senha-secreta');
    await tester.tap(find.byKey(const ValueKey('remember-me-control')));
    await tester.pump();
    final submit = find.widgetWithText(ElevatedButton, 'Entrar');
    final activate = tester.widget<ElevatedButton>(submit).onPressed!;
    activate();
    activate();
    await tester.pump();
    expect(store.writeCount, 1);

    navigatorKey.currentState!.pushNamed('/cobrindo');
    await tester.pump();
    store.releaseWrite.complete();
    await tester.pumpAndSettle();
    expect(find.text('Outra rota'), findsOneWidget);
    expect(find.byType(PetsPage), findsNothing);
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);
    expect(store.writeCount, 1);
  });
}
