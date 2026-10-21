import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/vet/vet_header.dart';

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
        expect(find.text('Pets'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
