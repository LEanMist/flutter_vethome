import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/cliente/consulta/agenda_page.dart';
import 'package:flutter_vethome/pages/cliente/consulta/nova_consulta_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const home = SavedAddress(
    id: 'casa',
    name: 'Casa',
    street: 'Rua de Teste',
    number: '12',
    city: 'São Paulo',
  );
  const work = SavedAddress(
    id: 'trabalho',
    name: 'Trabalho',
    street: 'Rua do Escritório',
    number: '101',
    complement: 'Sala 16',
    city: 'São Paulo',
  );

  const address = ValueKey('appointment-booking-address');
  const panel = ValueKey('appointment-address-dialog');
  Finder option(SavedAddress address) =>
      find.byKey(ValueKey('appointment-address-option-${address.id}'));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  Future<void> pumpBooking(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pet = VetRepository.pets.first;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: NovaConsultaPage(
          pet: pet,
          service: 'Consulta',
          plan: 'Particular',
        ),
        routes: {
          '/agenda': (context) => AgendaScreen(
            initialDate: ModalRoute.of(context)!.settings.arguments as DateTime,
          ),
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openPanel(WidgetTester tester) async {
    final button = find.byKey(address);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byKey(panel), findsOneWidget);
  }

  Future<void> seedAddresses(
    WidgetTester tester,
    Iterable<SavedAddress> addresses,
  ) => tester.runAsync(() async {
    for (final address in addresses) {
      VetRepository.saveAddress(address);
    }
    expect(await VetRepository.flush(), isTrue);
  });

  testWidgets('confirma um endereço, cancela trocas e reabre com a seleção', (
    tester,
  ) async {
    await seedAddresses(tester, [home, work]);
    await pumpBooking(tester);
    await openPanel(tester);

    expect(tester.getSize(find.byKey(panel)), const Size(390, 446));
    final ok = find.widgetWithText(ElevatedButton, 'OK');
    expect(tester.widget<ElevatedButton>(ok).onPressed, isNull);
    await tester.tap(option(home));
    await tester.tap(option(work));
    await tester.pumpAndSettle();
    expect(tester.widget<Semantics>(option(home)).properties.checked, isFalse);
    expect(tester.widget<Semantics>(option(work)).properties.checked, isTrue);
    await tester.tap(ok);
    await tester.pumpAndSettle();
    expect(find.text(work.summary), findsOneWidget);

    await openPanel(tester);
    expect(tester.widget<Semantics>(option(work)).properties.checked, isTrue);
    await tester.tap(option(home));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(panel), findsNothing);
    expect(find.text(work.summary), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite retirar o endereço sem perder o restante da consulta', (
    tester,
  ) async {
    await seedAddresses(tester, [home]);
    final petId = VetRepository.pets.first.id;
    await pumpBooking(tester);
    await openPanel(tester);
    await tester.tap(option(home));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await openPanel(tester);
    await tester.tap(find.text('Remover seleção'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text(home.summary), findsOneWidget);

    await openPanel(tester);
    await tester.tap(find.text('Remover seleção'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Escolher endereço'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const ValueKey('appointment-booking-save')));
      expect(await VetRepository.flush(), isTrue);
    });
    await tester.pumpAndSettle();
    final saved = VetRepository.realAppointments(petId).single;
    expect(saved.address, isNull);
    expect(saved.tipo, 'Consulta');
    expect(VetRepository.addresses.single.id, home.id);
  });

  testWidgets('salva o endereço e abre a Agenda com os dados da consulta', (
    tester,
  ) async {
    await seedAddresses(tester, [home]);
    final pet = VetRepository.pets.first;
    await pumpBooking(tester);
    await openPanel(tester);
    await tester.tap(option(home));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const ValueKey('appointment-booking-save')));
      expect(await VetRepository.flush(), isTrue);
    });
    await tester.pumpAndSettle();
    expect(find.byType(AgendaScreen), findsOneWidget);
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp(home.summary)), findsWidgets);
    semantics.dispose();

    await tester.runAsync(() async {
      VetRepository.removeAddress(home.id);
      await VetRepository.flush();
      await VetRepository.initialize();
    });
    expect(VetRepository.addresses, isEmpty);
    final stored = VetRepository.realAppointments(pet.id).single;
    expect(stored.address?.id, home.id);
    expect(stored.locationLabel, home.summary);
    expect(stored.local, 'VetHome · Particular');
  });

  testWidgets('mostra orientação quando não há endereços cadastrados', (
    tester,
  ) async {
    await pumpBooking(tester);
    await openPanel(tester);
    expect(find.textContaining('Nenhum endereço cadastrado'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Escolher endereço'), findsOneWidget);
  });

  testWidgets('permite rolar a lista a 320 × 640 com texto a 200%', (
    tester,
  ) async {
    await seedAddresses(tester, [
      for (var index = 0; index < 5; index++)
        SavedAddress(
          id: 'endereco-$index',
          name: 'Endereço alternativo $index',
          street: 'Alameda de Exemplo',
          number: '150',
          complement: 'Apartamento 340, bloco da entrada principal',
          city: 'São Paulo',
        ),
      work,
    ]);
    await pumpBooking(tester, size: const Size(320, 640), textScale: 2);
    await openPanel(tester);
    final list = find.descendant(
      of: find.byKey(panel),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(option(work), 200, scrollable: list);
    await Scrollable.ensureVisible(tester.element(option(work)), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(option(work));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text(work.summary), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
