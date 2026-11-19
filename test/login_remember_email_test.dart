import 'dart:async';
import 'dart:ui' show CheckedState, SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/home_page.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const _rememberedEmailKey = 'vethome.login.rememberedEmail.v1';

class _GatedPreferencesStore extends InMemorySharedPreferencesStore {
  _GatedPreferencesStore(this.writeStarted, this.releaseWrite) : super.empty();

  final Completer<void> writeStarted;
  final Completer<void> releaseWrite;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    writeStarted.complete();
    await releaseWrite.future;
    return super.setValue(valueType, key, value);
  }
}

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
    final rememberSemantics = tester
        .getSemantics(find.byKey(const ValueKey('remember-me-control')))
        .getSemanticsData();
    expect(rememberSemantics.flagsCollection.isEnabled, Tristate.isFalse);

    releaseWrite.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-figma-frame')), findsOneWidget);
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

  testWidgets('foco do lembrete fica no marcador, sem contornar o texto', (
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
    final controlDecoration =
        tester
                .widget<AnimatedContainer>(
                  find
                      .ancestor(
                        of: find.text('Lembre-se de mim'),
                        matching: find.byType(AnimatedContainer),
                      )
                      .first,
                )
                .decoration!
            as BoxDecoration;
    expect(controlDecoration.border, isNull);

    final focusNode = tester
        .widget<FocusableActionDetector>(control)
        .focusNode!;
    await tester.tap(control);
    await tester.pump();
    expect(focusNode.hasPrimaryFocus, isTrue);
    expect(FocusManager.instance.highlightMode, FocusHighlightMode.traditional);

    final focusedControlDecoration =
        tester
                .widget<AnimatedContainer>(
                  find
                      .ancestor(
                        of: find.text('Lembre-se de mim'),
                        matching: find.byType(AnimatedContainer),
                      )
                      .first,
                )
                .decoration!
            as BoxDecoration;
    expect(focusedControlDecoration.border, isNull);

    final marker = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('remember-me-marker')),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(marker.decoration, isA<inset_shadow.BoxDecoration>());
    expect((marker.decoration as inset_shadow.BoxDecoration).border, isNotNull);
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
