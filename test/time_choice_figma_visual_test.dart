import 'dart:ui' show Tristate;

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
    final startControl = find.byKey(
      const ValueKey('appointment-booking-start-time'),
    );
    await tester.ensureVisible(startControl);
    await tester.tap(startControl);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('time-choice-panel')), findsOneWidget);
  }

  testWidgets('seletor de horários segue CALENDAR_TIME_WIDGET do Figma', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await openPicker(tester, const Size(390, 844));
    final panelFinder = find.byKey(const ValueKey('time-choice-panel'));
    final panelRect = tester.getRect(panelFinder);
    expect(panelRect.width, 390);
    expect(panelRect.height, 168);
    final panel = tester.widget<Container>(panelFinder);
    final panelDecoration = panel.decoration! as BoxDecoration;
    expect(panelDecoration.color, VetColors.pink);
    expect(panelDecoration.borderRadius, BorderRadius.circular(30));
    expect(panelDecoration.boxShadow, isNull);
    expect(find.text('Escolha o horário'), findsNothing);
    expect(find.text('Cancelar'), findsNothing);
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
      expect(rect.left - gridOrigin.dx, closeTo(expectedX, .01));
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
      VetColors.calendarTextOnRose,
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
    expect(
      selectedButton.style!.foregroundColor!.resolve(const <WidgetState>{}),
      Colors.white,
    );
    expect(
      _contrastRatio(VetColors.calendarTextOnRose, VetColors.rose),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(Colors.white, VetColors.brown),
      greaterThanOrEqualTo(4.5),
    );

    await tester.tapAt(const Offset(195, 100));
    await tester.pumpAndSettle();
    expect(panelFinder, findsNothing);
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
    await tester.tapAt(const Offset(160, 80));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('seletor anuncia a rota e cada horário para acessibilidade', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    try {
      await openPicker(tester, const Size(390, 844));
      final route = tester.getSemantics(
        find.byKey(const ValueKey('time-choice-semantics')),
      );
      expect(route.label, startsWith('Escolha o horário'));
      expect(route.flagsCollection.scopesRoute, isTrue);
      expect(route.flagsCollection.namesRoute, isTrue);

      final timeButton = tester.getSemantics(
        find.byKey(const ValueKey('time-choice-semantics-12')),
      );
      expect(timeButton.label, contains('12:00'));
      expect(timeButton.flagsCollection.isButton, isTrue);
      expect(timeButton.flagsCollection.isSelected, Tristate.isTrue);
      expect(
        tester
            .getSemantics(
              find.byKey(const ValueKey('time-choice-semantics-13')),
            )
            .flagsCollection
            .isSelected,
        Tristate.isFalse,
      );

      final alternativeHour = [13, 14, 15, 16].firstWhere(
        (hour) =>
            tester
                .widget<ElevatedButton>(
                  find.byKey(ValueKey('time-choice-$hour')),
                )
                .onPressed !=
            null,
        orElse: () => 0,
      );
      if (alternativeHour != 0) {
        await tester.tap(find.byKey(ValueKey('time-choice-$alternativeHour')));
        await tester.pumpAndSettle();
        final startControl = find.byKey(
          const ValueKey('appointment-booking-start-time'),
        );
        await tester.ensureVisible(startControl);
        await tester.tap(startControl);
        await tester.pumpAndSettle();

        expect(
          tester
              .getSemantics(
                find.byKey(ValueKey('time-choice-semantics-$alternativeHour')),
              )
              .flagsCollection
              .isSelected,
          Tristate.isTrue,
        );
        expect(
          tester
              .getSemantics(
                find.byKey(const ValueKey('time-choice-semantics-12')),
              )
              .flagsCollection
              .isSelected,
          Tristate.isFalse,
        );
      }

      await tester.tapAt(const Offset(195, 100));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    } finally {
      semanticsHandle.dispose();
    }
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + .05) / (darker + .05);
}
