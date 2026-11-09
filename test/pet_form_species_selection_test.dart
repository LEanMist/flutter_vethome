import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/pet_form.dart';

void main() {
  Future<void> chooseSpecies(
    WidgetTester tester,
    String label,
    String value,
  ) async {
    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == label,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(value).last);
    await tester.pumpAndSettle();
  }

  Finder breedInput() {
    final field = find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == 'Raça',
    );
    return find.descendant(of: field, matching: find.byType(TextFormField));
  }

  testWidgets('reselecionar a mesma espécie no cadastro preserva a raça', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: Scaffold(
          body: PetForm(title: 'Cadastrar pet', onSaved: (_) {}, onSkip: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await chooseSpecies(tester, 'Tipo de Animal', 'Cachorro');
    await tester.enterText(breedInput(), 'Golden Retriever');
    await chooseSpecies(tester, 'Tipo de Animal', 'Cachorro');

    expect(
      tester.widget<TextFormField>(breedInput()).controller!.text,
      'Golden Retriever',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('cadastro mostra M/F e anuncia Sexo por extenso', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: VetTheme.light(VH.primary),
          home: Scaffold(
            body: PetForm(
              title: 'Cadastrar pet',
              onSaved: (_) {},
              onSkip: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sexField = find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Gênero/Sexo',
      );
      final input = find.descendant(
        of: sexField,
        matching: find.byType(TextFormField),
      );
      await tester.tap(input);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Macho').last);
      await tester.pumpAndSettle();

      expect(tester.widget<VHField>(sexField).choices, ['M', 'F']);
      expect(tester.widget<TextFormField>(input).controller!.text, 'M');
      final accessibleValue = find.bySemanticsLabel('Gênero/Sexo');
      expect(tester.getSemantics(accessibleValue).value, 'Macho');

      await tester.tap(input);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fêmea').last);
      await tester.pumpAndSettle();
      expect(tester.widget<TextFormField>(input).controller!.text, 'F');
      expect(tester.getSemantics(accessibleValue).value, 'Fêmea');
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets(
    'reselecionar espécie preserva raça na edição; mudar espécie limpa',
    (tester) async {
      final pet = PetModel(
        name: 'Bidu',
        imagePath: '',
        description: '',
        species: 'Cachorro',
        sex: 'Macho',
        weightKg: 8,
        birthDate: DateTime(2020, 1, 1),
        breed: 'Poodle',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: VetTheme.light(VH.primary),
          home: Scaffold(
            body: SingleChildScrollView(
              child: PetForm(title: 'Editar pet', pet: pet, onSaved: (_) {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await chooseSpecies(tester, 'Espécie', 'Cachorro');
      expect(
        tester.widget<TextFormField>(breedInput()).controller!.text,
        'Poodle',
      );

      await chooseSpecies(tester, 'Espécie', 'Gato');
      expect(tester.widget<TextFormField>(breedInput()).controller!.text, '');
      expect(tester.takeException(), isNull);
    },
  );
}
