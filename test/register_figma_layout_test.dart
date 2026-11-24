import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/cliente/cadastro_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/auth/vh_form.dart';
import 'package:flutter_vethome/widgets/auth/registration_field_icon.dart';

void main() {
  Finder inputFor(String label) => find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == label,
    ),
    matching: find.byType(TextFormField),
  );

  Future<void> showRegistration(
    WidgetTester tester,
    Size viewport, {
    double textScale = 1,
  }) async {
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
        home: const CadastroScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('e-mail longo volta a mostrar o começo ao perder o foco', (
    tester,
  ) async {
    await showRegistration(tester, const Size(320, 640));
    final email = inputFor('E-mail');
    const value = 'nome-de-teste-bastante-longo@example.test';
    await tester.ensureVisible(email);
    await tester.enterText(email, value);
    await tester.pumpAndSettle();
    final editable = tester.widget<EditableText>(
      find.descendant(of: email, matching: find.byType(EditableText)),
    );
    final scroll = editable.scrollController!;
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.ensureVisible(inputFor('Senha'));
    await tester.tap(inputFor('Senha'));
    await tester.pumpAndSettle();
    expect(scroll.offset, 0);
    expect(editable.controller.text, value);
  });

  testWidgets(
    'Cadastro mantém erro legível e ação visível com teclado e texto ampliado',
    (tester) async {
      await showRegistration(tester, const Size(320, 480), textScale: 2);
      tester.view.viewInsets = const FakeViewPadding(bottom: 200);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      final button = find.text('Continuar');
      expect(button.hitTestable(), findsOneWidget);
      await tester.tap(button);
      await tester.pumpAndSettle();
      final decorations = find.byType(InputDecorator);
      final decorator = decorations.first;
      final surface = InputDecorator.containerOf(
        tester.element(
          find.descendant(of: decorator, matching: find.byType(EditableText)),
        ),
      );
      final error = find.descendant(
        of: decorator,
        matching: find.text('Preencha este campo'),
      );
      expect(error, findsOneWidget);
      expect(
        tester.getTopLeft(error).dy,
        greaterThanOrEqualTo(
          surface!.localToGlobal(Offset.zero).dy + surface.size.height,
        ),
      );
      expect(tester.getBottomRight(button).dy, lessThanOrEqualTo(280));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('REGISTER_PAGE: ícones de CPF e senha correspondem ao Figma', (
    tester,
  ) async {
    await showRegistration(tester, const Size(390, 1035));
    final form = tester.widget<VHForm>(find.byType(VHForm));
    final byName = {for (final field in form.fields) field.label: field};

    // Frame 2564:473, da página Telas para IA.
    expect(byName['CPF']!.icon, Icons.account_balance_wallet_outlined);
    expect(byName['Senha']!.icon, Icons.lock_open_outlined);
    expect(byName['Confirmar Senha']!.icon, Icons.lock);

    expect(form.title, 'Cadastro');
    expect(form.next, '/endereco');
    expect(form.dataPrefix, 'client.');
    expect(form.fields, hasLength(7));
    expect(byName['Gênero/Sexo'], isNull);
    expect(byName['Data de Nascimento']!.value, '05 / 02 / 2007');
    expect(byName['CPF']!.value, '534.356.874 - 94');

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
    await showRegistration(tester, const Size(390, 926));
    final panel = find
        .ancestor(of: find.byType(Form), matching: find.byType(Container))
        .first;
    final panelRect = tester.getRect(panel);
    expect(panelRect.topLeft, const Offset(33, 96));
    expect(panelRect.width, 324);
    expect(find.text('Gênero/Sexo'), findsNothing);

    for (final expected in const [
      ('Nome Completo', 110.0, 130.0),
      ('Data de Nascimento', 202.0, 223.0),
      ('CPF', 282.0, 303.0),
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
        Offset(56, expected.$2),
      );
      final inputRect = tester.getRect(input);
      expect(inputRect.left, 49);
      expect(inputRect.top, closeTo(expected.$3, 1));
      expect(inputRect.size, const Size(292, 56));
      final icon = find.descendant(
        of: field,
        matching: find.byType(RegistrationFieldIcon),
      );
      expect(tester.getSize(icon), const Size(56, 56));
      expect(tester.getTopLeft(icon).dx, closeTo(inputRect.left, 1));
      final editable = find.descendant(
        of: input,
        matching: find.byType(EditableText),
      );
      expect(tester.getTopLeft(editable).dx - inputRect.left, closeTo(75, 1));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('cadastro foca e revela o primeiro campo inválido', (
    tester,
  ) async {
    await showRegistration(tester, const Size(514, 667));
    expect(find.text('Continuar').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    final firstField = find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == 'Nome Completo',
    );
    final firstInput = find.descendant(
      of: firstField,
      matching: find.byType(TextFormField),
    );
    final fieldRect = tester.getRect(firstInput);
    final editable = find.descendant(
      of: firstInput,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isTrue);
    expect(fieldRect.top, greaterThanOrEqualTo(0));
    expect(fieldRect.bottom, lessThanOrEqualTo(667));
    expect(tester.takeException(), isNull);
  });

  testWidgets('erro do Cadastro é removido quando o campo é corrigido', (
    tester,
  ) async {
    await showRegistration(tester, const Size(390, 926));
    final nameField = find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == 'Nome Completo',
    );
    final nameInput = find.descendant(
      of: nameField,
      matching: find.byType(TextFormField),
    );

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Continuar').hitTestable(), findsOneWidget);
    expect(
      find.descendant(
        of: nameField,
        matching: find.text('Preencha este campo'),
      ),
      findsOneWidget,
    );

    await tester.enterText(nameInput, 'Kelvin Teste');
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: nameField,
        matching: find.text('Preencha este campo'),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('erro de confirmação acompanha alterações na senha', (
    tester,
  ) async {
    await showRegistration(tester, const Size(390, 1035));
    final passwordInput = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Senha',
      ),
      matching: find.byType(TextFormField),
    );
    final confirmationInput = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Confirmar Senha',
      ),
      matching: find.byType(TextFormField),
    );

    await tester.ensureVisible(passwordInput);
    await tester.enterText(passwordInput, 'senha123');
    await tester.ensureVisible(confirmationInput);
    await tester.enterText(confirmationInput, 'outra123');
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('As senhas não coincidem'), findsOneWidget);

    await tester.ensureVisible(passwordInput);
    await tester.enterText(passwordInput, 'outra123');
    await tester.pumpAndSettle();
    expect(find.text('As senhas não coincidem'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tecla Próximo avança e último campo usa Concluído', (
    tester,
  ) async {
    await showRegistration(tester, const Size(390, 1035));
    final nameInput = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Nome Completo',
      ),
      matching: find.byType(TextFormField),
    );
    final birthInput = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Data de Nascimento',
      ),
      matching: find.byType(TextFormField),
    );
    final lastInput = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Confirmar Senha',
      ),
      matching: find.byType(TextFormField),
    );
    final nameTextField = find.descendant(
      of: nameInput,
      matching: find.byType(TextField),
    );
    final birthTextField = find.descendant(
      of: birthInput,
      matching: find.byType(TextField),
    );
    final lastTextField = find.descendant(
      of: lastInput,
      matching: find.byType(TextField),
    );

    expect(
      tester.widget<TextField>(nameTextField).textInputAction,
      TextInputAction.next,
    );
    await tester.tap(nameInput);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(
      tester.widget<TextField>(birthTextField).focusNode?.hasFocus,
      isTrue,
    );
    expect(
      tester.widget<TextField>(lastTextField).textInputAction,
      TextInputAction.done,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tecla Concluído valida o Cadastro e foca o primeiro erro', (
    tester,
  ) async {
    await showRegistration(tester, const Size(390, 1035));
    final lastInput = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Confirmar Senha',
      ),
      matching: find.byType(TextFormField),
    );
    final nameField = find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == 'Nome Completo',
    );
    final nameInput = find.descendant(
      of: nameField,
      matching: find.byType(TextFormField),
    );
    final nameEditable = find.descendant(
      of: nameInput,
      matching: find.byType(EditableText),
    );

    await tester.ensureVisible(lastInput);
    await tester.tap(lastInput);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: nameField,
        matching: find.text('Preencha este campo'),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<EditableText>(nameEditable).focusNode.hasFocus,
      isTrue,
    );
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

  testWidgets('indicador acompanha o cadastro centralizado em 414 px', (
    tester,
  ) async {
    await showRegistration(tester, const Size(414, 1035));

    final indicator = find.byKey(const ValueKey('register-scroll-indicator'));
    expect(
      tester.getRect(indicator),
      const Rect.fromLTWH(383.5, 369, 3, 328.001),
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
      expect(tester.getTopLeft(panel), const Offset(33, 96));
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
