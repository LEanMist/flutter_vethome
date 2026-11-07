import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/agenda_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/appointment_detail_dialog.dart';

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

  testWidgets(
    'Agenda mobile anuncia dias com consulta real sem marcar a grade',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final pet = VetRepository.pets.first;
        final appointment = Agendamento(
          data: DateTime(2026, 2, 18, 10),
          tipo: 'Consulta real de fevereiro',
          veterinario: 'Dra. Exemplo',
          local: 'Clínica VetHome',
          status: StatusAgendamento.confirmado,
        );
        // Conclui a gravação antes de sair do teste para não deixar uma Future
        // da zona assíncrona de testWidgets pendente no próximo setUp().
        await tester.runAsync(() async {
          VetRepository.addAgendamento(pet.id, appointment);
          expect(await VetRepository.flush(), isTrue);
        });

        await tester.pumpWidget(
          MaterialApp(home: AgendaScreen(initialDate: appointment.data)),
        );
        await tester.pumpAndSettle();

        final date = find.byKey(
          const ValueKey('calendar-date-semantics-2026-2-18'),
        );
        expect(date, findsOneWidget);
        expect(
          tester.getSemantics(date).getSemanticsData().label,
          'quarta-feira, 18 de fevereiro de 2026, possui agendamento',
        );
        final surface = find.byKey(
          const ValueKey('calendar-2026-2-18-surface'),
        );
        expect(surface, findsOneWidget);
        expect(
          find.descendant(of: surface, matching: find.byType(CircleAvatar)),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

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
    final surface = find.byKey(const ValueKey('appointment-detail-surface'));
    expect(tester.getSize(surface), const Size(390, 346));
    final deleteTarget = find.byKey(
      const ValueKey('appointment-detail-delete-target'),
    );
    final deleteVisual = find.byKey(
      const ValueKey('appointment-detail-delete'),
    );
    expect(tester.getSize(deleteTarget), const Size(109, 48));
    final surfaceRect = tester.getRect(surface);
    final deleteVisualRect = tester.getRect(deleteVisual);
    expect(deleteVisualRect.left, closeTo(surfaceRect.left + 140, .01));
    expect(deleteVisualRect.top, closeTo(surfaceRect.top + 283, .01));
    expect(deleteVisualRect.width, closeTo(109, .01));
    expect(deleteVisualRect.height, closeTo(41, .01));
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

    final targetRect = tester.getRect(deleteTarget);
    final visibleRect = tester.getRect(deleteVisual);
    final expandedHitPoint = Offset(targetRect.center.dx, targetRect.top + 1);
    expect(visibleRect.contains(expandedHitPoint), isFalse);
    await tester.tapAt(expandedHitPoint);
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

    tester.view.physicalSize = const Size(320, 640);
    var narrowDeleteTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppointmentDetailDialog(
            pet: pet,
            appointment: appointment,
            onDelete: () => narrowDeleteTapped = true,
          ),
        ),
      ),
    );
    final narrowSurface = tester.getRect(
      find.byKey(const ValueKey('appointment-detail-surface')),
    );
    final narrowTarget = find.byKey(
      const ValueKey('appointment-detail-delete-target'),
    );
    final narrowVisual = find.byKey(
      const ValueKey('appointment-detail-delete'),
    );
    final narrowScale = 320 / 390;
    final narrowTargetRect = tester.getRect(narrowTarget);
    final narrowVisualRect = tester.getRect(narrowVisual);
    expect(narrowTargetRect.height, 48);
    expect(narrowVisualRect.height, closeTo(41 * narrowScale, .01));
    expect(
      narrowVisualRect.left,
      closeTo(narrowSurface.left + 140 * narrowScale, .01),
    );
    expect(
      narrowVisualRect.top,
      closeTo(narrowSurface.top + 283 * narrowScale, .01),
    );
    final narrowHitPoint = Offset(
      narrowTargetRect.center.dx,
      narrowTargetRect.top + 1,
    );
    expect(narrowVisualRect.contains(narrowHitPoint), isFalse);
    await tester.tapAt(narrowHitPoint);
    await tester.pump();
    expect(narrowDeleteTapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
