import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/widgets/vet_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      final dateTile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Data'),
      );
      expect(dateTile.onTap, isNotNull);
      dateTile.onTap!();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('mobile-calendar-dialog')),
        findsOneWidget,
      );
    });
  }

  testWidgets('calendário segue acessível em mobile e desktop', (tester) async {
    await pumpAt(tester, 390);
    final mobileDateTile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Data'),
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
}
