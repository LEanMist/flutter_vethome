import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final fontLoader = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
    await fontLoader.load();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  Future<void> openPicker(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: NovaConsultaPage(
          pet: VetRepository.pets.first,
          service: 'Hemograma',
          plan: 'Particular',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('time-choice-panel')), findsNothing);
    final startTile = find.widgetWithText(ListTile, 'Início');
    await tester.ensureVisible(startTile);
    await tester.tap(startTile);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('time-choice-panel')), findsOneWidget);
  }

  testWidgets('seletor de horários segue CALENDAR_TIME_WIDGET do Figma', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await openPicker(tester, const Size(390, 844));
    final grid = find.byKey(const ValueKey('time-choice-grid'));
    final gridOrigin = tester.getTopLeft(grid);

    for (final (hour, expectedX, expectedY) in [
      (12, 18.0, 28.0),
      (13, 146.0, 28.0),
      (14, 272.0, 28.0),
      (15, 86.0, 95.0),
      (16, 212.0, 95.0),
    ]) {
      final buttonFinder = find.byKey(ValueKey('time-choice-$hour'));
      final rect = tester.getRect(buttonFinder);
      expect(rect.width, closeTo(100, .01));
      expect(rect.height, closeTo(45, .01));
      expect(rect.left - gridOrigin.dx, closeTo(expectedX, 1));
      expect(rect.top - gridOrigin.dy, expectedY);

      final wrapper = tester.widget<Container>(
        find.byKey(ValueKey('time-choice-shadow-$hour')),
      );
      final decoration = wrapper.decoration! as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(4));
      expect(decoration.boxShadow, hasLength(1));
      expect(decoration.boxShadow!.single.offset, const Offset(0, 4));
      expect(decoration.boxShadow!.single.blurRadius, 4);
      expect(
        decoration.boxShadow!.single.color,
        const Color.fromRGBO(0, 0, 0, .25),
      );
    }

    final normalButton = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('time-choice-13')),
    );
    final normalStyle = normalButton.style!;
    expect(
      normalStyle.backgroundColor!.resolve(const <WidgetState>{}),
      VH.secondary,
    );
    expect(
      normalStyle.foregroundColor!.resolve(const <WidgetState>{}),
      Colors.white,
    );
    expect(
      normalStyle.shape!.resolve(const <WidgetState>{}),
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
    final labelStyle = normalStyle.textStyle!.resolve(const <WidgetState>{})!;
    expect(labelStyle.fontFamily, 'Inter');
    expect(labelStyle.fontSize, 20);
    expect(labelStyle.fontWeight, FontWeight.normal);
    final label = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byKey(const ValueKey('time-choice-13')),
        matching: find.text('13:00'),
      ),
    );
    expect(label.text.style!.fontFamily, 'Inter');

    final selectedButton = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('time-choice-12')),
    );
    expect(
      selectedButton.style!.backgroundColor!.resolve(const <WidgetState>{}),
      VetColors.brown,
    );

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('time-choice-panel')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('seletor de horários cabe em 320 px sem cortar botões', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openPicker(tester, const Size(320, 640));
    for (final hour in [12, 13, 14, 15, 16]) {
      final rect = tester.getRect(find.byKey(ValueKey('time-choice-$hour')));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320));
      expect(rect.width, closeTo(100, .01));
      expect(rect.height, closeTo(45, .01));
    }
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
