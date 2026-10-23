import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets.dart';

void main() {
  const viewports = <Size>[Size(320, 640), Size(390, 844), Size(1280, 800)];

  inset_shadow.BoxDecoration fieldDecoration(WidgetTester tester) => tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(VHField),
          matching: find.byType(DecoratedBox),
        ),
      )
      .map((widget) => widget.decoration)
      .whereType<inset_shadow.BoxDecoration>()
      .single;

  void expectFigmaGradient(inset_shadow.BoxDecoration decoration) {
    expect(decoration.color, isNull);
    final gradient = decoration.gradient! as LinearGradient;
    expect(gradient.colors, [
      VH.secondary.withValues(alpha: .25),
      VH.background,
    ]);
    final shadow = decoration.boxShadow!.single as inset_shadow.BoxShadow;
    expect(shadow.inset, isTrue);
    expect(shadow.color, VetColors.shadowDark);
    expect(shadow.offset, const Offset(2, 2));
    expect(shadow.blurRadius, 2);
  }

  void expectFlatCompactSurface(inset_shadow.BoxDecoration decoration) {
    expect(decoration.color, VH.secondary.withValues(alpha: .25));
    expect(decoration.gradient, isNull);
  }

  for (final viewport in viewports) {
    testWidgets('figmaForm usa gradiente e sombra interna em $viewport', (
      tester,
    ) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 292,
                child: VHField('Nome Completo', Icons.person, figmaForm: true),
              ),
            ),
          ),
        ),
      );

      expectFigmaGradient(fieldDecoration(tester));
      expect(tester.takeException(), isNull);
    });

    testWidgets('compact usa superfície plana e sombra interna em $viewport', (
      tester,
    ) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 292,
                child: VHField('Nome do pet', Icons.pets, compact: true),
              ),
            ),
          ),
        ),
      );

      expectFlatCompactSurface(fieldDecoration(tester));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Login preserva o gradiente aprovado', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pump();

    final approvedLoginGradients = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((widget) => widget.decoration)
        .whereType<inset_shadow.BoxDecoration>()
        .where((decoration) {
          final gradient = decoration.gradient;
          return gradient is LinearGradient &&
              gradient.colors.length == 2 &&
              gradient.colors.first == VH.secondary.withValues(alpha: .25) &&
              gradient.colors.last == VH.background;
        })
        .toList();

    expect(approvedLoginGradients, hasLength(2));
    for (final decoration in approvedLoginGradients) {
      final gradient = decoration.gradient! as LinearGradient;
      expect(gradient.colors, [
        VH.secondary.withValues(alpha: .25),
        VH.background,
      ]);
    }
    expect(tester.takeException(), isNull);
  });
}
