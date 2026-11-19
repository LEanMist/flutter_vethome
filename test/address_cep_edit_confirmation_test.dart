import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/cep_service.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/address_form.dart';

class _MissingCepService extends CepService {
  @override
  Future<CepResult?> lookup(String cep) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'CEP alterado sem resultado exige confirmação ao editar endereço',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SavedAddress? saved;
      const existing = SavedAddress(
        id: 'existing-address',
        name: 'Casa',
        street: 'Rua anterior',
        number: '15',
        complement: '',
        city: 'Cidade anterior',
        cep: '01001-000',
      );

      Finder field(String label) => find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is VHField && widget.label == label,
        ),
        matching: find.byType(TextFormField),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddressForm(
              title: 'Endereço',
              initial: existing,
              cepService: _MissingCepService(),
              onDelete: (_) {},
              onSaved: (address) => saved = address,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(field('CEP'), '99999999');
      await tester.pumpAndSettle();
      await tester.ensureVisible(field('Logradouro'));
      await tester.enterText(field('Logradouro'), 'Rua preenchida manualmente');
      await tester.ensureVisible(field('Cidade'));
      await tester.enterText(field('Cidade'), 'Cidade preenchida manualmente');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Salvar'));
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(saved, isNull);
      expect(
        find.textContaining('O CEP mudou e não foi possível confirmar'),
        findsOneWidget,
      );
      await tester.tap(find.text('Corrigir'));
      await tester.pumpAndSettle();
      expect(saved, isNull);

      await tester.ensureVisible(find.text('Salvar'));
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(saved?.cep, '99999-999');
      expect(saved?.street, 'Rua preenchida manualmente');
      expect(saved?.city, 'Cidade preenchida manualmente');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'novo endereço permite preencher manualmente quando o CEP não é encontrado',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SavedAddress? saved;
      var saveCalls = 0;
      Finder field(String label) => find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is VHField && widget.label == label,
        ),
        matching: find.byType(TextFormField),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddressForm(
              title: 'Novo endereço',
              cepService: _MissingCepService(),
              onSaved: (address) {
                saved = address;
                saveCalls++;
              },
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

      for (final entry in const {
        'Endereço': 'Rua digitada manualmente',
        'Numero': '42',
        'Cidade': 'Cidade digitada manualmente',
      }.entries) {
        await tester.ensureVisible(field(entry.key));
        await tester.enterText(field(entry.key), entry.value);
        await tester.pumpAndSettle();
      }

      await tester.ensureVisible(find.text('Salvar endereço'));
      await tester.tap(find.text('Salvar endereço'));
      await tester.pumpAndSettle();

      expect(saveCalls, 1);
      expect(saved?.cep, '99999-999');
      expect(saved?.street, 'Rua digitada manualmente');
      expect(saved?.number, '42');
      expect(saved?.city, 'Cidade digitada manualmente');
      expect(
        find.textContaining('O CEP mudou e não foi possível confirmar'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
