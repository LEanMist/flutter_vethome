import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/widgets/appointment_detail_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'Comfortaa',
    )..addFont(rootBundle.load('assets/fonts/ComfortaaBold.ttf'))).load();
    await (FontLoader('MontserratAlternates')..addFont(
          rootBundle.load('assets/fonts/MontserratAlternatesMedium.ttf'),
        ))
        .load();
  });

  final pet = VetRepository.pets.first;

  Agendamento buildAppointment(String description, String service) =>
      Agendamento(
        data: DateTime(2026, 12, 12, 10),
        tipo: service,
        veterinario: 'Dra. Exemplo',
        local: 'Clínica VetHome',
        status: StatusAgendamento.confirmado,
        descricao: description,
      );

  Future<void> showDetail(
    WidgetTester tester, {
    required Size size,
    required String description,
    String service = 'Consulta de retorno',
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            child: AppointmentDetailDialog(
              pet: pet,
              appointment: buildAppointment(description, service),
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
      const Size(390, 381),
    );
    final textRegion = find.byKey(
      const ValueKey('appointment-detail-text-region'),
    );
    final positionedTextRegion = tester.widget<Positioned>(textRegion);
    expect(positionedTextRegion.left, 13);
    expect(positionedTextRegion.top, 74);
    expect(positionedTextRegion.width, 140);
    expect(positionedTextRegion.height, 110);
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
    expect(tester.getSize(surface).width, 320);
    expect(tester.getSize(surface).height, greaterThan(381 * (320 / 390)));

    final target = find.byKey(
      const ValueKey('appointment-detail-read-more-target'),
    );
    expect(target, findsOneWidget);
    expect(tester.getSize(target), const Size(140 * (320 / 390), 48));
    expect(
      tester.widget<Text>(find.text('Ler observação')).style?.fontSize,
      12,
    );
    expect(
      tester.widget<Text>(find.textContaining('Veterinário:')).style?.fontSize,
      12,
    );

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

  testWidgets(
    'título com vários serviços pode ser lido inteiro em tela estreita',
    (tester) async {
      const service =
          'Hemograma + Coproparasitológico + Fosfatase alcalina + Gripe oral ou intranasal';
      await showDetail(
        tester,
        size: const Size(240, 480),
        service: service,
        description: '',
      );
      final surface = find.byKey(const ValueKey('appointment-detail-surface'));
      expect(tester.getSize(surface).width, 240);
      final details = find.byKey(
        const ValueKey('appointment-detail-read-more-target'),
      );
      expect(tester.getSize(details).height, 48);
      final delete = find.byKey(
        const ValueKey('appointment-detail-delete-target'),
      );
      expect(tester.getRect(details).overlaps(tester.getRect(delete)), isFalse);
      await tester.tap(details);
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SelectableText &&
              (widget.data?.startsWith('Serviço: $service\n') ?? false),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('acesso à leitura e exclusão cabe com texto a 200%', (
    tester,
  ) async {
    await showDetail(
      tester,
      size: const Size(320, 480),
      description: 'Observação longa que precisa ser fácil de consultar.',
      textScale: 2,
    );
    final read = find.byKey(
      const ValueKey('appointment-detail-read-more-target'),
    );
    final delete = find.byKey(
      const ValueKey('appointment-detail-delete-target'),
    );
    expect(read.hitTestable(), findsOneWidget);
    expect(delete.hitTestable(), findsOneWidget);
    expect(tester.getRect(read).overlaps(tester.getRect(delete)), isFalse);
    expect(tester.takeException(), isNull);
  });
}
