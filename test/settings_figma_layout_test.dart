import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/config_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Comfortaa')
      ..addFont(rootBundle.load('assets/fonts/ComfortaaBold.ttf'));
    await loader.load();
  });

  Future<void> openSettings(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('SETTINGS_PAGE: posições do Figma em 390x844', (tester) async {
    await openSettings(tester, const Size(390, 844));

    final header = find.byType(VHHeader);
    expect(tester.getRect(header), const Rect.fromLTWH(0, 0, 390, 125));
    final title = find.text('Configurações');
    final titleStyle = tester.widget<Text>(title).style!;
    expect(titleStyle.fontFamily, VH.headingFontFamily);
    expect(titleStyle.fontWeight, FontWeight.bold);
    expect(titleStyle.fontSize, 30);

    for (final (label, expectedTop) in const [
      ('Configurações', 46.0),
      ('Tema do Aplicativo', 171.0),
      ('Meus Endereços', 229.0),
      ('Suporte', 287.0),
      ('Historico', 347.0),
      ('Sair', 402.0),
    ]) {
      final rect = tester.getRect(find.text(label));
      final renderParagraph = tester.renderObject<RenderParagraph>(
        find.text(label),
      );
      final textBox = renderParagraph
          .getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: label.length),
          )
          .first;
      final paintedTop = rect.top + textBox.top;
      // O teste usa Comfortaa real: compara a linha pintada à camada Figma.
      // Métricas de fontes entre motores permitem um pequeno deslocamento.
      if (label == 'Configurações') {
        expect(rect.top, closeTo(expectedTop, .5));
      } else {
        expect(paintedTop, closeTo(expectedTop, 3.1));
        expect(
          rect.left,
          closeTo(label == 'Tema do Aplicativo' ? 27 : 29, 1.5),
        );
      }
      if (label != 'Configurações') {
        final style = tester.widget<Text>(find.text(label)).style!;
        expect(style.fontFamily, VH.headingFontFamily);
        expect(style.fontWeight, FontWeight.bold);
        expect(style.fontSize, 18);
        expect(style.color, VH.foreground);
      }
    }

    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(tiles, hasLength(5));
    for (final tile in tiles) {
      expect(tile.onTap, isNotNull);
      expect(tile.enabled, isTrue);
    }

    final dividers = find.byType(Divider);
    expect(dividers, findsNWidgets(4));
    for (final (i, top) in const [
      (0, 208.0),
      (1, 267.0),
      (2, 326.0),
      (3, 384.0),
    ]) {
      final rect = tester.getRect(dividers.at(i));

      expect(rect.left, closeTo(12, 0.5));
      expect(rect.width, closeTo(366, .5));
      expect(rect.top, closeTo(top, 1.1));
    }

    final nav = find.byType(VetBottomNav);
    expect(nav, findsOneWidget);
    expect(tester.widget<VetBottomNav>(nav).selectedIndex, 4);
    final navSurfaces = find.descendant(
      of: nav,
      matching: find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is inset_shadow.BoxDecoration &&
            decoration.borderRadius == BorderRadius.circular(25) &&
            decoration.color == VH.secondary.withValues(alpha: 0.5);
      }),
    );
    expect(navSurfaces, findsOneWidget);
    final surface = tester.widget<Container>(navSurfaces);
    final outer = tester.getRect(navSurfaces);
    final margin = surface.margin!.resolve(TextDirection.ltr);
    final visible = Rect.fromLTRB(
      outer.left + margin.left,
      outer.top + margin.top,
      outer.right - margin.right,
      outer.bottom - margin.bottom,
    );
    expect(visible, const Rect.fromLTWH(12, 724, 366, 70));
    expect(
      find.descendant(
        of: nav,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Configurações' &&
              widget.properties.selected == true,
        ),
      ),
      findsOneWidget,
    );
    for (final (index, label) in const [
      (0, 'Pets'),
      (1, 'Perfil'),
      (2, 'Conversa'),
      (3, 'Agenda'),
      (4, 'Configurações'),
    ]) {
      final destination = find.descendant(
        of: nav,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label == label,
        ),
      );
      expect(destination, findsOneWidget);
      expect(
        tester.getRect(destination),
        Rect.fromLTWH(30 + index * 70, 734, 50, 50),
      );
    }
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 640), const Size(1280, 800)]) {
    testWidgets('Configurações preserva responsividade em $size', (
      tester,
    ) async {
      await openSettings(tester, size);
      expect(find.byType(ListTile), findsNWidgets(5));
      expect(find.byType(Divider), findsNWidgets(4));
      expect(find.byType(VetBottomNav), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
