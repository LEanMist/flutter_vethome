import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    expect(find.byType(SvgPicture), findsNWidgets(6));

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
    expect(
      tester.getRect(find.byWidget(marker)).left,
      closeTo(181, .02),
      reason:
          'SERVICES_PAGE 2791:3127: marcador alinhado à margem direita do Figma',
    );

    expect(find.text('Vacinas'), findsOneWidget);
    expect(find.text('Microchipagem'), findsOneWidget);
    expect(find.text('Atestados'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Serviços conserva geometria individual das faixas do Figma', (
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

    // SERVICES_PAGE 2791:3113; medidas absolutas no frame 390 × 844.
    const categories = [
      (
        'Exames',
        Rect.fromLTWH(0, 190, 263, 59),
        Rect.fromLTWH(15, 209, 30, 30),
        Rect.fromLTWH(240.075, 215.996, 19.698, 11.124),
      ),
      (
        'Vacinas',
        Rect.fromLTWH(0, 368, 263, 59),
        Rect.fromLTWH(16.669, 383, 31.181, 30),
        Rect.fromLTWH(226.345, 389.735, 8.008, 16.63),
      ),
      (
        'Microchipagem',
        Rect.fromLTWH(-1, 546, 263, 59),
        Rect.fromLTWH(13, 560, 30, 30),
        Rect.fromLTWH(289.5, 569, 17, 19),
      ),
      (
        'Atestados',
        Rect.fromLTWH(-5, 627, 267, 59),
        Rect.fromLTWH(8, 641, 32, 32),
        Rect.fromLTWH(289.5, 650, 17, 19),
      ),
    ];

    for (final (name, pillRect, iconRect, arrowRect) in categories) {
      final actualPill = tester.getRect(
        find.byKey(ValueKey('services-pill-$name')),
      );
      final actualIcon = tester.getRect(
        find.byKey(ValueKey('services-category-icon-$name')),
      );
      final arrow = find.byKey(ValueKey('services-category-arrow-$name'));
      final actualArrow = name == 'Microchipagem' || name == 'Atestados'
          ? tester.getRect(
              find.byKey(ValueKey('services-category-chevron-$name')),
            )
          : tester.getRect(arrow);

      expect(actualPill.left, closeTo(pillRect.left, .02), reason: name);
      expect(actualPill.top, closeTo(pillRect.top, .02), reason: name);
      expect(actualPill.width, closeTo(pillRect.width, .02), reason: name);
      expect(actualPill.height, closeTo(pillRect.height, .02), reason: name);
      expect(actualIcon.left, closeTo(iconRect.left, .02), reason: name);
      expect(actualIcon.top, closeTo(iconRect.top, .02), reason: name);
      expect(actualIcon.width, closeTo(iconRect.width, .02), reason: name);
      expect(actualIcon.height, closeTo(iconRect.height, .02), reason: name);
      expect(actualArrow.left, closeTo(arrowRect.left, .02), reason: name);
      expect(actualArrow.top, closeTo(arrowRect.top, .02), reason: name);
      expect(actualArrow.width, closeTo(arrowRect.width, .02), reason: name);
      expect(actualArrow.height, closeTo(arrowRect.height, .02), reason: name);
    }

    for (final (name, top) in const [('Exames', 249.0), ('Vacinas', 427.0)]) {
      final options = tester.getRect(
        find.byKey(ValueKey('services-options-$name')),
      );
      expect(options, Rect.fromLTWH(0, top, 228, 101));

      final indicator = tester.getRect(
        find.byKey(ValueKey('services-options-indicator-$name')),
      );
      expect(
        indicator.left,
        closeTo(213.7, .02),
        reason: 'SERVICES_PAGE 2791:${name == 'Exames' ? '3126' : '3134'}',
      );
      expect(indicator.top, closeTo(top + 25.5, .02), reason: name);
      expect(indicator.width, closeTo(3, .02), reason: name);
      expect(indicator.height, closeTo(28, .02), reason: name);
    }

    final examsDecoration =
        tester
                .widget<Ink>(find.byKey(const ValueKey('services-pill-Exames')))
                .decoration!
            as BoxDecoration;
    final examsGradient = examsDecoration.gradient! as LinearGradient;
    expect(examsGradient.begin, const Alignment(-1, -1.07212));
    expect(examsGradient.end, const Alignment(1, 1.07212));
    expect(
      examsDecoration.borderRadius,
      const BorderRadius.only(
        topRight: Radius.circular(800),
        bottomRight: Radius.circular(400),
      ),
    );

    final vaccinesDecoration =
        tester
                .widget<Ink>(
                  find.byKey(const ValueKey('services-pill-Vacinas')),
                )
                .decoration!
            as BoxDecoration;
    final vaccinesGradient = vaccinesDecoration.gradient! as LinearGradient;
    expect(vaccinesGradient.begin, const Alignment(-1, -0.0756));
    expect(vaccinesGradient.end, const Alignment(1, 0.0756));
    expect(vaccinesGradient.stops, [0.0019273, 0.99814]);

    final microchipDecoration =
        tester
                .widget<Ink>(
                  find.byKey(const ValueKey('services-pill-Microchipagem')),
                )
                .decoration!
            as BoxDecoration;
    final microchipGradient = microchipDecoration.gradient! as LinearGradient;
    expect(microchipGradient.begin, const Alignment(-1, -0.0756));
    expect(microchipGradient.end, const Alignment(1, 0.0756));
    expect(microchipGradient.stops, [0.0019273, 0.99814]);
    expect(
      microchipDecoration.borderRadius,
      const BorderRadius.only(
        topRight: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
    );

    final atestadosDecoration =
        tester
                .widget<Ink>(
                  find.byKey(const ValueKey('services-pill-Atestados')),
                )
                .decoration!
            as BoxDecoration;
    final atestadosGradient = atestadosDecoration.gradient! as LinearGradient;
    expect(atestadosGradient.begin, const Alignment(-1, 0.8813));
    expect(atestadosGradient.end, const Alignment(1, -0.8813));
    expect(
      atestadosDecoration.borderRadius,
      const BorderRadius.only(
        topRight: Radius.circular(400),
        bottomRight: Radius.circular(800),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
