import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/pages/editar_pet_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/pet_form.dart';
import 'package:flutter_vethome/widgets/pet_photo_button.dart';

void main() {
  testWidgets('modal de edição segue o EDIT_PROFILE_PET_WIDGET do Figma', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final pet = PetModel(
        name: 'Fernando',
        imagePath: '',
        description: '',
        species: 'Cachorro',
        sex: 'Macho',
        weightKg: 24,
        birthDate: DateTime(2012, 3, 23),
        breed: 'Lulu-da-Pomerania',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: VetTheme.light(VH.primary),
          home: Scaffold(body: EditarPetPage(pet: pet, modal: true)),
        ),
      );
      await tester.pumpAndSettle();

      final surface = find.byKey(const ValueKey('edit-pet-modal-surface'));
      final surfaceOrigin = tester.getTopLeft(surface);
      expect(tester.getSize(surface), const Size(310, 480));
      expect(find.text('Editar pet'), findsNothing);
      expect(find.bySemanticsLabel('Editar pet'), findsOneWidget);

      void expectField(
        String label,
        Offset offset,
        Size size, {
        required Offset labelOffset,
        TextAlign textAlign = TextAlign.start,
      }) {
        final field = find.ancestor(
          of: find.text(label),
          matching: find.byType(VHField),
        );
        final input = find.descendant(
          of: field.first,
          matching: find.byType(TextFormField),
        );
        expect(tester.getTopLeft(input) - surfaceOrigin, offset, reason: label);
        expect(tester.getSize(input), size, reason: label);
        expect(
          tester.getTopLeft(find.text(label)) - surfaceOrigin,
          labelOffset,
          reason: '$label label',
        );
        expect(
          tester
              .widget<EditableText>(
                find.descendant(of: input, matching: find.byType(EditableText)),
              )
              .textAlign,
          textAlign,
          reason: '$label value alignment',
        );
      }

      expectField(
        'Nome do Cachorro(a)',
        const Offset(25, 51),
        const Size(259, 56),
        labelOffset: const Offset(30, 31),
        textAlign: TextAlign.center,
      );
      expectField(
        'Gênero/Sexo',
        const Offset(25, 143),
        const Size(122, 56),
        labelOffset: const Offset(30, 123),
      );
      expectField(
        'Peso',
        const Offset(160, 143),
        const Size(124, 56),
        labelOffset: const Offset(167, 123),
      );
      expectField(
        'Data de Nascimento',
        const Offset(25, 237),
        const Size(259, 56),
        labelOffset: const Offset(30, 216),
        textAlign: TextAlign.center,
      );
      expectField(
        'Raça',
        const Offset(25, 330),
        const Size(259, 56),
        labelOffset: const Offset(30, 309),
      );

      final sexField = find.ancestor(
        of: find.text('Gênero/Sexo'),
        matching: find.byType(VHField),
      );
      final sexInput = find.descendant(
        of: sexField,
        matching: find.byType(TextFormField),
      );
      expect(tester.widget<TextFormField>(sexInput).controller!.text, 'M');
      final sexSemantics = find.descendant(
        of: sexField,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Gênero/Sexo',
        ),
      );
      expect(tester.widget<Semantics>(sexSemantics).properties.value, 'Macho');

      final weightField = find.ancestor(
        of: find.text('Peso'),
        matching: find.byType(VHField),
      );
      final weightInput = find.descendant(
        of: weightField,
        matching: find.byType(TextFormField),
      );
      final weightWidget = tester.widget<TextFormField>(weightInput);
      expect(weightWidget.controller!.text, '24');
      expect(
        tester
            .widget<InputDecorator>(
              find.descendant(
                of: weightField,
                matching: find.byType(InputDecorator),
              ),
            )
            .decoration
            .suffix,
        isA<Text>(),
      );
      expect(
        find.descendant(of: weightField, matching: find.text('kg')),
        findsOneWidget,
      );

      final cancel = find.ancestor(
        of: find.text('Cancelar'),
        matching: find.byType(OutlinedButton),
      );
      final save = find.widgetWithText(ElevatedButton, 'Salvar');
      final cancelTarget = find.byKey(const ValueKey('pet-edit-cancel-target'));
      final saveTarget = find.byKey(const ValueKey('pet-edit-save-target'));
      final extraOptionsTarget = find.byKey(
        const ValueKey('edit-pet-extra-fields-toggle'),
      );
      expect(tester.getTopLeft(cancel) - surfaceOrigin, const Offset(27, 422));
      expect(tester.getSize(cancel), const Size(98, 34));
      expect(tester.getTopLeft(save) - surfaceOrigin, const Offset(194, 422));
      expect(tester.getSize(save), const Size(90, 34));
      for (final (target, visual, size) in [
        (cancelTarget, cancel, const Size(98, 34)),
        (saveTarget, save, const Size(90, 34)),
      ]) {
        final targetRect = tester.getRect(target);
        final visualRect = tester.getRect(visual);
        expect(targetRect.size, Size(size.width, 48));
        expect(visualRect.size, size);
        expect(visualRect.bottom, targetRect.bottom);
        expect(visualRect.top, targetRect.top + 14);
      }
      expect(
        tester
            .widget<ElevatedButton>(save)
            .style
            ?.backgroundColor
            ?.resolve(<WidgetState>{}),
        VetColors.brown,
      );
      expect(find.text('Castração'), findsNothing);
      expect(find.byType(PetPhotoButton), findsNothing);
      final extraOptionsRect = tester.getRect(extraOptionsTarget);
      expect(extraOptionsRect.size, const Size(69, 48));
      expect(
        extraOptionsRect.left,
        greaterThanOrEqualTo(tester.getRect(cancelTarget).right),
      );
      expect(
        extraOptionsRect.right,
        lessThanOrEqualTo(tester.getRect(saveTarget).left),
      );
      final collapsedSemantics = find.descendant(
        of: extraOptionsTarget,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Mais opções',
        ),
      );
      expect(collapsedSemantics, findsOneWidget);
      expect(
        tester.widget<Semantics>(collapsedSemantics).properties.expanded,
        isFalse,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(extraOptionsTarget);
      await tester.pumpAndSettle();
      expect(find.text('Espécie'), findsOneWidget);
      expect(find.text('Castração'), findsOneWidget);
      expect(find.byType(PetPhotoButton), findsOneWidget);
      final expandedSemantics = find.descendant(
        of: extraOptionsTarget,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Menos opções',
        ),
      );
      expect(expandedSemantics, findsOneWidget);
      expect(
        tester.widget<Semantics>(expandedSemantics).properties.expanded,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('editor compacto salva sexo completo e peso numérico', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pet = PetModel(
      name: 'Fernando',
      imagePath: '',
      description: '',
      species: 'Cachorro',
      sex: 'Macho',
      weightKg: 24.75,
      birthDate: DateTime(2012, 3, 23),
      breed: 'Lulu-da-Pomerania',
    );
    final savedValues = <PetFormValue>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 310,
              height: 480,
              child: PetForm(
                title: 'Editar pet',
                pet: pet,
                modal: true,
                onSaved: savedValues.add,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final sexField = find.ancestor(
      of: find.text('Gênero/Sexo'),
      matching: find.byType(VHField),
    );
    final sexInput = find.descendant(
      of: sexField,
      matching: find.byType(TextFormField),
    );
    final sexFieldWidget = tester.widget<VHField>(sexField);
    expect(sexFieldWidget.choices, ['M', 'F']);
    expect(sexFieldWidget.choiceDisplayLabel?.call('F'), 'Fêmea');
    expect(sexFieldWidget.semanticsValue?.call('F'), 'Fêmea');
    expect(tester.widget<TextFormField>(sexInput).controller!.text, 'M');
    final weightField = find.ancestor(
      of: find.text('Peso'),
      matching: find.byType(VHField),
    );
    final weightInput = find.descendant(
      of: weightField,
      matching: find.byType(TextFormField),
    );
    expect(tester.widget<TextFormField>(weightInput).controller!.text, '24.75');

    await tester.tap(sexInput);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fêmea').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('pet-edit-save-target')));
    await tester.pumpAndSettle();

    expect(savedValues, hasLength(1));
    expect(savedValues.single.sex, 'Fêmea');
    expect(savedValues.single.weight, 24.75);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edição exige espécie e abre Mais opções quando ela falta', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pet = PetModel(
      name: 'Toby',
      imagePath: '',
      description: '',
      sex: 'Macho',
      weightKg: 4,
      birthDate: DateTime(2020, 1, 1),
      breed: 'SRD',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: Scaffold(body: EditarPetPage(pet: pet, modal: true)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('pet-edit-save-target')));
    await tester.pumpAndSettle();

    expect(find.text('Espécie'), findsOneWidget);
    expect(find.text('Obrigatório'), findsOneWidget);
    expect(find.byType(EditarPetPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor permanece acessível com texto ampliado em celulares', (
    tester,
  ) async {
    final pet = PetModel(
      name: 'Toby',
      imagePath: '',
      description: '',
      species: 'Cachorro',
      sex: 'Macho',
      weightKg: 4,
      birthDate: DateTime(2020, 1, 1),
      breed: 'SRD',
    );
    for (final size in const [Size(320, 640), Size(390, 844)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          theme: VetTheme.light(VH.primary),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(body: EditarPetPage(pet: pet, modal: true)),
        ),
      );
      await tester.pumpAndSettle();

      final neuteredField = find.text('Castração');
      await tester.ensureVisible(neuteredField);
      expect(find.byType(PetPhotoButton), findsOneWidget, reason: '$size');
      expect(neuteredField, findsOneWidget, reason: '$size');
      expect(tester.takeException(), isNull, reason: '$size');
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
