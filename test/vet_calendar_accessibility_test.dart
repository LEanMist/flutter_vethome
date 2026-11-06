import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/agenda_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets/vet_calendar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final heading = FontLoader('Comfortaa')
      ..addFont(rootBundle.load('assets/fonts/ComfortaaBold.ttf'));
    await heading.load();
    final body = FontLoader(
      'MontserratAlternates',
    )..addFont(rootBundle.load('assets/fonts/MontserratAlternatesRegular.ttf'));
    await body.load();
  });

  Future<void> pumpAgenda(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: MediaQuery(
          data: MediaQueryData.fromView(
            tester.view,
          ).copyWith(textScaler: TextScaler.linear(1)),
          child: AgendaScreen(initialDate: DateTime(2026, 1, 13)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpCalendar(
    WidgetTester tester,
    double textScale, {
    bool agendaPageStyle = true,
    DateTime? month,
    DateTime? selected,
    DateTime? firstDate,
    DateTime? lastDate,
    VoidCallback? onPreviousMonth,
    VoidCallback? onNextMonth,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: MediaQuery(
          data: MediaQueryData.fromView(
            tester.view,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 390,
                child: VetCalendar(
                  agendaPageStyle: agendaPageStyle,
                  month: month ?? DateTime(2026, 1),
                  selected: selected ?? DateTime(2026, 1, 13),
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onSelected: (_) {},
                  onPreviousMonth: onPreviousMonth ?? () {},
                  onNextMonth: onNextMonth ?? () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('agenda oferece ações de mês na árvore de acessibilidade', (
    tester,
  ) async {
    await pumpAgenda(tester);
    final semantics = tester.ensureSemantics();
    try {
      final monthNavigation = find.byKey(
        const ValueKey('agenda-calendar-month-navigation'),
      );
      expect(monthNavigation, findsOneWidget);

      const previousMonth = CustomSemanticsAction(label: 'Mês anterior');
      const nextMonth = CustomSemanticsAction(label: 'Próximo mês');
      final nextMonthId = CustomSemanticsAction.getIdentifier(nextMonth);
      final previousMonthId = CustomSemanticsAction.getIdentifier(
        previousMonth,
      );
      final navigationNode = tester.getSemantics(monthNavigation);
      expect(
        navigationNode.getSemanticsData().hint,
        'Use Page Up para o mês anterior e Page Down para o próximo mês.',
      );
      final exposedActions = navigationNode
          .getSemanticsData()
          .customSemanticsActionIds!
          .map(CustomSemanticsAction.getAction)
          .map((action) => action?.label);
      expect(exposedActions, containsAll(['Mês anterior', 'Próximo mês']));

      navigationNode.owner!.performAction(
        navigationNode.id,
        SemanticsAction.customAction,
        nextMonthId,
      );
      await tester.pumpAndSettle();
      expect(find.text('Fevereiro'), findsOneWidget);

      final updatedNavigationNode = tester.getSemantics(monthNavigation);
      updatedNavigationNode.owner!.performAction(
        updatedNavigationNode.id,
        SemanticsAction.customAction,
        previousMonthId,
      );
      await tester.pumpAndSettle();
      expect(find.text('Janeiro'), findsOneWidget);

      final day = tester.getSemantics(
        find.byKey(const ValueKey('calendar-date-semantics-2026-1-13')),
      );
      final dayData = day.getSemanticsData();
      expect(dayData.hasAction(SemanticsAction.tap), isTrue);
      expect(dayData.flagsCollection.isButton, isTrue);
      expect(dayData.flagsCollection.isSelected, Tristate.isTrue);

      final nextDay = tester.getSemantics(
        find.byKey(const ValueKey('calendar-date-semantics-2026-1-14')),
      );
      final nextDayData = nextDay.getSemanticsData();
      expect(nextDayData.label, 'quarta-feira, 14 de janeiro de 2026');
      expect(nextDayData.hasAction(SemanticsAction.tap), isTrue);
      expect(nextDayData.flagsCollection.isButton, isTrue);
      expect(nextDayData.flagsCollection.isEnabled, Tristate.isTrue);
      nextDay.owner!.performAction(nextDay.id, SemanticsAction.tap);
      await tester.pumpAndSettle();
      expect(find.text('14 - Quarta Feira'), findsOneWidget);
      expect(
        tester
            .getSemantics(
              find.byKey(const ValueKey('calendar-date-semantics-2026-1-14')),
            )
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('Page Up e Page Down trocam o mês pelo teclado', (tester) async {
    var previousMonthCalls = 0;
    var nextMonthCalls = 0;
    await pumpCalendar(
      tester,
      1,
      onPreviousMonth: () => previousMonthCalls++,
      onNextMonth: () => nextMonthCalls++,
    );

    var focusedDay = false;
    for (var index = 0; index < 42 && !focusedDay; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      focusedDay = tester
          .widgetList<InkWell>(find.byType(InkWell))
          .any(
            (day) =>
                day.statesController?.value.contains(WidgetState.focused) ??
                false,
          );
    }
    expect(focusedDay, isTrue, reason: 'Tab precisa alcançar uma data');

    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    expect(nextMonthCalls, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    expect(previousMonthCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('datas expõem nomes completos e respeitam limites inclusivos', (
    tester,
  ) async {
    await pumpCalendar(
      tester,
      1,
      firstDate: DateTime(2026, 1, 13),
      lastDate: DateTime(2026, 1, 14),
    );
    final semantics = tester.ensureSemantics();
    try {
      expect(find.bySemanticsLabel('Domingo'), findsOneWidget);

      final beforeRange = tester.getSemantics(
        find.byKey(const ValueKey('calendar-date-semantics-2026-1-12')),
      );
      final firstDay = tester.getSemantics(
        find.byKey(const ValueKey('calendar-date-semantics-2026-1-13')),
      );
      final lastDay = tester.getSemantics(
        find.byKey(const ValueKey('calendar-date-semantics-2026-1-14')),
      );
      final afterRange = tester.getSemantics(
        find.byKey(const ValueKey('calendar-date-semantics-2026-1-15')),
      );

      expect(
        beforeRange.getSemanticsData().label,
        'segunda-feira, 12 de janeiro de 2026',
      );
      expect(
        beforeRange.getSemanticsData().flagsCollection.isEnabled,
        Tristate.isFalse,
      );
      expect(
        beforeRange.getSemanticsData().hasAction(SemanticsAction.tap),
        isFalse,
      );
      expect(
        firstDay.getSemanticsData().flagsCollection.isEnabled,
        Tristate.isTrue,
      );
      expect(
        lastDay.getSemanticsData().flagsCollection.isEnabled,
        Tristate.isTrue,
      );
      expect(
        afterRange.getSemanticsData().flagsCollection.isEnabled,
        Tristate.isFalse,
      );
      expect(
        afterRange.getSemanticsData().hasAction(SemanticsAction.tap),
        isFalse,
      );

      await pumpCalendar(tester, 1, lastDate: DateTime(2026, 1, 14));
      final beforeLastDate = tester.getSemantics(
        find.byKey(const ValueKey('calendar-date-semantics-2026-1-13')),
      );
      final afterLastDate = tester.getSemantics(
        find.byKey(const ValueKey('calendar-date-semantics-2026-1-15')),
      );
      expect(
        beforeLastDate.getSemanticsData().flagsCollection.isEnabled,
        Tristate.isTrue,
      );
      expect(
        afterLastDate.getSemanticsData().flagsCollection.isEnabled,
        Tristate.isFalse,
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('agenda anuncia o dia atual sem alterar o visual do Figma', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final otherDay = DateTime(now.year, now.month, today.day == 1 ? 2 : 1);
    await pumpCalendar(
      tester,
      1,
      month: DateTime(today.year, today.month),
      selected: otherDay,
    );
    final semantics = tester.ensureSemantics();
    try {
      final todayNode = tester.getSemantics(
        find.byKey(
          ValueKey(
            'calendar-date-semantics-${today.year}-${today.month}-${today.day}',
          ),
        ),
      );
      expect(todayNode.getSemanticsData().label, contains(', hoje'));

      final todaySurface = tester.widget<Material>(
        find.byKey(
          ValueKey(
            'calendar-${today.year}-${today.month}-${today.day}-surface',
          ),
        ),
      );
      expect(todaySurface.shape, isA<CircleBorder>());
      expect((todaySurface.shape! as CircleBorder).side.width, 0);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('ambas as variações anunciam os dias da semana por extenso', (
    tester,
  ) async {
    for (final agendaStyle in [true, false]) {
      await pumpCalendar(tester, 1, agendaPageStyle: agendaStyle);
      final semantics = tester.ensureSemantics();
      try {
        expect(find.bySemanticsLabel('Domingo'), findsOneWidget);
        expect(find.bySemanticsLabel('Quinta-feira'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    }
  });

  for (final (key, label) in [
    (LogicalKeyboardKey.enter, 'Enter'),
    (LogicalKeyboardKey.space, 'Espaço'),
  ]) {
    testWidgets('Agenda: Tab e $label selecionam uma data do calendário', (
      tester,
    ) async {
      await pumpAgenda(tester);

      final target = find.byKey(const ValueKey('calendar-2026-1-14'));
      expect(target, findsOneWidget);

      var focused = false;
      for (var index = 0; index < 50 && !focused; index++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final day = tester.widget<InkWell>(target);
        focused =
            day.statesController?.value.contains(WidgetState.focused) ?? false;
      }
      expect(focused, isTrue, reason: 'Tab deve alcançar 14 de janeiro');

      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
      expect(find.text('14 - Quarta Feira'), findsOneWidget);

      final semantics = tester.ensureSemantics();
      try {
        final selected = tester.getSemantics(
          find.byKey(const ValueKey('calendar-date-semantics-2026-1-14')),
        );
        expect(
          selected.getSemanticsData().flagsCollection.isSelected,
          Tristate.isTrue,
        );
        expect(
          selected.getSemanticsData().label,
          'quarta-feira, 14 de janeiro de 2026',
        );
      } finally {
        semantics.dispose();
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('títulos do calendário não são cortados com texto ampliado', (
    tester,
  ) async {
    for (final factor in [1.0, 1.5, 2.0]) {
      await pumpCalendar(tester, factor);

      final monthHeading = find.byKey(
        const ValueKey('agenda-calendar-month-heading'),
      );
      expect(monthHeading, findsOneWidget);
      expect(
        tester.renderObject<RenderParagraph>(monthHeading).didExceedMaxLines,
        isFalse,
        reason: 'O mês foi cortado com TextScaler $factor',
      );
      expect(tester.takeException(), isNull, reason: 'TextScaler $factor');
    }
  });
}
