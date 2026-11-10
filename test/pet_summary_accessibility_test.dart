import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/widgets/pet_summary.dart';

void main() {
  testWidgets('Detalhes mantém nome e raça legíveis em largura estreita', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pet = PetModel(
      id: 'pet-summary-narrow',
      name: 'Fernando',
      imagePath: '',
      description: '',
      species: 'Cachorro',
      breed: 'Lulu-do-Pomerânia',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PetSummary(
              pet: pet,
              size: PetSummarySize.detailed,
              onEdit: () {},
              onPhoto: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.text('Fernando')).height, lessThanOrEqualTo(24));
    expect(
      tester.getSize(find.text('Cachorro · Lulu-do-Pomerânia')).height,
      lessThanOrEqualTo(54),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Detalhes do pet anuncia o estado expandido', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      var editPressed = false;
      var photoPressed = false;
      final pet = PetModel(
        id: 'pet-summary-a11y',
        name: 'Toby',
        imagePath: '',
        description: '',
        species: 'Cachorro',
        breed: 'Vira-lata',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetSummary(
              pet: pet,
              size: PetSummarySize.detailed,
              onEdit: () => editPressed = true,
              onPhoto: () => photoPressed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final toggle = find.byKey(const ValueKey('pet-summary-details-toggle'));
      expect(tester.widget<Semantics>(toggle).properties.expanded, isFalse);
      expect(
        tester
            .getSemantics(toggle)
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        ui.Tristate.isFalse,
      );

      await tester.tap(find.text('Toby'));
      await tester.pumpAndSettle();
      expect(find.text('Sexo'), findsOneWidget);
      expect(tester.widget<Semantics>(toggle).properties.expanded, isTrue);
      expect(
        tester
            .getSemantics(toggle)
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        ui.Tristate.isTrue,
      );

      await tester.tap(find.text('Toby'));
      await tester.pumpAndSettle();
      expect(find.text('Sexo'), findsNothing);
      expect(
        tester
            .getSemantics(toggle)
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        ui.Tristate.isFalse,
      );

      final editControl = find.byTooltip('Editar');
      final photoControl = find.byTooltip('Alterar foto do pet');
      expect(editControl, findsOneWidget);
      expect(photoControl, findsOneWidget);
      final editSemantics = tester.getSemantics(editControl);
      final photoSemantics = tester.getSemantics(photoControl);
      expect(editSemantics.id, isNot(photoSemantics.id));
      final editData = editSemantics.getSemanticsData();
      final photoData = photoSemantics.getSemanticsData();
      expect(editData.tooltip, 'Editar');
      expect(photoData.tooltip, 'Alterar foto do pet');
      expect(editData.flagsCollection.isButton, isTrue);
      expect(editData.hasAction(ui.SemanticsAction.tap), isTrue);
      expect(photoData.flagsCollection.isButton, isTrue);
      expect(photoData.hasAction(ui.SemanticsAction.tap), isTrue);

      await tester.tap(editControl);
      await tester.pumpAndSettle();
      expect(editPressed, isTrue);
      expect(
        tester
            .getSemantics(toggle)
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        ui.Tristate.isFalse,
      );

      await tester.tap(photoControl);
      await tester.pumpAndSettle();
      expect(photoPressed, isTrue);
      expect(
        tester
            .getSemantics(toggle)
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        ui.Tristate.isFalse,
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
