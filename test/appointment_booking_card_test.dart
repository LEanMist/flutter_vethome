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

  Future<void> pumpAt(
    WidgetTester tester,
    double width, {
    String service = 'Hemograma',
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: NovaConsultaPage(
          pet: VetRepository.pets.first,
          service: service,
          plan: 'Particular',
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('cartão de agendamento corresponde à referência no 390', (
    tester,
  ) async {
    await pumpAt(tester, 390);

    expect(
      tester.getSize(
        find.byKey(const ValueKey('appointment-booking-scaled-size')),
      ),
      const Size(390, 461),
    );
    expect(find.text('Hemograma'), findsOneWidget);
    expect(find.text('Particular'), findsOneWidget);
    final card = find.byKey(const ValueKey('appointment-booking-card'));
    expect(find.text(VetRepository.pets.first.name), findsOneWidget);
    final petName = find.byKey(const ValueKey('appointment-booking-pet-name'));
    expect(
      tester.getTopLeft(petName) - tester.getTopLeft(card),
      const Offset(80, 373.5),
    );
    expect(
      tester.getRect(petName).center.dy - tester.getTopLeft(card).dy,
      379.5,
    );
    final petIcon = find.byKey(const ValueKey('appointment-booking-pet-icon'));
    expect(
      tester.getTopLeft(petIcon) - tester.getTopLeft(card),
      const Offset(33, 364.4),
    );
    expect(tester.getSize(petIcon), const Size(28, 27.879));
    expect(
      find.byKey(const ValueKey('appointment-booking-description')),
      findsOneWidget,
    );
    final dateButton = find.byKey(const ValueKey('appointment-booking-date'));
    expect(tester.getSize(dateButton), const Size(222, 48));
    expect(
      find.descendant(
        of: dateButton,
        matching: find.textContaining(RegExp(r'^[A-ZÁÉÍÓÚÂÊÔÃÕ]')),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('appointment-booking-start-time')))
          .height,
      48,
    );
    final servicePill = tester.widget<Container>(
      find.byKey(const ValueKey('appointment-booking-service')),
    );
    expect(
      (servicePill.decoration! as BoxDecoration).borderRadius,
      BorderRadius.circular(15),
    );
    final save = find.byKey(const ValueKey('appointment-booking-save'));
    expect(save, findsOneWidget);
    expect(tester.getSize(save), const Size(105, 48));
    expect(
      tester.getTopLeft(save) - tester.getTopLeft(card),
      const Offset(265, 397),
    );
    final saveVisual = find.byKey(
      const ValueKey('appointment-booking-save-visual'),
    );
    expect(tester.getSize(saveVisual), const Size(105, 37));
    expect(
      tester.getTopLeft(saveVisual) - tester.getTopLeft(card),
      const Offset(265, 408),
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
    final scale = size.width / 390;
    for (final key in [
      const ValueKey('appointment-booking-date'),
      const ValueKey('appointment-booking-start-time'),
      const ValueKey('appointment-booking-end-time'),
      const ValueKey('appointment-booking-save'),
    ]) {
      expect(tester.getRect(find.byKey(key)).height, closeTo(48, .01));
    }
    final dateTarget = tester.getRect(
      find.byKey(const ValueKey('appointment-booking-date')),
    );
    final startTarget = tester.getRect(
      find.byKey(const ValueKey('appointment-booking-start-time')),
    );
    final descriptionLabel = tester.getRect(
      find.text('Adicionar uma descrição'),
    );
    final descriptionRect = tester.getRect(
      find.byKey(const ValueKey('appointment-booking-description')),
    );
    expect(dateTarget.bottom, lessThanOrEqualTo(startTarget.top + .01));
    expect(startTarget.overlaps(descriptionLabel), isFalse);
    expect(startTarget.bottom, lessThan(descriptionRect.top));
    final description = tester.widget<TextField>(
      find.byKey(const ValueKey('appointment-booking-description')),
    );
    expect(description.style!.fontSize! * scale, closeTo(12, .01));
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

  testWidgets('cartão permite consultar todos os serviços selecionados', (
    tester,
  ) async {
    const services = [
      'Hemograma',
      'Creatinina',
      'Urina',
      'V10',
      'Microchipagem',
    ];
    final combined = services.join(' + ');

    for (final width in [390.0, 320.0]) {
      await pumpAt(tester, width, service: combined);
      expect(find.text('5 serviços selecionados'), findsOneWidget);
      final details = find.byKey(
        const ValueKey('appointment-booking-service-details'),
      );
      expect(tester.getRect(details).height, closeTo(48, .01));
      await tester.ensureVisible(details);
      await tester.tap(details);
      await tester.pumpAndSettle();

      expect(find.text('Serviços selecionados'), findsOneWidget);
      for (final name in services) {
        expect(find.text(name), findsOneWidget);
      }
      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
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
