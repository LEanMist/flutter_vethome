import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/cadastro_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/auth/vh_form.dart';

void main() {
  Future<void> showRegistration(WidgetTester tester, Size viewport) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: const CadastroScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('REGISTER_PAGE: ícones de CPF e senha correspondem ao Figma', (
    tester,
  ) async {
    await showRegistration(tester, const Size(390, 1035));
    final form = tester.widget<VHForm>(find.byType(VHForm));
    final byName = {for (final field in form.fields) field.label: field};

    // Frame 2783:1400, nós wallet-outline 2783:1431,
    // lock-open 2783:1453 e lock 2783:1459.
    expect(byName['CPF']!.icon, Icons.account_balance_wallet_outlined);
    expect(byName['Senha']!.icon, Icons.lock_open_outlined);
    expect(byName['Confirmar Senha']!.icon, Icons.lock);

    expect(form.title, 'Cadastro');
    expect(form.next, '/endereco');
    expect(form.dataPrefix, 'client.');
    expect(form.fields, hasLength(7));
    expect(byName['Gênero/Sexo'], isNull);

    // O protótipo apresenta valores ilustrativos como dicas;
    // os controles reais devem iniciar vazios e as senhas ocultas.
    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();
    final textFields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields, hasLength(7));
    for (var i = 0; i < fields.length; i++) {
      expect(fields[i].controller?.text, isEmpty);
      expect(textFields[i].decoration?.hintText, form.fields[i].value);
    }
    for (final i in [5, 6]) {
      final editable = find.descendant(
        of: find.byType(TextFormField).at(i),
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(editable).obscureText, isTrue);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('REGISTER_PAGE: título e botão conservam estilo do Figma', (
    tester,
  ) async {
    await showRegistration(tester, const Size(390, 1035));
    final title = tester.widget<Text>(find.text('Cadastro'));
    expect(title.style?.fontFamily, 'Comfortaa');
    expect(title.style?.fontSize, 30);
    expect(title.style?.fontWeight, FontWeight.bold);
    expect(tester.getTopLeft(find.text('Cadastro')).dy, closeTo(38, 2));

    final button = find.ancestor(
      of: find.text('Continuar'),
      matching: find.byType(PillButton),
    );
    expect(button, findsOneWidget);
    expect(tester.getSize(button), const Size(181, 71));
    expect(tester.widget<PillButton>(button).color, VH.primary);
    expect(tester.takeException(), isNull);
  });

  testWidgets('REGISTER_PAGE: geometria no viewport do Figma', (tester) async {
    await showRegistration(tester, const Size(390, 1035));
    final panel = find
        .ancestor(of: find.byType(Form), matching: find.byType(Container))
        .first;
    final panelRect = tester.getRect(panel);
    expect(panelRect.topLeft, const Offset(39, 96));
    expect(panelRect.width, 312);
    expect(find.text('Gênero/Sexo'), findsNothing);

    for (final expected in const [
      ('Nome Completo', 110.0, 130.0),
      ('Data de Nascimento', 202.0, 223.0),
    ]) {
      final field = find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == expected.$1,
      );
      final input = find.descendant(
        of: field,
        matching: find.byType(TextFormField),
      );
      expect(
        tester.getTopLeft(find.text(expected.$1)),
        Offset(77, expected.$2),
      );
      final inputRect = tester.getRect(input);
      expect(inputRect.left, 49);
      expect(inputRect.top, closeTo(expected.$3, 1));
      expect(inputRect.size, const Size(292, 56));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('REGISTER_PAGE: indicador lateral usa o vetor Figma', (
    tester,
  ) async {
    await showRegistration(tester, const Size(390, 1035));

    final indicator = find.byKey(const ValueKey('register-scroll-indicator'));
    expect(
      tester.getRect(indicator),
      const Rect.fromLTWH(371.5, 369, 3, 328.001),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'REGISTER_PAGE mantém coordenadas Figma com barra de status Android',
    (tester) async {
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPadding);
      await showRegistration(tester, const Size(390, 1035));

      expect(tester.getTopLeft(find.text('Cadastro')).dy, closeTo(38, 2));
      final panel = find
          .ancestor(of: find.byType(Form), matching: find.byType(Container))
          .first;
      expect(tester.getTopLeft(panel), const Offset(39, 96));
      expect(find.byType(TextFormField), findsNWidgets(7));
      expect(tester.takeException(), isNull);
    },
  );

  for (final viewport in [const Size(320, 640), const Size(1280, 800)]) {
    testWidgets('Cadastro preserva campos e layout em $viewport', (
      tester,
    ) async {
      await showRegistration(tester, viewport);
      expect(find.byType(TextFormField), findsNWidgets(7));
      expect(find.text('Continuar'), findsOneWidget);
      expect(
        find.byKey(
          ValueKey(
            viewport.width >= VH.desktopBreakpoint
                ? 'vh-form-desktop-grid'
                : 'vh-form-mobile-grid',
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
