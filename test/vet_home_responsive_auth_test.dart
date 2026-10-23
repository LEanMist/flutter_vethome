import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/cadastroPet_page.dart';
import 'package:flutter_vethome/pages/cadastro_page.dart';
import 'package:flutter_vethome/pages/endereco_page.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/pet_form.dart';

Future<void> pumpAt(WidgetTester tester, Widget child, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(theme: VetTheme.light(VH.primary), home: child),
  );
  await tester.pump();
}

void main() {
  testWidgets('login preserva a composição móvel sem overflow', (tester) async {
    await pumpAt(tester, const LoginPage(), const Size(320, 640));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('login-surface')), findsOneWidget);
    expect(find.text('CADASTRE-SE'), findsOneWidget);
  });

  testWidgets('login usa superfície controlada no desktop', (tester) async {
    await pumpAt(tester, const LoginPage(), const Size(1280, 800));

    expect(tester.takeException(), isNull);
    final surface = tester.getSize(find.byKey(const ValueKey('login-surface')));
    expect(surface.width, lessThanOrEqualTo(520));
  });

  testWidgets('login usa o botão Entrar marrom aprovado no Figma', (
    tester,
  ) async {
    await pumpAt(tester, const LoginPage(), const Size(390, 844));

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Entrar'),
    );
    expect(
      button.style?.backgroundColor?.resolve(const <WidgetState>{}),
      VetColors.brown,
    );
  });

  testWidgets('campos do login seguem tipografia e geometria do novo Figma', (
    tester,
  ) async {
    await pumpAt(tester, const LoginPage(), const Size(390, 844));

    Finder fieldWithHint(String hint) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == hint,
    );

    final userFinder = fieldWithHint('Usuário');
    final passwordFinder = fieldWithHint('Senha');
    final user = tester.widget<TextField>(userFinder);
    final password = tester.widget<TextField>(passwordFinder);

    for (final field in [user, password]) {
      expect(field.style?.fontFamily, 'MontserratAlternates_500');
      expect(field.style?.fontFamilyFallback, const ['MontserratAlternates']);
      expect(field.style?.fontSize, 15);
      expect(field.style?.fontWeight, FontWeight.w500);
      expect(
        field.decoration?.hintStyle?.fontFamily,
        'MontserratAlternates_500',
      );
      expect(field.decoration?.hintStyle?.fontFamilyFallback, const [
        'MontserratAlternates',
      ]);
      expect(field.decoration?.hintStyle?.fontSize, 15);
      expect(field.decoration?.hintStyle?.fontWeight, FontWeight.w500);
      expect(
        field.decoration?.contentPadding,
        const EdgeInsets.fromLTRB(14, 17, 8, 13),
      );
    }

    expect(tester.getSize(userFinder), const Size(242, 48));
    expect(tester.getSize(passwordFinder), const Size(242, 48));
    expect(
      tester.getTopLeft(passwordFinder).dy - tester.getTopLeft(userFinder).dy,
      65,
    );

    final editable = find.descendant(
      of: userFinder,
      matching: find.byType(EditableText),
    );
    expect(
      tester.getTopLeft(editable).dx - tester.getTopLeft(userFinder).dx,
      closeTo(64, 1),
    );
    expect(tester.getTopLeft(userFinder).dy, closeTo(333, 1));
  });

  testWidgets('campos do login mantêm preenchimento foco e senha visível', (
    tester,
  ) async {
    await pumpAt(tester, const LoginPage(), const Size(390, 844));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'cliente@vethome.com');
    await tester.enterText(fields.at(1), 'segredo');
    await tester.tap(find.byTooltip('Mostrar/ocultar senha'));
    await tester.pump();

    expect(find.text('cliente@vethome.com'), findsOneWidget);
    expect(find.text('segredo'), findsOneWidget);
    expect(tester.widget<TextField>(fields.at(1)).obscureText, isFalse);

    await tester.tap(fields.at(0));
    await tester.pump();
    final editable = find.descendant(
      of: fields.at(0),
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isTrue);
  });

  testWidgets('lembrar de mim usa marcador Figma e aceita teclado', (
    tester,
  ) async {
    await pumpAt(tester, const LoginPage(), const Size(390, 844));

    expect(find.byType(Checkbox), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('remember-me-marker'))),
      const Size(16, 15),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('remember-me-marker'))),
      const Offset(79, 458),
    );

    final control = tester.widget<FocusableActionDetector>(
      find.byKey(const ValueKey('remember-me-control')),
    );
    control.focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('login distribui os ícones sociais conforme o frame original', (
    tester,
  ) async {
    await pumpAt(tester, const LoginPage(), const Size(390, 844));

    expect(tester.getTopLeft(find.byTooltip('Google')).dx, closeTo(73, 1));
    expect(tester.getTopLeft(find.byTooltip('Facebook')).dx, closeTo(166, 1));
    expect(tester.getTopLeft(find.byTooltip('Instagram')).dx, closeTo(260, 1));
  });

  testWidgets('cadastro usa a ação marrom Continuar do frame original', (
    tester,
  ) async {
    await pumpAt(tester, const CadastroScreen(), const Size(390, 926));

    final buttonFinder = find.ancestor(
      of: find.text('Continuar'),
      matching: find.byType(PillButton),
    );
    final button = tester.widget<PillButton>(buttonFinder);
    expect(button.color, VetColors.brown);
    expect(tester.getSize(buttonFinder), const Size(181, 71));
  });

  testWidgets('cadastro de endereço usa o painel medido no Figma', (
    tester,
  ) async {
    await pumpAt(tester, const EnderecoScreen(), const Size(390, 844));

    final panelFinder = find.byKey(
      const ValueKey('address-registration-panel'),
    );
    final panel = tester.widget<Container>(panelFinder);
    final decoration = panel.decoration! as BoxDecoration;
    expect(tester.getSize(panelFinder), const Size(290, 565));
    expect(tester.getTopLeft(panelFinder).dy, closeTo(88, 1));
    expect(decoration.color, Colors.white.withValues(alpha: .2));
    expect(decoration.borderRadius, BorderRadius.circular(30));
    expect(decoration.border!.top.width, 3);
    final buttonFinder = find.widgetWithText(ElevatedButton, 'Cadastrar');
    expect(tester.getSize(buttonFinder), const Size(181, 65));
    expect(tester.getTopLeft(buttonFinder).dy, closeTo(683, 1));
  });

  testWidgets('cadastro de pet usa o painel medido no Figma', (tester) async {
    await pumpAt(tester, const CadastroPetScreen(), const Size(390, 844));

    final panelFinder = find.byKey(const ValueKey('pet-registration-panel'));
    final panel = tester.widget<Container>(panelFinder);
    final decoration = panel.decoration! as BoxDecoration;
    expect(tester.getSize(panelFinder), const Size(290, 480));
    expect(decoration.color, Colors.white.withValues(alpha: .2));
    expect(decoration.borderRadius, BorderRadius.circular(30));
    expect(decoration.border!.top.width, 3);
    final buttonFinder = find.widgetWithText(ElevatedButton, 'Cadastrar');
    expect(tester.getSize(buttonFinder), const Size(181, 65));
    expect(
      tester.getTopLeft(buttonFinder).dy - tester.getTopLeft(panelFinder).dy,
      closeTo(524, 1),
    );
    expect(find.byType(PetForm), findsOneWidget);
  });

  testWidgets('cadastro distribui campos em duas colunas no desktop', (
    tester,
  ) async {
    await pumpAt(tester, const CadastroScreen(), const Size(1280, 800));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('vh-form-desktop-grid')), findsOneWidget);
  });

  testWidgets('endereço usa grade desktop sem perder os cinco campos', (
    tester,
  ) async {
    await pumpAt(tester, const EnderecoScreen(), const Size(1280, 800));

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('address-form-desktop-grid')),
      findsOneWidget,
    );
    for (final label in [
      'CEP',
      'Endereço',
      'Número',
      'Complemento (opcional)',
      'Cidade',
    ]) {
      expect(find.text(label), findsWidgets);
    }
  });

  testWidgets('cadastro do pet usa grade desktop e mantém sexo', (
    tester,
  ) async {
    await pumpAt(tester, const CadastroPetScreen(), const Size(1280, 800));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('pet-form-desktop-grid')), findsOneWidget);
    expect(find.text('Gênero/Sexo'), findsOneWidget);
  });
}
