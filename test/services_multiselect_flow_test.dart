import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/screens/pets.dart'
    show ConvenioScreen, ServicosScreen;
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

double _contrastRatio(Color first, Color second) {
  final luminances = [first.computeLuminance(), second.computeLuminance()]
    ..sort((a, b) => b.compareTo(a));
  return (luminances.first + 0.05) / (luminances.last + 0.05);
}

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

  test(
    'marcador selecionado mantém contraste gráfico de pelo menos 3:1',
    () async {
      const selectedAsset =
          'assets/imagens/figma/services-checkbox-selected.svg';
      final svg = await rootBundle.loadString(selectedAsset);
      final fill = RegExp(
        r'<path[^>]*fill="#68442E"[^>]*fill-opacity="([0-9.]+)"',
      ).firstMatch(svg);

      expect(fill, isNotNull, reason: 'O marcador deve manter a cor definida.');
      final opacity = double.parse(fill!.group(1)!);
      const surface = Color(0xFFECBEC0);
      final visibleFill = Color.alphaBlend(
        const Color(0xFF68442E).withValues(alpha: opacity),
        surface,
      );

      expect(
        _contrastRatio(visibleFill, surface),
        greaterThanOrEqualTo(3),
        reason: 'O preenchimento precisa se distinguir do fundo das opções.',
      );
    },
  );

  Future<void> openServices(
    WidgetTester tester, {
    bool realAppointment = false,
    Size size = const Size(390, 844),
    double? textScale,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousPet = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previousPet);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(
      MaterialApp(
        builder: textScale == null
            ? null
            : (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!,
              ),
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

  Finder selectionMarker(String name) =>
      find.byKey(ValueKey('services-checkbox-$name'));

  String markerAsset(WidgetTester tester, String name) =>
      (tester.widget<SvgPicture>(selectionMarker(name)).bytesLoader
              as SvgAssetLoader)
          .assetName;

  String categoryMarkerAsset(WidgetTester tester, String name) =>
      (tester
                  .widget<SvgPicture>(
                    find.byKey(ValueKey('services-category-checkbox-$name')),
                  )
                  .bytesLoader
              as SvgAssetLoader)
          .assetName;

  String categoryChevronAsset(WidgetTester tester, String name) =>
      (tester
                  .widget<Image>(
                    find.byKey(ValueKey('services-category-chevron-$name')),
                  )
                  .image
              as AssetImage)
          .assetName;

  String categoryArrowAsset(WidgetTester tester, String name) =>
      (tester
                  .widget<SvgPicture>(
                    find.byKey(ValueKey('services-category-arrow-$name')),
                  )
                  .bytesLoader
              as SvgAssetLoader)
          .assetName;

  int categoryArrowRotation(WidgetTester tester, String name) => tester
      .widget<RotatedBox>(
        find.byKey(ValueKey('services-category-arrow-rotation-$name')),
      )
      .quarterTurns;

  Future<void> selectService(WidgetTester tester, String service) async {
    const serviceCategories = {
      'Hemograma': 'Exames',
      'Creatinina': 'Exames',
      'Urina': 'Exames',
      'V8': 'Vacinas',
      'V10': 'Vacinas',
      'Antirrábica': 'Vacinas',
    };
    final category = serviceCategories[service]!;
    if (find.text(service).evaluate().isEmpty) {
      await tester.tap(find.byKey(ValueKey('services-pill-$category')));
      await tester.pumpAndSettle();
    }
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
    expect(
      markerAsset(tester, 'Hemograma'),
      'assets/imagens/figma/services-checkbox-selected.svg',
    );

    await selectService(tester, 'Hemograma');
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNull);
    expect(
      markerAsset(tester, 'Hemograma'),
      'assets/imagens/figma/services-checkbox-unselected.svg',
    );

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

  testWidgets('opções expõem o estado de checkbox para acessibilidade', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await openServices(tester);

      final service = find.text('Hemograma');
      var node = tester.getSemantics(service);
      var data = node.getSemanticsData();
      expect(data.flagsCollection.isChecked, CheckedState.isFalse);
      expect(data.label, 'Hemograma');
      expect(data.hasAction(SemanticsAction.tap), isTrue);

      await selectService(tester, 'Hemograma');
      node = tester.getSemantics(service);
      data = node.getSemanticsData();
      expect(data.flagsCollection.isChecked, CheckedState.isTrue);
      expect(data.label, 'Hemograma');
      expect(data.hasAction(SemanticsAction.tap), isTrue);

      await selectService(tester, 'Hemograma');
      node = tester.getSemantics(service);
      data = node.getSemanticsData();
      expect(data.flagsCollection.isChecked, CheckedState.isFalse);
      expect(data.label, 'Hemograma');
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('cada categoria tem uma ação acessível e um ponto de foco', (
    tester,
  ) async {
    await openServices(tester, size: const Size(1280, 800));

    final semantics = tester.ensureSemantics();
    try {
      for (final category in ['Microchipagem', 'Atestados']) {
        final categorySemantics = find.byKey(
          ValueKey('services-category-semantics-$category'),
        );
        final data = tester.getSemantics(categorySemantics).getSemanticsData();
        expect(data.label, category);
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.hasAction(SemanticsAction.tap), isTrue);

        final arrow = find.byKey(ValueKey('services-category-arrow-$category'));
        expect(arrow, findsOneWidget);
        expect(
          find.ancestor(of: arrow, matching: find.byType(ExcludeFocus)),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('setas começam no Figma e refletem a interação', (tester) async {
    await openServices(tester);

    const down = 'assets/imagens/figma/services-chevron-down.svg';
    const right = 'assets/imagens/figma/services-chevron-right.svg';
    expect(categoryArrowAsset(tester, 'Exames'), down);
    expect(categoryArrowAsset(tester, 'Vacinas'), right);
    expect(categoryArrowRotation(tester, 'Exames'), 1);
    expect(categoryArrowRotation(tester, 'Vacinas'), 0);

    await tester.tap(find.byKey(const ValueKey('services-pill-Exames')));
    await tester.pumpAndSettle();
    expect(categoryArrowAsset(tester, 'Exames'), down);
    expect(categoryArrowRotation(tester, 'Exames'), 0);
    await tester.tap(find.byKey(const ValueKey('services-pill-Exames')));
    await tester.pumpAndSettle();
    expect(categoryArrowAsset(tester, 'Exames'), down);
    expect(categoryArrowRotation(tester, 'Exames'), 1);

    await tester.tap(find.byKey(const ValueKey('services-pill-Vacinas')));
    await tester.pumpAndSettle();
    expect(categoryArrowAsset(tester, 'Vacinas'), right);
    expect(categoryArrowRotation(tester, 'Vacinas'), 0);
    await tester.tap(find.byKey(const ValueKey('services-pill-Vacinas')));
    await tester.pumpAndSettle();
    expect(categoryArrowAsset(tester, 'Vacinas'), right);
    expect(categoryArrowRotation(tester, 'Vacinas'), 1);

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Serviços inicia como no Figma e deixa Continuar visível em 320x640',
    (tester) async {
      await openServices(tester, size: const Size(320, 640));

      expect(find.text('Hemograma'), findsOneWidget);
      expect(find.text('V8'), findsOneWidget);
      final continueButton = find.byKey(const ValueKey('services-continue'));
      expect(tester.getRect(continueButton).bottom, lessThanOrEqualTo(640));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Serviços fixa Continuar em alturas intermediárias', (
    tester,
  ) async {
    for (final size in [const Size(390, 800), const Size(390, 760)]) {
      await openServices(tester, size: size);

      final continueButton = find.byKey(const ValueKey('services-continue'));
      final navigationTop = tester.getTopLeft(find.byType(VetBottomNav)).dy;
      expect(
        tester.getRect(continueButton).bottom,
        lessThanOrEqualTo(navigationTop),
        reason: 'Continuar deve ficar visível em $size.',
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Serviços fixa Continuar em desktop de altura reduzida', (
    tester,
  ) async {
    await openServices(tester, size: const Size(1280, 720));

    final continueButton = find.byKey(const ValueKey('services-continue'));
    expect(continueButton, findsOneWidget);
    expect(tester.getRect(continueButton).bottom, lessThanOrEqualTo(720));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Serviços desktop baixo mostra as categorias sem rolagem', (
    tester,
  ) async {
    await openServices(tester, size: const Size(1280, 720));

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(
      scrollable.position.maxScrollExtent,
      0,
      reason: 'As categorias de Serviços devem caber antes da navegação.',
    );
    expect(find.text('V8'), findsNothing);
    expect(find.text('Antirrábica'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('services-category-semantics-Vacinas')),
    );
    await tester.pumpAndSettle();

    expect(find.text('V8'), findsOneWidget);
    expect(find.text('Antirrábica'), findsOneWidget);
    expect(find.text('Hemograma'), findsNothing);

    await tester.tap(find.text('V8'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('services-category-semantics-Exames')),
    );
    await tester.pumpAndSettle();

    expect(find.text('V8'), findsNothing);
    expect(
      categoryMarkerAsset(tester, 'Vacinas'),
      'assets/imagens/figma/services-checkbox-selected.svg',
    );
    expect(
      tester
          .widget<Semantics>(
            find.byKey(const ValueKey('services-category-semantics-Vacinas')),
          )
          .properties
          .hint,
      'Selecionados: V8',
    );
    expect(
      scrollable.position.maxScrollExtent,
      0,
      reason: 'Trocar de categoria e preservar seleção não deve rolar.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Serviços desktop mantém os nomes legíveis com texto a 200%', (
    tester,
  ) async {
    await openServices(tester, size: const Size(1280, 720), textScale: 2);

    for (final name in ['Exames', 'Vacinas', 'Microchipagem', 'Atestados']) {
      final label = find.byKey(ValueKey('services-category-label-$name'));
      expect(label, findsOneWidget);
      expect(
        tester
            .widget<Semantics>(
              find.byKey(ValueKey('services-category-semantics-$name')),
            )
            .properties
            .label,
        name,
        reason: '$name deve manter o nome completo para leitores de tela.',
      );
      expect(
        tester.renderObject<RenderParagraph>(label).didExceedMaxLines,
        isFalse,
        reason:
            '$name não deve ser cortado com texto ampliado. Texto: '
            '${tester.widget<Text>(label).data}; linhas: '
            '${tester.widget<Text>(label).maxLines}; '
            'tamanho: ${tester.getSize(label)}.',
      );
    }
    expect(
      tester.getRect(find.byKey(const ValueKey('services-continue'))).bottom,
      lessThanOrEqualTo(720),
      reason: 'Continuar permanece visível com texto ampliado.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('serviços mobile não adiciona seta e ainda pode voltar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(builder: (_) => const ServicosScreen()),
              ),
              child: const Text('Abrir Serviços'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir Serviços'));
    await tester.pumpAndSettle();

    expect(find.byType(ServicosScreen), findsOneWidget);
    expect(find.byTooltip('Voltar'), findsNothing);
    await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
    await tester.pumpAndSettle();
    expect(find.text('Abrir Serviços'), findsOneWidget);
    expect(find.byType(ServicosScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('categorias diretas selecionam sem abrir sublistas no mobile', (
    tester,
  ) async {
    await openServices(tester);

    expect(find.text('Hemograma'), findsOneWidget);
    final continueButton = find.byKey(const ValueKey('services-continue'));
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNull);
    for (final category in ['Microchipagem', 'Atestados']) {
      final marker = find.byKey(
        ValueKey('services-category-checkbox-$category'),
      );
      final arrow = find.byKey(ValueKey('services-category-arrow-$category'));
      expect(
        categoryChevronAsset(tester, category),
        'assets/imagens/figma/convenio-chevron.png',
      );
      expect(marker, findsNothing);
      expect(arrow, findsOneWidget);
      await tester.tap(find.byKey(ValueKey('services-pill-$category')));
      await tester.pumpAndSettle();
      expect(
        categoryMarkerAsset(tester, category),
        'assets/imagens/figma/services-checkbox-selected.svg',
      );
      expect(marker, findsOneWidget);
      expect(
        find.byKey(ValueKey('services-category-chevron-$category')),
        findsNothing,
      );
      expect(
        tester.widget<ElevatedButton>(continueButton).onPressed,
        isNotNull,
      );
      await tester.tap(arrow);
      await tester.pumpAndSettle();
      expect(marker, findsNothing);
      expect(
        categoryChevronAsset(tester, category),
        'assets/imagens/figma/convenio-chevron.png',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('checkboxes de Microchipagem e Atestados são acessíveis', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await openServices(tester);
      for (final category in ['Microchipagem', 'Atestados']) {
        final finder = find.byKey(
          ValueKey('services-category-semantics-$category'),
        );
        var data = tester.getSemantics(finder).getSemanticsData();
        expect(data.label, category);
        expect(data.flagsCollection.isChecked, CheckedState.isFalse);
        expect(data.flagsCollection.isButton, isFalse);
        expect(data.hasAction(SemanticsAction.tap), isTrue);

        await tester.tap(find.byKey(ValueKey('services-pill-$category')));
        await tester.pumpAndSettle();
        data = tester.getSemantics(finder).getSemanticsData();
        expect(data.flagsCollection.isChecked, CheckedState.isTrue);
      }
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('Convênio mantém Particular visível em 320x640', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousPet = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previousPet);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(const MaterialApp(home: ConvenioScreen()));
    await tester.pumpAndSettle();

    final particular = find.byKey(
      const ValueKey('convenio-plan-pill-Particular'),
    );
    final navigationTop = tester.getTopLeft(find.byType(VetBottomNav)).dy;
    expect(
      tester.getRect(particular).bottom,
      lessThanOrEqualTo(navigationTop),
      reason: 'A opção Particular precisa aparecer acima da navegação.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Convênio não trunca os planos com texto ampliado a 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousPet = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previousPet);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const ConvenioScreen(),
      ),
    );
    await tester.pumpAndSettle();

    for (final plan in ['PetLove', 'Doglife', 'Particular']) {
      final label = find.text(plan);
      expect(label, findsOneWidget);
      final textWidget = tester.widget<Text>(label);
      expect(textWidget.data, plan);
      expect(textWidget.maxLines, isNull);
      expect(textWidget.overflow, isNull);
      expect(
        tester.renderObject<RenderParagraph>(label).didExceedMaxLines,
        isFalse,
        reason: '$plan deve continuar legível com texto a 200%.',
      );
    }
    final particular = find.byKey(
      const ValueKey('convenio-plan-pill-Particular'),
    );
    await tester.ensureVisible(particular);
    await tester.pumpAndSettle();
    final navigationTop = tester.getTopLeft(find.byType(VetBottomNav)).dy;
    expect(
      tester.getRect(particular).bottom,
      lessThanOrEqualTo(navigationTop),
      reason:
          'Particular deve permanecer alcançável a 200% sem ficar sob a navegação.',
    );
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
    expect(
      markerAsset(tester, 'V10'),
      'assets/imagens/figma/services-checkbox-selected.svg',
    );

    final button = find.byKey(const ValueKey('services-continue'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(ConvenioScreen), findsOneWidget);

    await tester.ensureVisible(find.text('PetLove'));
    await tester.tap(find.text('PetLove'));
    await tester.pumpAndSettle();
    expect(find.byType(NovaConsultaPage), findsOneWidget);
    expect(find.text('2 serviços selecionados'), findsOneWidget);
    expect(find.text('PetLove'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('appointment-booking-service-details')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Serviços selecionados'), findsOneWidget);
    expect(find.text('Hemograma'), findsOneWidget);
    expect(find.text('V10'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    final confirm = find.byKey(const ValueKey('appointment-booking-save'));
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
