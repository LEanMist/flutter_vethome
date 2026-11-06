import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/agenda_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';

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

  test('exclusão remove o objeto exato e persiste o estado', () async {
    final pet = VetRepository.pets.first;
    final appointment = Agendamento(
      data: DateTime(2026, 1, 13, 12),
      tipo: 'Consulta de retorno',
      veterinario: 'Dra. Exemplo',
      local: 'Clínica VetHome',
      status: StatusAgendamento.confirmado,
    );
    VetRepository.addAgendamento(pet.id, appointment);
    expect(await VetRepository.flush(), isTrue);

    expect(VetRepository.removeAgendamento(pet.id, appointment), isTrue);
    expect(await VetRepository.flush(), isTrue);
    expect(VetRepository.realAppointments(pet.id), isEmpty);
    expect(storage.snapshot?.appointments[pet.id] ?? [], isEmpty);
    expect(VetRepository.removeAgendamento(pet.id, appointment), isFalse);
  });

  testWidgets('consulta real abre o cartão Figma e pode ser excluída', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pet = VetRepository.pets.first;
    final appointment = Agendamento(
      data: DateTime(2026, 1, 13, 12),
      tipo: 'Consulta de retorno',
      veterinario: 'Dra. Exemplo',
      local: 'Clínica VetHome',
      status: StatusAgendamento.confirmado,
      descricao: 'Acompanhamento do tratamento.',
    );
    VetRepository.addAgendamento(pet.id, appointment);
    await tester.pump();

    await tester.pumpWidget(
      MaterialApp(home: AgendaScreen(initialDate: appointment.data)),
    );
    await tester.pumpAndSettle();

    final appointmentCard = find.byKey(
      ValueKey(
        'agenda-appointment-${appointment.data.microsecondsSinceEpoch}-${appointment.tipo}',
      ),
    );
    expect(appointmentCard, findsOneWidget);
    await tester.tap(appointmentCard);
    await tester.pumpAndSettle();

    final detail = find.byKey(const ValueKey('appointment-detail-dialog'));
    expect(detail, findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('appointment-detail-surface'))),
      const Size(390, 346),
    );
    expect(find.text(pet.name), findsOneWidget);
    expect(
      find.descendant(of: detail, matching: find.text(appointment.tipo)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detail,
        matching: find.textContaining('Acompanhamento do tratamento.'),
      ),
      findsOneWidget,
    );
    final description = tester.widget<Text>(
      find.descendant(
        of: detail,
        matching: find.textContaining('Acompanhamento do tratamento.'),
      ),
    );
    expect(description.style?.color, VetColors.calendarTextOnRose);

    await tester.tap(find.byKey(const ValueKey('appointment-detail-delete')));
    await tester.pumpAndSettle();
    expect(find.text('Excluir consulta?'), findsOneWidget);
    expect(find.textContaining('deste dispositivo?'), findsOneWidget);

    await tester.tap(find.text('Excluir'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(VetRepository.realAppointments(pet.id), isEmpty);
    expect(find.text(appointment.tipo), findsNothing);

    await tester.tap(find.text('Hemograma'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('appointment-detail-dialog')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
