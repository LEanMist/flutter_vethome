import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/cliente/consulta/nova_consulta_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/vet_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  Future<void> pumpAt(
    WidgetTester tester,
    double width, {
    double height = 844,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: NovaConsultaPage(
          pet: VetRepository.pets.first,
          service: 'Hemograma',
          plan: 'Particular',
        ),
      ),
    );
    await tester.pump();
  }

  for (final width in <double>[900, 940, 964]) {
    testWidgets('calendário permanece acessível em ${width.toInt()} px', (
      tester,
    ) async {
      await pumpAt(tester, width);

      final desktopLayout = find.byKey(
        const ValueKey('new-appointment-desktop-layout'),
      );
      if (desktopLayout.evaluate().isNotEmpty) {
        expect(
          find.descendant(
            of: desktopLayout,
            matching: find.byType(VetCalendar),
          ),
          findsOneWidget,
        );
        return;
      }

      final dateControl = tester.widget<InkWell>(
        find.byKey(const ValueKey('appointment-booking-date')),
      );
      expect(dateControl.onTap, isNotNull);
      dateControl.onTap!();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('mobile-calendar-dialog')),
        findsOneWidget,
      );
    });
  }

  testWidgets('calendário permite datas futuras em mobile e desktop', (
    tester,
  ) async {
    await pumpAt(tester, 390);
    final mobileDateTile = tester.widget<InkWell>(
      find.byKey(const ValueKey('appointment-booking-date')),
    );
    expect(mobileDateTile.onTap, isNotNull);
    await tester.tap(find.byKey(const ValueKey('appointment-booking-date')));
    await tester.pumpAndSettle();
    final mobileCalendar = tester.widget<VetCalendar>(
      find.descendant(
        of: find.byKey(const ValueKey('mobile-calendar-dialog')),
        matching: find.byType(VetCalendar),
      ),
    );
    expect(mobileCalendar.firstDate, isNotNull);
    expect(mobileCalendar.lastDate, isNull);

    await pumpAt(tester, 1280);
    final desktopLayout = find.byKey(
      const ValueKey('new-appointment-desktop-layout'),
    );
    expect(desktopLayout, findsOneWidget);
    final desktopCalendar = tester.widget<VetCalendar>(
      find.descendant(of: desktopLayout, matching: find.byType(VetCalendar)),
    );
    expect(desktopCalendar.firstDate, isNotNull);
    expect(desktopCalendar.lastDate, isNull);
  });

  testWidgets('setas do calendário navegam e só Confirmar aplica a data', (
    tester,
  ) async {
    await pumpAt(tester, 390);
    final dateControl = find.byKey(const ValueKey('appointment-booking-date'));
    final previous = find.byKey(const ValueKey('date-picker-previous-month'));
    final next = find.byKey(const ValueKey('date-picker-next-month'));
    final calendar = find.byType(VetCalendar);

    await tester.tap(dateControl);
    await tester.pumpAndSettle();
    final initial = tester.widget<VetCalendar>(calendar).selected;
    final firstMonth = tester.widget<VetCalendar>(calendar).month;
    final frame = tester.getRect(find.byKey(const ValueKey('vet-calendar')));
    final inset = tester.getRect(
      find.byKey(const ValueKey('appointment-date-calendar-inset')),
    );
    expect(frame.width, 390);
    expect(inset.topLeft - frame.topLeft, const Offset(22, 28));
    expect(inset.width, 347);
    expect(tester.getSize(next), const Size(48, 48));
    expect(tester.getSize(previous), const Size(48, 48));

    if (DateTime(
      initial.year,
      initial.month,
    ).isAfter(DateTime(DateTime.now().year, DateTime.now().month))) {
      await tester.tap(previous);
      await tester.pumpAndSettle();
    }
    expect(tester.widget<IconButton>(previous).onPressed, isNull);
    final minimum = tester.widget<VetCalendar>(calendar).month;
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(
      tester.widget<VetCalendar>(calendar).month,
      DateTime(minimum.year, minimum.month + 1),
    );
    expect(tester.widget<IconButton>(previous).onPressed, isNotNull);
    await tester.tap(previous);
    await tester.pumpAndSettle();
    expect(tester.widget<VetCalendar>(calendar).month, minimum);

    Future<DateTime> selectNextMonth() async {
      await tester.tap(next);
      await tester.pumpAndSettle();
      final month = tester.widget<VetCalendar>(calendar).month;
      final day = DateTime(month.year, month.month, 17);
      await tester.tap(
        find.byKey(ValueKey('calendar-${day.year}-${day.month}-17-surface')),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<VetCalendar>(calendar).selected, day);
      return day;
    }

    await selectNextMonth();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await tester.tap(dateControl);
    await tester.pumpAndSettle();
    expect(tester.widget<VetCalendar>(calendar).month, firstMonth);
    expect(tester.widget<VetCalendar>(calendar).selected, initial);

    final chosen = await selectNextMonth();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(calendar, findsNothing);
    await tester.tap(dateControl);
    await tester.pumpAndSettle();
    expect(tester.widget<VetCalendar>(calendar).selected, chosen);
  });

  testWidgets(
    'ações da data continuam à vista com a tela baixa e texto a 200%',
    (tester) async {
      await pumpAt(tester, 320, height: 460, textScale: 2);
      final dateControl = find.byKey(
        const ValueKey('appointment-booking-date'),
      );
      await tester.ensureVisible(dateControl);
      await tester.tap(dateControl);
      await tester.pumpAndSettle();

      expect(find.text('Cancelar').hitTestable(), findsOneWidget);
      expect(find.text('Confirmar').hitTestable(), findsOneWidget);
      expect(tester.getRect(find.text('Confirmar')).bottom, lessThan(460));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('campos da consulta mantêm contraste AA sobre o rosa', (
    tester,
  ) async {
    for (final width in [390.0, 1280.0]) {
      await pumpAt(tester, width);

      if (width < VH.desktopBreakpoint) {
        final dateLabel = tester.widget<Text>(
          find.byWidgetPredicate(
            (widget) => widget is Text && widget.data?.contains(' de ') == true,
          ),
        );
        expect(dateLabel.style!.color, VetColors.calendarTextOnRose);
        expect(
          _contrastRatio(dateLabel.style!.color!, VetColors.rose),
          greaterThanOrEqualTo(4.5),
        );
        for (final timeLabel in ['12:00', '13:00']) {
          final timeText = tester.widget<Text>(find.text(timeLabel));
          expect(timeText.style!.color, VetColors.calendarTextOnRose);
          expect(
            _contrastRatio(timeText.style!.color!, VetColors.rose),
            greaterThanOrEqualTo(4.5),
          );
        }
      } else {
        final tileThemes = tester
            .widgetList<ListTileTheme>(find.byType(ListTileTheme))
            .toList();
        expect(tileThemes, isNotEmpty);
        for (final tileTheme in tileThemes) {
          final data = tileTheme.data;
          for (final color in [
            data.textColor!,
            data.titleTextStyle!.color!,
            data.subtitleTextStyle!.color!,
          ]) {
            expect(color, VetColors.calendarTextOnRose);
            expect(
              _contrastRatio(color, VetColors.rose),
              greaterThanOrEqualTo(4.5),
            );
          }
        }
      }

      final descriptionFinder = width < VH.desktopBreakpoint
          ? find.byKey(const ValueKey('appointment-booking-description'))
          : find.byType(TextField);
      final description = tester.widget<TextField>(descriptionFinder);
      final descriptionColor = description.style!.color!;
      final hintColor = description.decoration!.hintStyle!.color!;
      if (width < VH.desktopBreakpoint) {
        expect(description.decoration!.filled, isFalse);
        final descriptionSurface = tester.widget<Container>(
          find.byKey(const ValueKey('appointment-booking-description-surface')),
        );
        expect(
          (descriptionSurface.decoration! as inset_shadow.BoxDecoration).color,
          VetColors.rose,
        );
      }
      for (final color in [descriptionColor, hintColor]) {
        expect(color, VetColors.calendarTextOnRose);
        expect(
          _contrastRatio(color, VetColors.rose),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(tester.takeException(), isNull);
    }
  });
}
