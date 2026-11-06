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
          service: 'Hemograma + V10',
          plan: 'Particular',
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('cartão compacto corresponde à dimensão de referência no 390', (
    tester,
  ) async {
    await pumpAt(tester, 390);

    expect(
      tester.getSize(
        find.byKey(const ValueKey('appointment-booking-scaled-size')),
      ),
      const Size(390, 461),
    );
    expect(find.text('Hemograma + V10'), findsOneWidget);
    expect(find.text('Particular'), findsOneWidget);
    expect(find.text(VetRepository.pets.first.name), findsOneWidget);
    expect(
      find.byKey(const ValueKey('appointment-booking-description')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('appointment-booking-save')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('cartão reduz na largura de 320 sem overflow', (tester) async {
    await pumpAt(tester, 320);

    final size = tester.getSize(
      find.byKey(const ValueKey('appointment-booking-scaled-size')),
    );
    expect(size.width, 320);
    expect(size.height, closeTo(461 * 320 / 390, .01));
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('appointment-booking-description')),
      'Retorno de exame',
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('appointment-booking-description')),
          )
          .controller!
          .text,
      'Retorno de exame',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('data e horários preservam os seletores existentes', (
    tester,
  ) async {
    await pumpAt(tester, 390);

    await tester.tap(find.byKey(const ValueKey('appointment-booking-date')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('mobile-calendar-dialog')),
      findsOneWidget,
    );
    expect(find.byType(VetCalendar), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('appointment-booking-start-time')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('time-choice-panel')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
