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

void main() {
  testWidgets('status do CEP expande o painel sem cortar o campo Nome', (
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
    expect(tester.getSize(panel).height, 565);

    await tester.enterText(field('CEP'), '99999999');
    await tester.pumpAndSettle();

    expect(
      find.text('CEP não encontrado. Confira ou preencha manualmente.'),
      findsOneWidget,
    );
    final panelRect = tester.getRect(panel);
    expect(panelRect.height, greaterThan(565));
    expect(
      tester.getRect(field('Nome')).bottom,
      lessThanOrEqualTo(panelRect.bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('feedback do CEP continua alcançável a 200% em tela estreita', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
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
    expect(tester.getRect(panel).height, greaterThan(565));
    await tester.ensureVisible(field('Nome'));
    expect(tester.getRect(field('Nome')).bottom, lessThanOrEqualTo(640));
    expect(tester.takeException(), isNull);
  });
}
