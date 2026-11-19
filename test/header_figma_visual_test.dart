import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/vet/vet_header.dart';

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + .05) / (darker + .05);
}

void main() {
  const viewports = <Size>[Size(320, 640), Size(390, 844), Size(1280, 800)];

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
  }

  testWidgets(
    'VHHeader padrão segue a geometria do Figma em todas as larguras',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final viewport in viewports) {
        setViewport(tester, viewport);
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: VHHeader('Serviços'))),
        );

        final header = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(VHHeader),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = header.decoration! as BoxDecoration;

        expect(tester.getSize(find.byType(VHHeader)).height, 125);
        expect(
          decoration.borderRadius,
          const BorderRadius.vertical(bottom: Radius.circular(30)),
        );
        expect(decoration.boxShadow, isNull);
        expect(find.text('Serviços'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('VetHeader segue a geometria do Figma em todas as larguras', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final viewport in viewports) {
      setViewport(tester, viewport);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: VetHeader(title: 'Endereços')),
        ),
      );

      final header = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(VetHeader),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = header.decoration! as BoxDecoration;

      expect(tester.getSize(find.byType(VetHeader)).height, 125);
      expect(
        decoration.borderRadius,
        const BorderRadius.vertical(bottom: Radius.circular(30)),
      );
      expect(decoration.boxShadow, isNull);
      expect(find.text('Endereços'), findsOneWidget);
      final backIcon = tester.widget<Icon>(find.byIcon(Icons.arrow_back));
      expect(backIcon.color, VetColors.brown);
      final backButtonSurface = Color.alphaBlend(
        Colors.white.withValues(alpha: .2),
        VetColors.rose,
      );
      expect(
        _contrastRatio(backIcon.color!, backButtonSurface),
        greaterThanOrEqualTo(3),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'cabeçalho de Pets segue a geometria do Figma em todas as larguras',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final viewport in viewports) {
        setViewport(tester, viewport);
        await tester.pumpWidget(const MaterialApp(home: PetsPage()));
        await tester.pump();

        final header = tester
            .widgetList<Container>(find.byType(Container))
            .firstWhere((container) {
              final decoration = container.decoration;
              return decoration is BoxDecoration &&
                  decoration.color == VetColors.rose &&
                  container.constraints?.maxHeight != null;
            });
        final decoration = header.decoration! as BoxDecoration;

        expect(header.constraints?.maxHeight, 125);
        expect(
          decoration.borderRadius,
          const BorderRadius.vertical(bottom: Radius.circular(30)),
        );
        expect(decoration.boxShadow, isNull);
        final titleFinder = find.text('Pets');
        final scale = (viewport.width / 390).clamp(.8, 1.0).toDouble();
        expect(titleFinder, findsOneWidget);
        expect(find.byTooltip('Telas de teste'), findsNothing);
        expect(
          tester.getTopLeft(titleFinder).dx,
          closeTo((viewport.width - 134 * scale) / 2, .5),
        );
        if (viewport == const Size(390, 844)) {
          // Figma PETS_PAGE 2783:1236: x=128, y=46, width=134.
          expect(tester.getCenter(titleFinder).dy, closeTo(62.5, .5));
          expect(tester.getSize(titleFinder).width, closeTo(134, 1));
        }
        expect(tester.takeException(), isNull);
      }
    },
  );
}
