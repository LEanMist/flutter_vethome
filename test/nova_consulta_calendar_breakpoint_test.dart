import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
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

  Future<void> pumpAt(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
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

  testWidgets('calendário segue acessível em mobile e desktop', (tester) async {
    await pumpAt(tester, 390);
    final mobileDateTile = tester.widget<InkWell>(
      find.byKey(const ValueKey('appointment-booking-date')),
    );
    expect(mobileDateTile.onTap, isNotNull);

    await pumpAt(tester, 1280);
    expect(
      find.byKey(const ValueKey('new-appointment-desktop-layout')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('new-appointment-desktop-layout')),
        matching: find.byType(VetCalendar),
      ),
      findsOneWidget,
    );
  });

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
