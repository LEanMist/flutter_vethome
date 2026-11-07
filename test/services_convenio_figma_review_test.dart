import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/screens/pets.dart'
    show ServicosScreen, ConvenioScreen;
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/pet_summary.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  testWidgets('Serviços e Convênio: posições e textos no mobile Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final before = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = before);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(const MaterialApp(home: ServicosScreen()));
    await tester.pumpAndSettle();

    // O frame mobile do Figma não mostra a barra inferior do app.
    expect(find.byType(VetBottomNav), findsNothing);
    // SERVICES_PAGE 2791:3113 não apresenta o resumo do pet no mobile.
    expect(find.byType(PetSummary), findsNothing);
    expect(find.text('Serviços'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Serviços'));
    expect(title.style?.fontFamily, 'Comfortaa');
    expect(title.style?.fontSize, 30);
    expect(title.style?.fontWeight, FontWeight.bold);
    expect(title.style?.color, Colors.white);
    for (final label in [
      'Serviços',
      'Exames',
      'Vacinas',
      'Microchipagem',
      'Atestados',
    ]) {
      // ignore: avoid_print
      print('SERVICOS pos $label: ${tester.getTopLeft(find.text(label)).dy}');
    }
    // SERVICES_PAGE 2791:3113, TELA_CLIENTE: posições na escala 1 (390x844).
    for (final expected in const [
      ('Serviços', 37.0),
      ('Exames', 208.0),
      ('Vacinas', 386.0),
      ('Microchipagem', 564.0),
      ('Atestados', 645.0),
    ]) {
      expect(
        tester.getTopLeft(find.text(expected.$1)).dy,
        closeTo(expected.$2, 1),
        reason: 'Desvio do Figma no texto ${expected.$1}',
      );
    }
    final examsPill = tester.widget<Ink>(
      find.ancestor(of: find.text('Exames'), matching: find.byType(Ink)).first,
    );
    final examsGradient =
        (examsPill.decoration! as BoxDecoration).gradient! as LinearGradient;
    final gradientBegin = examsGradient.begin as Alignment;
    final gradientEnd = examsGradient.end as Alignment;
    expect(examsGradient.colors, [VetColors.rose, VetColors.pink]);
    expect(gradientBegin.x, closeTo(-1, 0.01));
    expect(gradientBegin.y, closeTo(-1.07212, 0.01));
    expect(gradientEnd.x, closeTo(1, 0.01));
    expect(gradientEnd.y, closeTo(1.07212, 0.01));
    for (final label in ['Exames', 'Vacinas', 'Microchipagem', 'Atestados']) {
      final category = tester.widget<Text>(find.text(label));
      expect(category.style?.fontFamily, 'MontserratAlternates');
      expect(category.style?.fontSize, 20);
      expect(category.style?.fontWeight, FontWeight.bold);
      expect(category.style?.color, VetColors.brownOnRose);
      final endpointContrasts = [
        _contrastRatio(category.style!.color!, VetColors.rose),
        _contrastRatio(category.style!.color!, VetColors.pink),
      ];
      expect(
        endpointContrasts.reduce((a, b) => a < b ? a : b),
        greaterThanOrEqualTo(3),
        reason: 'Rótulos de categoria devem ter contraste de texto grande.',
      );
    }
    final continueButton = find.byKey(const ValueKey('services-continue'));
    final continueText = tester.widget<Text>(
      find.descendant(of: continueButton, matching: find.text('Continuar')),
    );
    expect(continueText.style?.fontFamily, 'Comfortaa');
    expect(continueText.style?.fontSize, 18);
    expect(continueText.style?.fontWeight, FontWeight.bold);
    expect(
      tester
          .widget<ElevatedButton>(continueButton)
          .style
          ?.foregroundColor
          ?.resolve(<WidgetState>{}),
      Colors.white,
    );
    final continueRect = tester.getRect(continueButton);
    expect(continueRect.topLeft.dx, closeTo(116, 1));
    expect(continueRect.topLeft.dy, closeTo(718, 1));
    expect(continueRect.size, const Size(157, 57));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MaterialApp(home: ConvenioScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(VetBottomNav), findsNothing);
    final selectedPet = VetRepository.pets.first;
    expect(find.byType(PetSummary), findsNothing);
    expect(find.text(selectedPet.name), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label?.startsWith(
                  'Pet selecionado: ${selectedPet.name}, espécie ',
                ) ==
                true,
      ),
      findsOneWidget,
    );
    // Figma CONVENIO_PAGE 2783:840, viewport de 390 × 844.
    // Mantém o fluxo/rotas existentes enquanto alinha a posição dos planos.
    expect(tester.getTopLeft(find.text('Convênio')).dy, closeTo(37, 1));
    expect(tester.getTopLeft(find.text('PetLove')).dy, closeTo(359, 1));
    expect(tester.getTopLeft(find.text('Doglife')).dy, closeTo(479, 2));
    expect(tester.getTopLeft(find.text('Particular')).dy, closeTo(598, 2));
    // CONVENIO_PAGE 2783:840: planos 254 × 59 e títulos
    // Montserrat Alternates Bold, 20 px.
    for (final label in ['PetLove', 'Doglife', 'Particular']) {
      final title = tester.widget<Text>(find.text(label));
      expect(title.style?.fontFamily, 'MontserratAlternates');
      expect(title.style?.fontSize, 20);
      expect(title.style?.fontWeight, FontWeight.bold);
      expect(title.style?.color, VetColors.brownOnRose);
      final gradientContrasts = [
        _contrastRatio(title.style!.color!, VetColors.rose),
        _contrastRatio(title.style!.color!, VetColors.pink),
      ];
      expect(
        gradientContrasts.reduce((a, b) => a < b ? a : b),
        greaterThanOrEqualTo(3),
        reason: 'Títulos grandes de plano devem manter contraste acessível.',
      );
      final pill = find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is ConstrainedBox && widget.constraints.maxWidth == 254,
        ),
      );
      expect(pill, findsOneWidget);
      expect(tester.getSize(pill).width, closeTo(254, 1));
      expect(tester.getSize(pill).height, closeTo(59, 1));
    }
    expect(
      find.image(const AssetImage('assets/imagens/figma/convenio-petlove.png')),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage('assets/imagens/figma/coisademedico-1.png')),
      findsOneWidget,
    );
    expect(
      find.image(
        const AssetImage('assets/imagens/figma/convenio-particular.png'),
      ),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage('assets/imagens/figma/convenio-chevron.png')),
      findsNWidgets(3),
    );
    for (final label in ['Convênio', 'PetLove', 'Doglife', 'Particular']) {
      // ignore: avoid_print
      print('CONVENIO pos $label: ${tester.getTopLeft(find.text(label)).dy}');
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets('Convênio preserva plano, serviço e pet ao continuar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previous = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previous);
    final pet = VetRepository.pets.first;
    VetRepository.selectedPetId = pet.id;
    Map<dynamic, dynamic>? received;

    await tester.pumpWidget(
      MaterialApp(
        home: const ConvenioScreen(),
        routes: {
          '/nova-consulta': (context) {
            received = ModalRoute.of(context)!.settings.arguments as Map;
            return const Scaffold(body: Text('Consulta de teste'));
          },
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Doglife'));
    await tester.pumpAndSettle();

    expect(find.text('Consulta de teste'), findsOneWidget);
    expect(received?['petId'], pet.id);
    expect(received?['plan'], 'DogLife');
    expect(received?['service'], isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Convênio móvel oferece só uma ação acessível por plano', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previous = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previous);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(const MaterialApp(home: ConvenioScreen()));
    await tester.pumpAndSettle();

    final root = tester
        .binding
        .renderViews
        .first
        .owner!
        .semanticsOwner!
        .rootSemanticsNode!;
    final counts = <String, int>{
      for (final name in ['PetLove', 'Doglife', 'Particular']) name: 0,
    };

    void inspect(SemanticsNode node) {
      final data = node.getSemanticsData();
      if (data.hasAction(SemanticsAction.tap)) {
        for (final name in counts.keys) {
          if (data.label.toLowerCase() == name.toLowerCase() ||
              data.tooltip.toLowerCase() == name.toLowerCase()) {
            counts[name] = counts[name]! + 1;
          }
        }
      }
      node.visitChildren((child) {
        inspect(child);
        return true;
      });
    }

    inspect(root);
    handle.dispose();
    for (final name in counts.keys) {
      expect(
        counts[name],
        1,
        reason: '$name não deve aparecer como dois controles de navegação',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Seta de Convênio mantém a navegação por toque', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previous = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previous);
    final pet = VetRepository.pets.first;
    VetRepository.selectedPetId = pet.id;
    Map<dynamic, dynamic>? received;

    await tester.pumpWidget(
      MaterialApp(
        home: const ConvenioScreen(),
        routes: {
          '/nova-consulta': (context) {
            received = ModalRoute.of(context)!.settings.arguments as Map;
            return const Scaffold(body: Text('Consulta aberta'));
          },
        },
      ),
    );
    await tester.pumpAndSettle();

    final arrow = find.byWidgetPredicate(
      (widget) => widget is IconButton && widget.tooltip == 'PetLove',
    );
    expect(arrow, findsOneWidget);
    expect(tester.widget<IconButton>(arrow).onPressed, isNotNull);

    await tester.tap(arrow);
    await tester.pumpAndSettle();
    expect(find.text('Consulta aberta'), findsOneWidget);
    expect(received?['plan'], 'PetLove');
    expect(received?['petId'], pet.id);
    expect(received?['service'], isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Convênio desktop mantém contraste legível nos planos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previous = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previous);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(const MaterialApp(home: ConvenioScreen()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('plans-desktop-layout')), findsOneWidget);
    for (final label in ['PetLove', 'DogLife', 'Particular']) {
      final titleFinder = find.text(label);
      final title = tester.widget<Text>(titleFinder);
      expect(title.style?.fontSize, 16);
      expect(title.style?.fontWeight, FontWeight.bold);
      expect(title.style?.color, VetColors.calendarTextOnRose);

      final pill = tester.widget<Ink>(
        find.ancestor(of: titleFinder, matching: find.byType(Ink)).first,
      );
      final gradient = pill.decoration! as BoxDecoration;
      final colors = (gradient.gradient! as LinearGradient).colors;
      final minimumContrast = colors
          .map((background) => _contrastRatio(title.style!.color!, background))
          .reduce((a, b) => a < b ? a : b);
      expect(
        minimumContrast,
        greaterThanOrEqualTo(4.5),
        reason: 'Texto desktop de 16 px exige contraste AA de 4,5:1.',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Serviços e Convênio não mostram abas fora do fluxo principal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final before = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = before);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(const MaterialApp(home: ServicosScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(VetBottomNav), findsNothing);

    await tester.pumpWidget(const MaterialApp(home: ConvenioScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(VetBottomNav), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
