import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/widgets/appointment_detail_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final pet = VetRepository.pets.first;

  Agendamento buildAppointment(String description) => Agendamento(
    data: DateTime(2026, 12, 12, 10),
    tipo: 'Consulta de retorno',
    veterinario: 'Dra. Exemplo',
    local: 'Clínica VetHome',
    status: StatusAgendamento.confirmado,
    descricao: description,
  );

  Future<void> showDetail(
    WidgetTester tester, {
    required Size size,
    required String description,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppointmentDetailDialog(
              pet: pet,
              appointment: buildAppointment(description),
              onDelete: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('observação curta mantém o cartão Figma sem ação extra', (
    tester,
  ) async {
    await showDetail(tester, size: const Size(390, 844), description: 'OK');

    expect(
      tester.getSize(find.byKey(const ValueKey('appointment-detail-surface'))),
      const Size(390, 346),
    );
    final textRegion = find.byKey(
      const ValueKey('appointment-detail-text-region'),
    );
    final positionedTextRegion = tester.widget<Positioned>(textRegion);
    expect(positionedTextRegion.left, 13);
    expect(positionedTextRegion.top, 54);
    expect(positionedTextRegion.width, 140);
    expect(positionedTextRegion.height, 111);
    expect(
      find.byKey(const ValueKey('appointment-detail-read-more-target')),
      findsNothing,
    );
    expect(find.textContaining('Observação: OK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('observação truncada abre leitura completa acessível e rolável', (
    tester,
  ) async {
    const marker = 'Marcador final: observar apetite e hidratação.';
    final description =
        '${List.filled(7, 'Informação clínica importante para acompanhar a evolução').join(' ')} $marker';
    expect(description.length, lessThanOrEqualTo(500));

    await showDetail(
      tester,
      size: const Size(320, 480),
      description: description,
    );

    final surface = find.byKey(const ValueKey('appointment-detail-surface'));
    expect(tester.getSize(surface), Size(320, 346 * (320 / 390)));

    final target = find.byKey(
      const ValueKey('appointment-detail-read-more-target'),
    );
    expect(target, findsOneWidget);
    expect(tester.getSize(target), const Size(140 * (320 / 390), 48));

    final semantics = tester.widget<Semantics>(
      find.descendant(of: target, matching: find.byType(Semantics)).first,
    );
    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.label, 'Ler observação completa');
    expect(semantics.properties.onTap, isNotNull);

    await tester.tap(target);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('appointment-full-details-dialog')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            (widget.data?.contains(marker) ?? false),
      ),
      findsOneWidget,
    );
    final scroll = find.byKey(
      const ValueKey('appointment-full-details-scroll'),
    );
    final scrollable = tester.state<ScrollableState>(
      find.descendant(of: scroll, matching: find.byType(Scrollable)).first,
    );
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('appointment-full-details-dialog')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
