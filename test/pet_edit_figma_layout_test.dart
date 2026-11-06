import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/pages/editar_pet_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/pet_photo_button.dart';

void main() {
  testWidgets('modal de edição segue o EDIT_PROFILE_PET_WIDGET do Figma', (
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

    final cancel = find.ancestor(
      of: find.text('Cancelar'),
      matching: find.byType(OutlinedButton),
    );
    final save = find.widgetWithText(ElevatedButton, 'Salvar');
    expect(tester.getTopLeft(cancel) - surfaceOrigin, const Offset(27, 422));
    expect(tester.getSize(cancel), const Size(98, 34));
    expect(tester.getTopLeft(save) - surfaceOrigin, const Offset(194, 422));
    expect(tester.getSize(save), const Size(90, 34));
    expect(find.text('Castração'), findsNothing);
    expect(find.byType(PetPhotoButton), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(
      find.byKey(const ValueKey('edit-pet-extra-fields-toggle')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Espécie'), findsOneWidget);
    expect(find.text('Castração'), findsOneWidget);
    expect(find.byType(PetPhotoButton), findsOneWidget);
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

    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
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
