import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';

Future<void> _focusActionWithTab(WidgetTester tester, String actionKey) async {
  final actionElement = tester.element(find.byKey(ValueKey(actionKey)));

  bool actionIsFocused() {
    final focusedElement = FocusManager.instance.primaryFocus?.context;
    if (focusedElement == null) return false;
    var insideAction = false;
    focusedElement.visitAncestorElements((ancestor) {
      if (identical(ancestor, actionElement)) {
        insideAction = true;
        return false;
      }
      return true;
    });
    return insideAction;
  }

  // A página contém também a navegação inferior; não depende da ordem exata
  // de todos os outros controles, mas exige foco alcançado pelo Tab real.
  for (var step = 0; step < 20; step++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    if (actionIsFocused()) return;
  }
  fail('Tab não alcançou a ação $actionKey em 20 tentativas.');
}

Future<void> _openProfileForKeyboard(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('nome e foto do perfil são ações acessíveis e focalizáveis', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    try {
      await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
      await tester.pumpAndSettle();

      for (final action in const [
        ('profile-change-name-action', 'Alterar nome do perfil.'),
        ('profile-change-photo-action', 'Alterar foto do perfil'),
      ]) {
        final actionFinder = find.byKey(ValueKey(action.$1));
        expect(find.bySemanticsLabel(RegExp(action.$2)), findsOneWidget);
        expect(
          tester
              .getSemantics(actionFinder)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );
        final inkWell = tester.widget<InkWell>(
          find.descendant(of: actionFinder, matching: find.byType(InkWell)),
        );
        expect(inkWell.canRequestFocus, isTrue);
      }

      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
  for (final entry in [
    (key: LogicalKeyboardKey.enter, label: 'Enter'),
    (key: LogicalKeyboardKey.space, label: 'Espaço'),
  ]) {
    testWidgets('Tab e ${entry.label} abrem edição do nome do perfil', (
      tester,
    ) async {
      await _openProfileForKeyboard(tester);
      await _focusActionWithTab(tester, 'profile-change-name-action');
      await tester.sendKeyEvent(entry.key);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Mudar nome de perfil'), findsOneWidget);
      expect(find.text('Novo nome'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tab e ${entry.label} abrem seleção da foto do perfil', (
      tester,
    ) async {
      await _openProfileForKeyboard(tester);
      await _focusActionWithTab(tester, 'profile-change-photo-action');
      await tester.sendKeyEvent(entry.key);
      await tester.pumpAndSettle();

      expect(find.text('Escolher da galeria'), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final entry in [
    (key: LogicalKeyboardKey.enter, label: 'Enter'),
    (key: LogicalKeyboardKey.space, label: 'Espaço'),
  ]) {
    testWidgets('Tab e ${entry.label} abrem edição do nascimento do perfil', (
      tester,
    ) async {
      await _openProfileForKeyboard(tester);
      final action = find
          .ancestor(
            of: find.text('Mudar Data de Nascimento'),
            matching: find.byType(InkWell),
          )
          .first;
      final actionElement = tester.element(action);

      bool actionIsFocused() {
        final focusedElement = FocusManager.instance.primaryFocus?.context;
        if (focusedElement == null) return false;
        if (identical(focusedElement, actionElement)) return true;
        var insideAction = false;
        focusedElement.visitAncestorElements((ancestor) {
          if (identical(ancestor, actionElement)) {
            insideAction = true;
            return false;
          }
          return true;
        });
        return insideAction;
      }

      var reached = actionIsFocused();
      for (var step = 0; step < 25 && !reached; step++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        reached = actionIsFocused();
      }
      expect(
        reached,
        isTrue,
        reason: 'Tab deve alcançar Mudar Data de Nascimento',
      );

      await tester.sendKeyEvent(entry.key);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Mudar data de nascimento'), findsOneWidget);
      expect(find.text('Data de nascimento'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ações do Perfil permitem quebra com texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
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
        home: const PerfilPage(),
      ),
    );
    await tester.pumpAndSettle();

    final birthActionLabel = find.text('Mudar Data de Nascimento');
    expect(birthActionLabel, findsOneWidget);
    expect(
      find.ancestor(of: birthActionLabel, matching: find.byType(FittedBox)),
      findsNothing,
      reason: 'o texto ampliado não deve ser reduzido para caber em uma linha',
    );
    expect(tester.getRect(birthActionLabel).height, greaterThan(30));
    expect(tester.takeException(), isNull);
  });
}
