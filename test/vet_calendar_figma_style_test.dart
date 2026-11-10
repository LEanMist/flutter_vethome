import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/agenda_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/vet_calendar.dart';

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

void main() {
  const repaintBoundaryKey = ValueKey('calendar-test-boundary');

  Future<void> pumpCalendar(
    WidgetTester tester, {
    required Size viewport,
    DateTime? month,
    DateTime? selected,
    bool agendaPageStyle = false,
    VoidCallback? onPreviousMonth,
    VoidCallback? onNextMonth,
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
                  month: month ?? DateTime(2026, 10),
                  selected: selected ?? DateTime(2026, 10, 9),
                  onSelected: (_) {},
                  onPreviousMonth: onPreviousMonth ?? () {},
                  onNextMonth: onNextMonth ?? () {},
                  hasIndicator: (date) => date == DateTime(2026, 10, 9),
                  agendaPageStyle: agendaPageStyle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpAgenda(
    WidgetTester tester,
    Size viewport, {
    DateTime? initialDate,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: AgendaScreen(initialDate: initialDate ?? DateTime(2026, 1, 13)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('calendário mantém geometria do Figma com contraste acessível', (
    tester,
  ) async {
    await pumpCalendar(tester, viewport: const Size(390, 844));
    final semantics = tester.ensureSemantics();
    try {
      await tester.pump();
      expect(
        find.bySemanticsLabel(
          RegExp(r'sexta-feira, 9 de outubro de 2026, possui agendamento'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          RegExp(r'quinta-feira, 8 de outubro de 2026, possui agendamento'),
        ),
        findsNothing,
      );
    } finally {
      semantics.dispose();
    }

    final panel = tester.widget<Container>(
      find.byKey(const ValueKey('vet-calendar')),
    );
    final panelDecoration = panel.decoration! as BoxDecoration;
    expect(panelDecoration.color, const Color(0xFFC08081));
    expect(panelDecoration.borderRadius, BorderRadius.circular(30));

    final weekday = tester.widget<Text>(find.text('Dom'));
    expect(weekday.style?.fontFamily, VH.headingFontFamily);
    expect(weekday.style?.fontSize, 15);
    expect(weekday.style?.fontWeight, FontWeight.bold);
    expect(weekday.style?.color, VetColors.calendarTextOnRose);
    expect(
      _contrastRatio(weekday.style!.color!, const Color(0xFFC08081)),
      greaterThanOrEqualTo(4.5),
    );

    final monthTitle = tester.widget<Text>(find.text('Outubro'));
    expect(monthTitle.style?.fontFamily, VH.headingFontFamily);
    expect(monthTitle.style?.fontSize, 15);
    expect(monthTitle.style?.fontWeight, FontWeight.bold);
    expect(monthTitle.style?.color, VetColors.calendarTextOnRose);
    final yearTitle = tester.widget<Text>(find.text('2026'));
    expect(yearTitle.style?.fontFamily, VH.headingFontFamily);
    expect(yearTitle.style?.fontSize, 15);
    expect(yearTitle.style?.fontWeight, FontWeight.bold);
    expect(yearTitle.style?.color, VetColors.calendarTextOnRose);

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
    expect(normalText.style?.color, VetColors.calendarTextOnRose);

    final outsideDay = find.byKey(const ValueKey('calendar-2026-9-27-surface'));
    final outsideText = tester.widget<Text>(
      find.descendant(of: outsideDay, matching: find.text('27')),
    );
    expect(outsideText.style?.color, VetColors.calendarTextOnRose);
    expect(outsideText.style?.fontWeight, FontWeight.w500);
  });

  testWidgets('indicador da Agenda mantém centro branco no calendário largo', (
    tester,
  ) async {
    await pumpCalendar(
      tester,
      viewport: const Size(1280, 800),
      selected: DateTime(2026, 10, 8),
    );

    final day = find.byKey(const ValueKey('calendar-2026-10-9-surface'));
    final dots = tester.widgetList<CircleAvatar>(
      find.descendant(of: day, matching: find.byType(CircleAvatar)),
    );

    expect(dots, hasLength(2));
    expect(dots.first.backgroundColor, VetColors.calendarTextOnRose);
    expect(dots.last.backgroundColor, Colors.white);
    expect(tester.takeException(), isNull);
  });

  testWidgets('calendário de consulta segue a geometria do Figma', (
    tester,
  ) async {
    await pumpCalendar(
      tester,
      viewport: const Size(390, 844),
      month: DateTime(2026, 1),
      selected: DateTime(2026, 1, 13),
    );

    expect(VetCalendar.monthDays(DateTime(2026, 1)), hasLength(35));
    final panelRect = tester.getRect(
      find.byKey(const ValueKey('vet-calendar')),
    );
    expect(panelRect.size, const Size(390, 383));
    expect(
      tester.getRect(find.byKey(const ValueKey('calendar-month-label'))),
      Rect.fromLTWH(128, panelRect.top + 22, 71, 35),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('calendar-year-label'))),
      Rect.fromLTWH(226, panelRect.top + 22, 35, 35),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('calendar-month-grid'))),
      Rect.fromLTWH(42, panelRect.top + 75, 305, 260),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('calendar-2026-1-1-surface'))),
      Rect.fromLTWH(222, panelRect.top + 120, 35, 35),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('calendar-2026-1-31-surface'))),
      Rect.fromLTWH(312, panelRect.top + 300, 35, 35),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Agenda suaviza datas adjacentes sem perder contraste legível', (
    tester,
  ) async {
    await pumpCalendar(
      tester,
      viewport: const Size(390, 844),
      month: DateTime(2026, 11),
      selected: DateTime(2026, 11, 13),
      agendaPageStyle: true,
    );

    final outsideDay = find.byKey(const ValueKey('calendar-2026-12-1-surface'));
    final outsideText = tester.widget<Text>(
      find.descendant(of: outsideDay, matching: find.text('1')),
    );
    final figmaPanelSurface = Color.alphaBlend(
      VetColors.pink.withValues(alpha: .3),
      VetColors.rose,
    );
    final figmaAdjacentText = Color.alphaBlend(
      VetColors.brown.withValues(alpha: .3),
      figmaPanelSurface,
    );

    expect(outsideText.style?.color, VetColors.calendarAdjacentDayText);
    expect(_contrastRatio(figmaAdjacentText, figmaPanelSurface), lessThan(4.5));
    expect(
      _contrastRatio(outsideText.style!.color!, figmaPanelSurface),
      greaterThanOrEqualTo(4.8),
    );
    expect(outsideText.style?.fontWeight, FontWeight.w500);
  });

  testWidgets('ponto branco de consulta mantém contorno com contraste', (
    tester,
  ) async {
    await pumpCalendar(
      tester,
      viewport: const Size(390, 844),
      month: DateTime(2026, 10),
      selected: DateTime(2026, 10, 10),
      agendaPageStyle: true,
    );

    final appointmentDay = find.byKey(
      const ValueKey('calendar-2026-10-9-surface'),
    );
    final markerFinder = find.descendant(
      of: appointmentDay,
      matching: find.byType(CircleAvatar),
    );
    final markers = tester.widgetList<CircleAvatar>(markerFinder).toList();
    expect(markers, hasLength(2));

    final outlineFinder = markerFinder.first;
    final centerFinder = markerFinder.last;
    final outline = markers.first;
    final center = markers.last;
    final panelSurface = Color.alphaBlend(
      VetColors.pink.withValues(alpha: .3),
      VetColors.rose,
    );

    expect(outline.radius, 3);
    expect(tester.getSize(outlineFinder), const Size.square(6));
    expect(outline.backgroundColor, VetColors.calendarTextOnRose);
    expect(center.radius, 2);
    expect(tester.getSize(centerFinder), const Size.square(4));
    expect(center.backgroundColor, Colors.white);
    expect(
      _contrastRatio(outline.backgroundColor!, panelSurface),
      greaterThanOrEqualTo(3),
    );
    expect(
      _contrastRatio(center.backgroundColor!, outline.backgroundColor!),
      greaterThanOrEqualTo(3),
    );
  });

  testWidgets('calendário de consulta permite avançar o mês por gesto', (
    tester,
  ) async {
    var nextMonthCalls = 0;
    await pumpCalendar(
      tester,
      viewport: const Size(390, 844),
      onNextMonth: () => nextMonthCalls++,
    );

    await tester.drag(
      find.byKey(const ValueKey('vet-calendar')),
      const Offset(-120, 0),
    );
    await tester.pumpAndSettle();

    expect(nextMonthCalls, 1);
    expect(tester.takeException(), isNull);
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
    var firstDayFocused = false;
    for (var index = 0; index < 50 && !firstDayFocused; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      firstDayFocused = firstDayWidget().statesController!.value.contains(
        WidgetState.focused,
      );
    }
    expect(
      firstDayFocused,
      isTrue,
      reason: 'Tab precisa alcançar a primeira data da grade',
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
        tester
            .getRect(find.byKey(const ValueKey('calendar-month-label')))
            .right,
        lessThanOrEqualTo(panel.right),
      );
      expect(tester.takeException(), isNull, reason: '$viewport');
    }
  });

  testWidgets('Agenda usa viewport lógico 390×844 sem corte horizontal', (
    tester,
  ) async {
    await pumpAgenda(tester, const Size(390, 844));

    final appointmentBoxes = [
      for (final label in ['Hemograma', 'Urina', 'Creatinina'])
        tester.getRect(
          find
              .ancestor(of: find.text(label), matching: find.byType(Container))
              .first,
        ),
    ];
    for (final rect in appointmentBoxes) {
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(390));
    }

    // CALENDAR_PAGE 2783:950, na página de entrega atual: cabeçalho 390×344,
    // grade x=31/y=65, faixa selecionada em y=323 e cartões a partir de x=102.
    expect(
      tester.getRect(find.byKey(const ValueKey('vet-calendar'))),
      const Rect.fromLTWH(0, 0, 390, 344),
    );
    expect(
      find.byKey(const ValueKey('agenda-calendar-inner-panel')),
      findsNothing,
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('agenda-calendar-month-slot'))),
      const Rect.fromLTWH(126, 17, 71, 35),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('agenda-calendar-year-slot'))),
      const Rect.fromLTWH(207, 17, 35, 35),
    );
    final monthGrid = tester.getRect(
      find.byKey(const ValueKey('agenda-calendar-month-grid')),
    );
    expect(monthGrid, const Rect.fromLTWH(31, 65, 327, 230));
    final januaryFirst = tester.getRect(
      find.byKey(const ValueKey('calendar-date-semantics-2026-1-1')),
    );
    // O protótipo coloca 1º de janeiro no domingo; o app mantém o calendário
    // gregoriano correto, quinta-feira, e preserva o mesmo tamanho de toque.
    expect(januaryFirst.left, closeTo(223.57, .02));
    expect(januaryFirst.top, closeTo(105, .01));
    expect(januaryFirst.width, closeTo(35, .01));
    expect(januaryFirst.height, closeTo(35, .01));
    expect(
      find.byKey(const ValueKey('calendar-date-semantics-2025-12-28')),
      findsOneWidget,
      reason: 'A grade deve exibir os dias do mês adjacente.',
    );
    final cardTopByLabel = {
      'Hemograma': 399.0,
      'Urina': 483.0,
      'Creatinina': 567.0,
    };
    for (final entry in cardTopByLabel.entries) {
      final card = find
          .ancestor(of: find.text(entry.key), matching: find.byType(Container))
          .first;
      expect(tester.getRect(card), Rect.fromLTWH(102, entry.value, 195, 50));
    }
    expect(
      tester.getRect(find.byKey(const ValueKey('agenda-selected-date'))),
      const Rect.fromLTWH(67, 323, 258, 41),
    );
    for (var index = 0; index < 2; index++) {
      final line = tester.getRect(
        find.byKey(ValueKey('agenda-divider-$index')),
      );
      expect(line.left, closeTo(88, .5));
      expect(line.width, closeTo(221, .5));
      expect(line.center.dy, closeTo(466 + 85 * index, .5));
    }
    expect(
      tester.getRect(find.byKey(const ValueKey('agenda-chevron-up'))),
      const Rect.fromLTWH(345, 435, 20, 20),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('agenda-chevron-down'))),
      const Rect.fromLTWH(345, 560, 20, 20),
    );
    final newAppointmentButton = find
        .ancestor(
          of: find.text('Nova Consulta'),
          matching: find.byType(Container),
        )
        .first;
    expect(
      tester.getRect(newAppointmentButton),
      const Rect.fromLTWH(145.5, 651.5, 99, 41),
    );
    final newAppointmentTarget = tester.getRect(
      find.byKey(const ValueKey('agenda-new-appointment-target')),
    );
    expect(newAppointmentTarget.width, greaterThanOrEqualTo(48));
    expect(newAppointmentTarget.height, greaterThanOrEqualTo(48));
    expect(
      newAppointmentTarget.center,
      tester.getRect(newAppointmentButton).center,
    );
    final stickyFooter = find.byKey(
      const ValueKey('agenda-sticky-action-footer'),
    );
    expect(stickyFooter, findsOneWidget);
    final footerRect = tester.getRect(stickyFooter);
    expect(footerRect.top, 648);
    expect(footerRect.bottom, 718);
    expect(newAppointmentTarget.top, greaterThanOrEqualTo(footerRect.top));
    expect(newAppointmentTarget.bottom, lessThanOrEqualTo(footerRect.bottom));
    expect(
      footerRect.bottom,
      lessThanOrEqualTo(tester.getRect(find.byTooltip('Pets')).top),
    );
    expect(find.byTooltip('Pets'), findsOneWidget);
    expect(
      tester.getRect(find.byTooltip('Pets')),
      const Rect.fromLTWH(30, 734, 50, 50),
    );
    expect(
      tester.getRect(find.byTooltip('Configurações')),
      const Rect.fromLTWH(310, 734, 50, 50),
    );

    for (final finder in [
      find.text('Sáb'),
      find.byKey(const ValueKey('agenda-calendar-month-navigation')),
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

  testWidgets('Agenda vazia oculta as setas dos cartões', (tester) async {
    await pumpAgenda(
      tester,
      const Size(390, 844),
      initialDate: DateTime(2026, 2, 17),
    );

    expect(find.text('Não há consultas neste dia.'), findsOneWidget);
    expect(find.byKey(const ValueKey('agenda-chevron-up')), findsNothing);
    expect(find.byKey(const ValueKey('agenda-chevron-down')), findsNothing);
    expect(
      find.byKey(const ValueKey('agenda-new-appointment-target')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Agenda seis semanas não sobrepõe a data selecionada em 320 px', (
    tester,
  ) async {
    const viewport = Size(320, 640);
    await pumpAgenda(tester, viewport, initialDate: DateTime(2026, 8, 15));

    final lastWeekDay = tester.getRect(
      find.byKey(const ValueKey('calendar-2026-9-5-surface')),
    );
    final selectedDate = tester.getRect(
      find.byKey(const ValueKey('agenda-selected-date')),
    );
    final expectedScale = viewport.width / 390;

    expect(lastWeekDay.bottom, lessThanOrEqualTo(selectedDate.top));
    expect(selectedDate.bottom, lessThanOrEqualTo(403 * expectedScale));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Agenda expande a faixa da data com texto ampliado', (
    tester,
  ) async {
    final scenarios = [
      (viewport: const Size(390, 844), date: DateTime(2026, 1, 13)),
      (viewport: const Size(320, 640), date: DateTime(2026, 8, 15)),
    ];

    for (final scenario in scenarios) {
      await pumpAgenda(
        tester,
        scenario.viewport,
        initialDate: scenario.date,
        textScale: 2,
      );
      final scale = (scenario.viewport.width / 390).clamp(0.8, 1.0);
      final selectedDate = tester.getRect(
        find.byKey(const ValueKey('agenda-selected-date')),
      );
      final label = tester.getRect(
        find.byKey(const ValueKey('agenda-selected-date-label')),
      );
      final emptyMessage = find.text('Não há consultas neste dia.');
      final appointmentCard = find.byWidgetPredicate(
        (widget) =>
            widget is InkWell &&
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'agenda-appointment-',
            ),
      );
      final followingContent = emptyMessage.evaluate().isNotEmpty
          ? emptyMessage
          : appointmentCard.first;
      final followingContentRect = tester.getRect(followingContent);

      expect(selectedDate.height, greaterThan(41 * scale));
      expect(label.left, greaterThanOrEqualTo(selectedDate.left + 5 * scale));
      expect(label.right, lessThanOrEqualTo(selectedDate.right - 5 * scale));
      expect(label.top, greaterThanOrEqualTo(selectedDate.top + 5 * scale));
      expect(label.bottom, lessThanOrEqualTo(selectedDate.bottom - 5 * scale));
      expect(
        followingContentRect.top,
        greaterThanOrEqualTo(selectedDate.bottom + 8 * scale),
      );
      if (appointmentCard.evaluate().isNotEmpty) {
        final lastAppointment = tester.getRect(appointmentCard.last);
        final actionTarget = tester.getRect(
          find.byKey(const ValueKey('agenda-new-appointment-target')),
        );
        final stickyFooter = find.byKey(
          const ValueKey('agenda-sticky-action-footer'),
        );
        if (stickyFooter.evaluate().isNotEmpty) {
          final footerRect = tester.getRect(stickyFooter);
          expect(actionTarget.top, greaterThanOrEqualTo(footerRect.top));
          expect(actionTarget.bottom, lessThanOrEqualTo(footerRect.bottom));
          expect(
            footerRect.bottom,
            lessThanOrEqualTo(
              tester.getRect(find.byTooltip('Configurações')).top,
            ),
          );
          expect(lastAppointment.bottom, greaterThan(actionTarget.top));
        } else {
          expect(
            actionTarget.top + .01,
            greaterThanOrEqualTo(lastAppointment.bottom + 8 * scale),
            reason:
                '${scenario.viewport}: Nova Consulta não deve cobrir o último cartão',
          );
        }
      }
      expect(tester.takeException(), isNull, reason: '${scenario.viewport}');
    }
  });

  testWidgets('Agenda 360×800 mantém Nova Consulta sem rolar', (tester) async {
    await pumpAgenda(tester, const Size(360, 800));
    final navigation = find.byTooltip('Configurações');
    final navigationRectBefore = tester.getRect(navigation);
    final buttonRect = tester.getRect(find.text('Nova Consulta'));
    final buttonTargetRect = tester.getRect(
      find.byKey(const ValueKey('agenda-new-appointment-target')),
    );
    final navigationRectAfter = tester.getRect(navigation);
    expect(buttonRect.bottom, lessThanOrEqualTo(navigationRectAfter.top));
    expect(buttonTargetRect.height, greaterThanOrEqualTo(48));
    expect(navigationRectAfter, navigationRectBefore);
    expect(tester.getRect(find.text('Sáb')).right, lessThanOrEqualTo(360));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Nova Consulta mantém alvo de 48 px em 320×640', (tester) async {
    await pumpAgenda(tester, const Size(320, 640));

    final target = tester.getRect(
      find.byKey(const ValueKey('agenda-new-appointment-target')),
    );
    final button = tester.getRect(
      find
          .ancestor(
            of: find.text('Nova Consulta'),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(target.height, greaterThanOrEqualTo(48));
    expect(target.width, greaterThanOrEqualTo(48));
    expect(button.height, closeTo(41 * (320 / 390), .01));
    expect(target.center, button.center);
    expect(
      target.bottom,
      lessThanOrEqualTo(tester.getRect(find.byTooltip('Configurações')).top),
      reason: 'A ação deve ficar disponível acima da navegação sem rolagem',
    );
    expect(
      find.byKey(const ValueKey('agenda-sticky-action-footer')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
