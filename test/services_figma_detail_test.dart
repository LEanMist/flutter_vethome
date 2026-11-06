import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/screens/pets.dart' show ServicosScreen;
import 'package:flutter_vethome/theme.dart';

void main() {
  testWidgets('Serviços: opção Exames segue tipografia e marcador do Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final previousPet = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previousPet);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(const MaterialApp(home: ServicosScreen()));
    await tester.pumpAndSettle();

    final optionFinder = find.text('Hemograma');
    expect(optionFinder, findsOneWidget);
    final optionText = tester.widget<Text>(optionFinder);
    // SERVICES_PAGE 2791:3113 > opções de Exames (font 15 Medium).
    expect(optionText.style?.fontFamily, VH.bodyFontFamily);
    expect(optionText.style?.fontSize, 15);
    expect(optionText.style?.fontWeight, FontWeight.w500);
    expect(optionText.style?.color, VH.foreground);

    final optionRow = find
        .ancestor(of: optionFinder, matching: find.byType(Row))
        .first;
    final marker = tester
        .widgetList<Container>(
          find.descendant(of: optionRow, matching: find.byType(Container)),
        )
        .singleWhere((container) {
          final decoration = container.decoration;
          return decoration is BoxDecoration &&
              decoration.border != null &&
              decoration.borderRadius == BorderRadius.circular(3);
        });
    // SERVICES_PAGE 2791:3127-3129: marcadores de 15 x 15.
    expect(tester.getSize(find.byWidget(marker)), const Size(15, 15));

    expect(find.text('Vacinas'), findsOneWidget);
    expect(find.text('Microchipagem'), findsOneWidget);
    expect(find.text('Atestados'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
