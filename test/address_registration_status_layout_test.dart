import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/cep_service.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/address_form.dart';

class _MissingCepService extends CepService {
  @override
  Future<CepResult?> lookup(String cep) async => null;
}

class _RegistrationCepService extends CepService {
  @override
  Future<CepResult?> lookup(String cep) async => switch (cep) {
    '01001-000' => const CepResult('Praça da Sé', 'São Paulo'),
    '12345-678' => const CepResult('', 'Cidade de teste'),
    _ => null,
  };
}

void main() {
  testWidgets(
    'trocar CEP limpa dados automáticos e preserva correções manuais',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddressForm(
              title: 'Endereço',
              cepService: _RegistrationCepService(),
              onSkip: () {},
              onSaved: (_) {},
            ),
          ),
        ),
      );
      Finder field(String label) => find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is VHField && widget.label == label,
        ),
        matching: find.byType(TextFormField),
      );
      String value(String label) =>
          tester.widget<TextFormField>(field(label)).controller!.text;

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Preencha este campo'), findsNWidgets(3));

      await tester.enterText(field('CEP'), '01001000');
      await tester.pumpAndSettle();
      expect(value('Logradouro'), 'Praça da Sé');
      expect(value('Cidade'), 'São Paulo');
      expect(find.text('CEP consultado.'), findsNothing);
      expect(find.text('Preencha este campo'), findsOneWidget);
      final number = find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Número',
      );
      expect(
        find.descendant(of: number, matching: find.text('Preencha este campo')),
        findsOneWidget,
      );

      await tester.enterText(field('Logradouro'), 'Rua de teste');
      await tester.enterText(field('CEP'), '12345678');
      await tester.pumpAndSettle();
      expect(value('Logradouro'), 'Rua de teste');
      expect(value('Cidade'), 'Cidade de teste');

      await tester.enterText(field('CEP'), '99999999');
      await tester.pumpAndSettle();
      expect(value('Logradouro'), 'Rua de teste');
      expect(value('Cidade'), isEmpty);
    },
  );

  testWidgets('status do CEP expande o painel sem cortar o campo Cidade', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Finder field(String label) => find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == label,
      ),
      matching: find.byType(TextFormField),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: Scaffold(
          body: AddressForm(
            title: 'Endereço',
            cepService: _MissingCepService(),
            onSkip: () {},
            onSaved: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final panel = find.byKey(const ValueKey('address-registration-panel'));
    final initialHeight = tester.getSize(panel).height;

    await tester.enterText(field('CEP'), '99999999');
    await tester.pumpAndSettle();

    expect(
      find.text('CEP não encontrado. Confira ou preencha manualmente.'),
      findsOneWidget,
    );
    final panelRect = tester.getRect(panel);
    expect(panelRect.height, greaterThan(initialHeight));
    expect(
      tester.getRect(field('Cidade')).bottom,
      lessThanOrEqualTo(panelRect.bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('erros de cadastro expandem o painel sem cortar os campos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Finder field(String label) => find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == label,
      ),
      matching: find.byType(TextFormField),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: Scaffold(
          body: AddressForm(
            title: 'Endereço',
            cepService: _MissingCepService(),
            onSkip: () {},
            onSaved: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final panel = find.byKey(const ValueKey('address-registration-panel'));
    final initialHeight = tester.getSize(panel).height;
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pumpAndSettle();
    final cepEditable = find.descendant(
      of: field('CEP'),
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(cepEditable).focusNode.hasFocus, isTrue);

    final panelRect = tester.getRect(panel);
    expect(panelRect.height, greaterThan(initialHeight));
    expect(find.text('Informe um CEP com 8 números'), findsOneWidget);
    expect(find.text('Preencha este campo'), findsNWidgets(3));
    await tester.ensureVisible(field('Cidade'));
    final lastError = find.text('Preencha este campo').last;
    await tester.ensureVisible(lastError);
    expect(tester.getRect(lastError).bottom, lessThanOrEqualTo(844));
    expect(tester.takeException(), isNull);
  });

  testWidgets('feedback do CEP continua alcançável a 200% em tela estreita', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    Finder field(String label) => find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == label,
      ),
      matching: find.byType(TextFormField),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: AddressForm(
            title: 'Endereço',
            cepService: _MissingCepService(),
            onSkip: () {},
            onSaved: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(field('CEP'));
    await tester.enterText(field('CEP'), '99999999');
    await tester.pumpAndSettle();

    expect(
      find.text('CEP não encontrado. Confira ou preencha manualmente.'),
      findsOneWidget,
    );
    final panel = find.byKey(const ValueKey('address-registration-panel'));
    expect(tester.getRect(panel).height, greaterThan(473));
    final button = find.widgetWithText(ElevatedButton, 'Continuar');
    expect(button.hitTestable(), findsOneWidget);
    expect(tester.getBottomRight(button).dy, lessThanOrEqualTo(440));
    expect(find.text('Pular').hitTestable(), findsOneWidget);
    await tester.ensureVisible(field('Cidade'));
    expect(tester.getRect(field('Cidade')).bottom, lessThanOrEqualTo(640));
    expect(tester.takeException(), isNull);
  });
}
