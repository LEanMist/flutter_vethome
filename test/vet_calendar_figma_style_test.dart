import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/agenda_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets/vet_calendar.dart';

void main() {
  const repaintBoundaryKey = ValueKey('calendar-test-boundary');

  Future<void> pumpCalendar(
    WidgetTester tester, {
    required Size viewport,
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: repaintBoundaryKey,
              child: SizedBox(
                width: viewport.width >= 900 ? 390 : viewport.width,
                child: VetCalendar(
                  month: DateTime(2026, 10),
                  selected: DateTime(2026, 10, 9),
                  onSelected: (_) {},
                  onPreviousMonth: () {},
                  onNextMonth: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpAgenda(WidgetTester tester, Size viewport) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: AgendaScreen(initialDate: DateTime(2026, 1, 13)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('calendário reproduz painel e dia selecionado do Figma', (
    tester,
  ) async {
    await pumpCalendar(tester, viewport: const Size(390, 844));

    final panel = tester.widget<Container>(
      find.byKey(const ValueKey('vet-calendar')),
    );
    final panelDecoration = panel.decoration! as BoxDecoration;
    expect(panelDecoration.color, const Color(0xFFC08081));
    expect(
      panelDecoration.borderRadius,
      const BorderRadius.vertical(bottom: Radius.circular(30)),
    );

    final weekday = tester.widget<Text>(find.text('Dom'));
    expect(weekday.style?.fontFamily, VH.headingFontFamily);
    expect(weekday.style?.fontSize, 15);
    expect(weekday.style?.fontWeight, FontWeight.bold);
    expect(weekday.style?.color, const Color(0xFF68442E));

    final monthTitle = tester.widget<Text>(find.text('Outubro 2026'));
    expect(monthTitle.style?.fontFamily, VH.headingFontFamily);
    expect(monthTitle.style?.fontSize, 15);
    expect(monthTitle.style?.fontWeight, FontWeight.bold);

    final selectedDay = find.byKey(
      const ValueKey('calendar-2026-10-9-surface'),
    );
    expect(selectedDay, findsOneWidget);
    expect(tester.getSize(selectedDay), const Size.square(35));

    final selectedSurface = tester.widget<Material>(selectedDay);
    expect(selectedSurface.color, const Color(0xFF68442E));
    expect(selectedSurface.shape, const CircleBorder());
    final selectedText = tester.widget<Text>(
      find.descendant(of: selectedDay, matching: find.text('9')),
    );
    expect(selectedText.style?.fontFamily, VH.headingFontFamily);
    expect(selectedText.style?.fontSize, 15);
    expect(selectedText.style?.fontWeight, FontWeight.bold);

    final normalDay = find.byKey(const ValueKey('calendar-2026-10-8-surface'));
    final normalText = tester.widget<Text>(
      find.descendant(of: normalDay, matching: find.text('8')),
    );
    expect(normalText.style?.color, const Color(0xFF68442E));

    final outsideDay = find.byKey(const ValueKey('calendar-2026-9-27-surface'));
    final outsideText = tester.widget<Text>(
      find.descendant(of: outsideDay, matching: find.text('27')),
    );
    expect(
      outsideText.style?.color,
      const Color(0xFF68442E).withValues(alpha: .30),
    );
  });

  testWidgets('hover, foco por teclado e splash são pintados no dia', (
    tester,
  ) async {
    await pumpCalendar(tester, viewport: const Size(390, 844));
    final day = find.byKey(const ValueKey('calendar-2026-10-8'));
    InkWell dayWidget() => tester.widget<InkWell>(day);

    expect(dayWidget().statesController, isNotNull);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(day));
    await tester.pump();
    expect(dayWidget().statesController!.value, contains(WidgetState.hovered));
    final hoverColor = dayWidget().overlayColor!.resolve(
      dayWidget().statesController!.value,
    );
    expect(hoverColor, isNotNull);
    expect(hoverColor, isNot(VH.secondary));

    await mouse.moveTo(Offset.zero);
    await tester.pump();
    final touch = await tester.startGesture(tester.getCenter(day));
    await tester.pump();
    expect(dayWidget().statesController!.value, contains(WidgetState.pressed));
    final pressedColor = dayWidget().overlayColor!.resolve(
      dayWidget().statesController!.value,
    );
    expect(pressedColor, isNotNull);
    expect(pressedColor, isNot(VH.secondary));
    await touch.up();
    await tester.pumpAndSettle();

    final firstDay = find.byKey(const ValueKey('calendar-2026-9-27'));
    InkWell firstDayWidget() => tester.widget<InkWell>(firstDay);
    expect(firstDayWidget().statesController, isNotNull);
    for (var index = 0; index < 3; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(
      firstDayWidget().statesController!.value,
      contains(WidgetState.focused),
    );
    final focusColor = firstDayWidget().overlayColor!.resolve(
      firstDayWidget().statesController!.value,
    );
    expect(focusColor, isNotNull);
    expect(focusColor, isNot(VH.secondary));
    expect(tester.takeException(), isNull);
  });

  testWidgets('calendário permanece íntegro nos breakpoints aprovados', (
    tester,
  ) async {
    for (final viewport in const [
      Size(320, 640),
      Size(390, 844),
      Size(900, 800),
      Size(940, 800),
      Size(964, 800),
      Size(1280, 800),
    ]) {
      await pumpCalendar(tester, viewport: viewport);
      final panel = tester.getRect(find.byKey(const ValueKey('vet-calendar')));
      expect(
        tester.getRect(find.text('Sáb')).right,
        lessThanOrEqualTo(panel.right),
      );
      expect(
        tester.getRect(find.byTooltip('Próximo mês')).right,
        lessThanOrEqualTo(panel.right),
      );
      expect(tester.takeException(), isNull, reason: '$viewport');
    }
  });

  testWidgets('Agenda usa viewport lógico 390×844 sem corte horizontal', (
    tester,
  ) async {
    await pumpAgenda(tester, const Size(390, 844));

    for (final finder in [
      find.text('Sáb'),
      find.byTooltip('Próximo mês'),
      find.byTooltip('Configurações'),
      find.text('Hemograma'),
      find.text('Urina'),
      find.text('Creatinina'),
    ]) {
      final rect = tester.getRect(finder);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(390));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Agenda 360×800 rola sem sobrepor a navegação inferior', (
    tester,
  ) async {
    await pumpAgenda(tester, const Size(360, 800));
    final navigation = find.byTooltip('Configurações');
    final navigationRectBefore = tester.getRect(navigation);

    await tester.scrollUntilVisible(
      find.text('Nova Consulta'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();

    final buttonRect = tester.getRect(find.text('Nova Consulta'));
    final navigationRectAfter = tester.getRect(navigation);
    expect(buttonRect.bottom, lessThanOrEqualTo(navigationRectAfter.top));
    expect(navigationRectAfter, navigationRectBefore);
    expect(tester.getRect(find.text('Sáb')).right, lessThanOrEqualTo(360));
    expect(tester.takeException(), isNull);
  });
}
