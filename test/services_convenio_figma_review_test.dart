import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/screens/pets.dart'
    show ServicosScreen, ConvenioScreen;
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/pet_summary.dart';

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
    expect(gradientBegin.x, closeTo(-1.005, 0.01));
    expect(gradientBegin.y, closeTo(0.876, 0.01));
    expect(gradientEnd.x, closeTo(1.005, 0.01));
    expect(gradientEnd.y, closeTo(-0.876, 0.01));
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
}
