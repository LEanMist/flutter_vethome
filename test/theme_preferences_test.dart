import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vethome/data/theme_preferences.dart';
import 'package:flutter_vethome/pages/config_page.dart';
import 'package:flutter_vethome/theme.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tema escolhido em Configurações persiste após reinicialização', (
    tester,
  ) async {
    final previousSeed = VH.themeSeed.value;
    addTearDown(() => VH.themeSeed.value = previousSeed);

    await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));
    await tester.tap(find.text('Tema do Aplicativo'));
    await tester.pumpAndSettle();
    final colorWheel = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/imagens/figma/image-8.png',
    );
    expect(tester.getSize(colorWheel), const Size(239, 237));
    final wheelFrame = find.byKey(const ValueKey('theme-color-wheel-frame'));
    final frameRect = tester.getRect(wheelFrame);
    final frameDecoration =
        tester.widget<Container>(wheelFrame).decoration! as BoxDecoration;
    expect(tester.getSize(wheelFrame), const Size(264, 261));
    expect(frameDecoration.color, const Color(0xFFFAD3D5));
    expect(frameDecoration.borderRadius, BorderRadius.circular(30));
    expect(
      tester
              .getRect(find.byKey(const ValueKey('theme-color-wheel-image')))
              .topLeft -
          frameRect.topLeft,
      const Offset(12, 12),
    );
    final ring = find.byKey(const ValueKey('theme-color-wheel-ring'));
    expect(tester.getSize(ring), const Size(236, 236));
    expect(
      tester.getRect(ring).topLeft - frameRect.topLeft,
      const Offset(15, 14),
    );
    final selection = find.byKey(const ValueKey('theme-color-wheel-selection'));
    expect(tester.getSize(selection), const Size(28, 28));
    expect(
      tester.getRect(selection).topLeft - frameRect.topLeft,
      const Offset(119, 118),
    );
    // O centro do COLORS_WIDGET (2783:766) não tem contorno no Figma.
    final selectionDecoration =
        tester.widget<Container>(selection).decoration! as BoxDecoration;
    expect(selectionDecoration.shape, BoxShape.circle);
    expect(selectionDecoration.border, isNull);
    expect(selectionDecoration.color, VH.themeSeed.value);
    final rose = find.byWidgetPredicate(
      (widget) =>
          widget is CircleAvatar &&
          widget.backgroundColor == const Color(0xFFC08081),
    );
    await tester.tap(rose);
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt(ThemePreferences.storageKey), 0xFFC08081);

    VH.themeSeed.value = VH.primary;
    await ThemePreferences.load();
    expect(VH.themeSeed.value, const Color(0xFFC08081));
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 640), const Size(390, 844)]) {
    testWidgets('alvos do seletor de tema cabem em $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));
      await tester.tap(find.text('Tema do Aplicativo'));
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byKey(const ValueKey('theme-color-wheel-frame'))),
        const Size(264, 261),
      );
      final swatches = [
        for (final palette in ThemePreferences.options)
          find.byKey(ValueKey('theme-swatch-target-${palette.name}')),
      ];
      expect(swatches, hasLength(5));
      final bounds = [for (final swatch in swatches) tester.getRect(swatch)];
      for (final (index, rect) in bounds.indexed) {
        expect(rect.width, greaterThanOrEqualTo(48));
        expect(rect.height, greaterThanOrEqualTo(48));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(size.width));
        final palette = ThemePreferences.options[index];
        final visual = find.byKey(
          ValueKey('theme-swatch-visual-${palette.name}'),
        );
        final visualRect = tester.getRect(visual);
        final isSelected = palette.color == VH.themeSeed.value;
        expect(visualRect.size, Size.square(isSelected ? 38 : 32));
        expect(visualRect.center, rect.center);
      }
      expect(bounds.map((rect) => rect.top).toSet(), hasLength(1));
      expect(tester.takeException(), isNull);
    });
  }

  test(
    'prefere o tema padrão quando o armazenamento contém uma cor inválida',
    () async {
      SharedPreferences.setMockInitialValues({
        ThemePreferences.storageKey: 0xFF12AB34,
      });
      VH.themeSeed.value = VH.primary;

      await ThemePreferences.load();

      expect(VH.themeSeed.value, VH.primary);
    },
  );

  test('não grava cores fora da paleta disponível', () async {
    final saved = await ThemePreferences.save(Colors.red);
    final preferences = await SharedPreferences.getInstance();

    expect(saved, isFalse);
    expect(preferences.getInt(ThemePreferences.storageKey), isNull);
  });
}
