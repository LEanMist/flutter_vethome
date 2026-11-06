import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/screens/pets.dart'
    show ConvenioScreen, ServicosScreen;

class _MemoryStorage extends LocalStorage {
  int writes = 0;
  LocalState? snapshot;

  @override
  Future<LocalLoadResult> load() async => snapshot == null
      ? const LocalLoadResult.empty()
      : LocalLoadResult.valid(snapshot!);

  @override
  Future<void> save(LocalState state) async {
    writes++;
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

  Future<void> openServices(
    WidgetTester tester, {
    bool realAppointment = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousPet = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previousPet);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(
      MaterialApp(
        home: const ServicosScreen(),
        routes: {
          '/convenio': (_) => const ConvenioScreen(),
          '/nova-consulta': (context) {
            final args = ModalRoute.of(context)!.settings.arguments! as Map;
            return realAppointment
                ? NovaConsultaPage(
                    pet: VetRepository.petById(args['petId'] as String)!,
                    service: args['service'] as String,
                    plan: args['plan'] as String,
                  )
                : Scaffold(
                    body: Text(
                      'Recebido: ${args['service']} / ${args['plan']}',
                    ),
                  );
          },
          '/agenda': (_) => const Scaffold(body: Text('Agenda de teste')),
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder selectionMarker(String name) {
    final row = find
        .ancestor(of: find.text(name), matching: find.byType(Row))
        .first;
    return find
        .descendant(
          of: row,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.constraints?.minWidth == 15 &&
                widget.constraints?.minHeight == 15 &&
                widget.decoration is BoxDecoration,
          ),
        )
        .first;
  }

  Future<void> selectService(WidgetTester tester, String service) async {
    await tester.ensureVisible(find.text(service));
    await tester.pumpAndSettle();
    await tester.tap(find.text(service));
    await tester.pumpAndSettle();
  }

  testWidgets('caixas alternam sem navegar e um serviço segue compatível', (
    tester,
  ) async {
    await openServices(tester);

    final continueButton = find.byKey(const ValueKey('services-continue'));
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNull);
    expect(find.text('Hemograma'), findsOneWidget);
    expect(find.text('V10'), findsOneWidget);

    await selectService(tester, 'Hemograma');
    expect(find.byType(ConvenioScreen), findsNothing);
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNotNull);
    final selected = tester.widget<Container>(selectionMarker('Hemograma'));
    expect(
      (selected.decoration! as BoxDecoration).color,
      isNot(Colors.transparent),
    );

    await selectService(tester, 'Hemograma');
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNull);
    final unselected = tester.widget<Container>(selectionMarker('Hemograma'));
    expect((unselected.decoration! as BoxDecoration).color, Colors.transparent);

    await selectService(tester, 'Hemograma');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.byType(ConvenioScreen), findsOneWidget);
    await tester.ensureVisible(find.text('Particular'));
    await tester.tap(find.text('Particular'));
    await tester.pumpAndSettle();
    expect(find.text('Recebido: Hemograma / Particular'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dois serviços chegam ao agendamento e geram um registro', (
    tester,
  ) async {
    await openServices(tester, realAppointment: true);
    final pet = VetRepository.selectedPet!;
    final before = VetRepository.realAppointments(pet.id).length;

    await selectService(tester, 'Hemograma');
    await selectService(tester, 'V10');
    expect(find.byType(ConvenioScreen), findsNothing);
    final v10 = tester.widget<Container>(selectionMarker('V10'));
    expect((v10.decoration! as BoxDecoration).color, isNot(Colors.transparent));

    final button = find.byKey(const ValueKey('services-continue'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(ConvenioScreen), findsOneWidget);

    await tester.ensureVisible(find.text('PetLove'));
    await tester.tap(find.text('PetLove'));
    await tester.pumpAndSettle();
    expect(find.byType(NovaConsultaPage), findsOneWidget);
    expect(find.text('Serviço: Hemograma + V10'), findsOneWidget);
    expect(find.text('Convênio: PetLove'), findsOneWidget);

    final confirm = find.widgetWithText(
      ElevatedButton,
      'Confirmar agendamento',
    );
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    final stored = VetRepository.realAppointments(pet.id);
    expect(stored, hasLength(before + 1));
    expect(stored.last.tipo, 'Hemograma + V10');
    expect(stored.last.local, 'VetHome · PetLove');
    expect(find.text('Agenda de teste'), findsOneWidget);
    expect(storage.writes, greaterThanOrEqualTo(1));
    expect(
      storage.snapshot?.appointments[pet.id]?.single.tipo,
      'Hemograma + V10',
    );

    // Simula reinício: o agendamento deve vir do snapshot, não só da sessão.
    await tester.runAsync(() => VetRepository.initialize(storage: storage));
    final restored = VetRepository.realAppointments(pet.id);
    expect(restored, hasLength(before + 1));
    expect(restored.single.tipo, 'Hemograma + V10');
    expect(tester.takeException(), isNull);
  });
}
