import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/screens/pets.dart'
    show ServicosScreen, ConvenioScreen;
import 'package:flutter_vethome/widgets/pet_summary.dart';

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
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MaterialApp(home: ConvenioScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(PetSummary), findsOneWidget);
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
