import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/agendamentos_page.dart';

class _MemoryStorage extends LocalStorage {
  LocalState? snapshot;

  @override
  Future<LocalLoadResult> load() async => snapshot == null
      ? const LocalLoadResult.empty()
      : LocalLoadResult.valid(snapshot!);

  @override
  Future<void> save(LocalState state) async {
    snapshot = state;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _MemoryStorage storage;

  setUp(() async {
    storage = _MemoryStorage();
    await VetRepository.initialize(storage: storage);
  });

  String cardKey(Agendamento appointment) =>
      'appointment-card-${appointment.data.microsecondsSinceEpoch}-${appointment.tipo}';

  Agendamento appointment(String type, DateTime date) => Agendamento(
    data: date,
    tipo: type,
    veterinario: 'Dra. Teste',
    local: 'Clínica VetHome',
    status: StatusAgendamento.confirmado,
  );

  Future<void> saveAppointment(
    WidgetTester tester,
    String petId,
    Agendamento appointment,
  ) async {
    await tester.runAsync(() async {
      VetRepository.addAgendamento(petId, appointment);
      expect(await VetRepository.flush(), isTrue);
    });
  }

  testWidgets('separa próximos agendamentos do histórico e evita duplicidade', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pet = VetRepository.pets.first;
    final now = DateTime.now();
    final nearest = appointment(
      'Consulta real mais próxima',
      now.add(const Duration(days: 2)),
    );
    final later = appointment(
      'Consulta real posterior',
      now.add(const Duration(days: 12)),
    );
    final past = appointment(
      'Consulta real anterior',
      now.subtract(const Duration(days: 3)),
    );
    for (final event in [nearest, later, past]) {
      await saveAppointment(tester, pet.id, event);
    }

    await tester.pumpWidget(MaterialApp(home: AgendamentosPage(pet: pet)));
    await tester.pumpAndSettle();

    final upcoming = find.byKey(const ValueKey('appointments-upcoming-list'));
    final history = find.byKey(const ValueKey('appointments-history-list'));
    expect(find.text('Outros agendamentos futuros'), findsOneWidget);
    expect(find.text('Histórico de agendamentos'), findsOneWidget);
    expect(upcoming, findsOneWidget);
    expect(history, findsOneWidget);
    expect(
      find.descendant(of: upcoming, matching: find.text(later.tipo)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: upcoming, matching: find.text(nearest.tipo)),
      findsNothing,
      reason:
          'o próximo agendamento deve aparecer apenas no cartão em destaque',
    );
    expect(find.text(nearest.tipo), findsOneWidget);
    expect(
      find.descendant(of: history, matching: find.text(past.tipo)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: history, matching: find.text(nearest.tipo)),
      findsNothing,
    );
    expect(find.byKey(ValueKey(cardKey(nearest))), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cartões reais abrem detalhes e oferecem exclusão confirmável', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pet = VetRepository.pets.first;
    final nearest = appointment(
      'Consulta real mais próxima',
      DateTime.now().add(const Duration(days: 2)),
    );
    final event = appointment(
      'Consulta real acessível',
      DateTime.now().add(const Duration(days: 4)),
    );
    await saveAppointment(tester, pet.id, nearest);
    await saveAppointment(tester, pet.id, event);

    await tester.pumpWidget(MaterialApp(home: AgendamentosPage(pet: pet)));
    await tester.pumpAndSettle();

    final card = find.byKey(ValueKey(cardKey(event)));
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('appointment-detail-dialog')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('appointment-detail-delete-target')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Excluir consulta?'), findsOneWidget);
    expect(VetRepository.realAppointments(pet.id), contains(event));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('appointment-detail-dialog')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'cartões de demonstração não abrem detalhes nem permitem excluir',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final pet = VetRepository.pets.first;
      await tester.pumpWidget(MaterialApp(home: AgendamentosPage(pet: pet)));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum agendamento futuro'), findsNothing);
      final upcoming = find.byKey(const ValueKey('appointments-upcoming-list'));
      final demo = find.descendant(
        of: upcoming,
        matching: find.text('Vacinação'),
      );
      expect(demo, findsOneWidget);
      await tester.tap(demo);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('appointment-detail-dialog')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
