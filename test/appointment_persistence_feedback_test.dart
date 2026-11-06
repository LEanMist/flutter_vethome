import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/screens/outros.dart';

class _BlockedAppointmentStorage extends LocalStorage {
  _BlockedAppointmentStorage(this.result);

  final LocalLoadResult result;
  int saveCalls = 0;

  @override
  Future<LocalLoadResult> load() async => result;

  @override
  Future<void> save(LocalState state) async {
    saveCalls++;
  }
}

class _DelayedStorage extends LocalStorage {
  late Completer<void> write;
  int saveCalls = 0;

  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) {
    saveCalls++;
    return (write = Completer<void>()).future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = _DelayedStorage();
  setUp(() => VetRepository.initialize(storage: storage));

  testWidgets('aviso aparece antes da confirmação e é legível pelo leitor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pet = VetRepository.pets.first;
    await tester.pumpWidget(
      MaterialApp(
        home: NovaConsultaPage(
          pet: pet,
          service: 'Consulta teste',
          plan: 'Particular',
        ),
      ),
    );
    await tester.pumpAndSettle();

    const notice =
        'Demonstração local: esta consulta é salva apenas neste dispositivo '
        'e não é enviada à veterinária.';
    final semantics = tester.widget<Semantics>(
      find.byKey(const ValueKey('appointment-locality-notice')),
    );
    expect(semantics.properties.label, notice);
    expect(semantics.container, isTrue);
    expect(find.text(notice), findsOneWidget);
    final button = find.byKey(const ValueKey('appointment-booking-save'));
    expect(
      tester.getTopLeft(find.text(notice)).dy,
      lessThan(tester.getTopLeft(button).dy),
    );

    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(
        find.byKey(const ValueKey('appointment-locality-notice')),
      ),
      matchesSemantics(label: notice),
    );
    handle.dispose();
    expect(tester.takeException(), isNull);
  });

  for (final result in [
    const LocalLoadResult.invalid(FormatException('snapshot inválido')),
    LocalLoadResult.unavailable(StateError('armazenamento indisponível')),
  ]) {
    testWidgets(
      'consulta bloqueada antes da alteração: ${result.status.name}',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final blocked = _BlockedAppointmentStorage(result);
        await tester.runAsync(() => VetRepository.initialize(storage: blocked));
        final pet = VetRepository.pets.first;
        final before = VetRepository.realAppointments(pet.id).length;

        await tester.pumpWidget(
          MaterialApp(
            home: NovaConsultaPage(
              pet: pet,
              service: 'Consulta teste',
              plan: 'Particular',
            ),
            routes: {
              '/agenda': (_) => const Scaffold(body: Text('Agenda aberta')),
            },
          ),
        );
        await tester.pumpAndSettle();
        final notice = find.byKey(
          const ValueKey('appointment-locality-notice'),
        );
        expect(notice, findsOneWidget);
        expect(
          tester.widget<Semantics>(notice).properties.label,
          contains('não é enviada à veterinária'),
        );
        await tester.tap(
          find.byKey(const ValueKey('appointment-booking-save')),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Armazenamento local bloqueado. Nenhuma consulta foi criada.',
          ),
          findsOneWidget,
        );
        expect(VetRepository.realAppointments(pet.id), hasLength(before));
        expect(blocked.saveCalls, 0);
        expect(find.text('Agenda aberta'), findsNothing);
        expect(find.text('Salvar'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('consulta aguarda a gravação e a Agenda avisa se ela falhar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pet = VetRepository.pets.first;
    final before = VetRepository.agendamentos(pet.id).length;
    const service = 'Consulta teste';
    DateTime? agendaDate;
    await tester.pumpWidget(
      MaterialApp(
        home: NovaConsultaPage(pet: pet, service: service, plan: 'Particular'),
        routes: {
          '/agenda': (context) {
            agendaDate = ModalRoute.of(context)!.settings.arguments as DateTime;
            return AgendaScreen(initialDate: agendaDate);
          },
        },
      ),
    );

    const notice =
        'Demonstração local: esta consulta é salva apenas neste dispositivo '
        'e não é enviada à veterinária.';
    final noticeFinder = find.byKey(
      const ValueKey('appointment-locality-notice'),
    );
    expect(noticeFinder, findsOneWidget);
    expect(find.text(notice), findsOneWidget);
    expect(tester.widget<Semantics>(noticeFinder).properties.label, notice);

    final confirm = find.byKey(const ValueKey('appointment-booking-save'));
    expect(
      tester.getTopLeft(noticeFinder).dy,
      lessThan(tester.getTopLeft(confirm).dy),
    );
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.byType(AgendaScreen), findsNothing);
    expect(storage.saveCalls, 1);
    final saving = find.widgetWithText(ElevatedButton, 'Salvando…');
    expect(tester.widget<ElevatedButton>(saving).onPressed, isNull);
    final appointments = VetRepository.agendamentos(pet.id);
    expect(appointments, hasLength(before + 1));
    final appointment = appointments.singleWhere(
      (item) => item.tipo == service,
    );

    storage.write.completeError(StateError('falha simulada de gravação'));
    await tester.runAsync(() async {
      expect(await VetRepository.flush(), isFalse);
    });
    await tester.pumpAndSettle();

    expect(find.byType(AgendaScreen), findsOneWidget);
    expect(agendaDate, appointment.data);
    expect(find.text(service), findsWidgets);
    expect(
      find.text(
        'Consulta criada nesta sessão. Não foi possível salvar localmente.',
      ),
      findsOneWidget,
    );
    expect(storage.saveCalls, 1);
    expect(tester.takeException(), isNull);
  });
}
