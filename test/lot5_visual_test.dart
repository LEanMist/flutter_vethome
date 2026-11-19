import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsAction;
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/screens/pets.dart' show EscolhaPetScreen;
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/pets/pet_card_widget.dart';
import 'package:flutter_vethome/widgets/pets/pet_avatar.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';
import 'package:flutter_vethome/widgets/vet_choice_pill.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  void viewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('D8 keeps the 390px panel and softly raises pet rows', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await tester.pumpWidget(const MaterialApp(home: PetsPage()));

    final panel = find.byKey(const ValueKey('pets-list-panel'));
    expect(tester.getSize(panel), const Size(346, 428));
    expect(tester.getTopLeft(panel).dx, closeTo(22, 1));
    expect(tester.getTopLeft(panel).dy, closeTo(182, 1));
    final panelDecoration = tester.widget<Container>(panel).decoration!;
    expect(panelDecoration, isA<BoxDecoration>());
    expect((panelDecoration as BoxDecoration).boxShadow, isNull);
    expect(panelDecoration.color, VetColors.roseOverlay25);

    final card = find.byType(PetCardWidget).first;
    expect(tester.getSize(card).width, closeTo(321, 1));
    expect(tester.getSize(card).height, 52);
    for (var i = 0; i < 4; i++) {
      final rect = tester.getRect(find.byType(PetCardWidget).at(i));
      expect(rect.left, closeTo(34, 1));
      expect(rect.top, closeTo(203 + 70 * i, 1));
      expect(rect.size, const Size(321, 52));
    }
    final addPet = tester.getRect(find.byTooltip('Adicionar pet'));
    expect(addPet.left, closeTo(141, 1));
    expect(addPet.top, closeTo(643, 1));
    expect(addPet.size, const Size(107, 47));
    final addPetTarget = tester.getRect(
      find.byKey(const ValueKey('pets-add-target')),
    );
    expect(addPetTarget.left, closeTo(141, 1));
    expect(addPetTarget.top, closeTo(643, 1));
    expect(addPetTarget.size, const Size(107, 48));
    expect(addPetTarget.bottom - addPet.bottom, 1);
    final bottomNav = find.byType(VetBottomNav);
    final navSurface = tester
        .widgetList<Container>(
          find.descendant(of: bottomNav, matching: find.byType(Container)),
        )
        .firstWhere(
          (item) =>
              item.decoration is inset_shadow.BoxDecoration &&
              item.margin == const EdgeInsets.fromLTRB(12, 6, 12, 50),
        );
    final navRect = tester.getRect(
      find.descendant(
        of: find.byWidget(navSurface),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration == navSurface.decoration,
        ),
      ),
    );
    expect(navRect.left, closeTo(12, 1));
    expect(navRect.top, closeTo(724, 1));
    expect(navRect.size, const Size(366, 70));
    final decoration = tester
        .widgetList<DecoratedBox>(
          find.descendant(of: card, matching: find.byType(DecoratedBox)),
        )
        .map((widget) => widget.decoration)
        .whereType<BoxDecoration>()
        .single;
    expect(decoration.color, VetColors.roseOverlay50);
    expect(decoration.borderRadius, BorderRadius.circular(25));
    final shadow = decoration.boxShadow!.single;
    expect(shadow.color, VetColors.brown.withValues(alpha: .12));
    expect(shadow.offset, const Offset(0, 2));
    expect(shadow.blurRadius, 6);

    final avatar = find.descendant(of: card, matching: find.byType(PetAvatar));
    final name = find.descendant(of: card, matching: find.text('Fernando'));
    expect(
      tester.getTopLeft(name).dx - tester.getTopRight(avatar).dx,
      closeTo(2, .1),
    );

    final chevron = tester.widget<VetChevron>(
      find.descendant(of: card, matching: find.byType(VetChevron)),
    );
    expect(chevron.color, VetColors.brownOnRose);
    expect(chevron.strokeWidth, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lista vazia orienta como cadastrar o primeiro pet', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    VetRepository.pets.clear();
    await tester.pumpWidget(const MaterialApp(home: PetsPage()));

    expect(find.byKey(const ValueKey('pets-empty-state')), findsOneWidget);
    expect(find.byIcon(Icons.pets_outlined), findsOneWidget);
    expect(find.text('Nenhum pet cadastrado'), findsOneWidget);
    expect(
      find.text('Cadastre seu primeiro pet pelo botão + abaixo.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Adicionar pet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'lista Pets expande o cartão para nomes longos em telas estreitas',
    (tester) async {
      viewport(tester, const Size(320, 640));
      const longName =
          'Um nome de pet muito comprido para a largura disponível';
      VetRepository.pets
        ..clear()
        ..add(
          PetModel(
            name: longName,
            imagePath: 'assets/imagens/figma/vethomepng-2.png',
            description: '',
          ),
        );
      await tester.pumpWidget(const MaterialApp(home: PetsPage()));

      final card = find.byType(PetCardWidget).first;
      final nameFinder = find.descendant(
        of: card,
        matching: find.text(longName),
      );
      final name = tester.widget<Text>(nameFinder);
      expect(name.maxLines, 2);
      expect(tester.getSize(nameFinder).height, greaterThan(25));
      expect(tester.getSize(card).height, greaterThan(52 * 320 / 390));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cartão da lista tem um único rótulo acessível e acionável', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const MaterialApp(home: PetsPage()));

      final heading = find.byKey(const ValueKey('pets-page-heading'));
      expect(heading, findsOneWidget);
      expect(tester.getSemantics(heading).flagsCollection.isHeader, isTrue);

      final card = find.byType(PetCardWidget).first;
      final node = tester.getSemantics(card);
      expect(node.label, 'Abrir detalhes de Fernando');
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('D8 stays usable at 320px and in pet choice', (tester) async {
    viewport(tester, const Size(320, 640));
    await tester.pumpWidget(const MaterialApp(home: PetsPage()));
    expect(find.byType(PetCardWidget), findsWidgets);
    final petsCard = find.byType(PetCardWidget).first;
    final petsName = tester.widget<Text>(
      find.descendant(of: petsCard, matching: find.byType(Text)).first,
    );
    expect(petsName.maxLines, 2);
    expect(
      tester.getSize(find.byKey(const ValueKey('pets-add-target'))),
      const Size(107, 48),
    );
    expect(
      tester.getSize(find.byTooltip('Adicionar pet')),
      const Size(107, 47),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MaterialApp(home: EscolhaPetScreen()));
    expect(find.byType(PetCardWidget), findsWidgets);
    final choiceCard = find.byType(PetCardWidget).first;
    final choiceName = tester.widget<Text>(
      find.descendant(of: choiceCard, matching: find.byType(Text)).first,
    );
    expect(choiceName.maxLines, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('D8 mantém o botão visível e ativa o alvo de 48px', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: const PetsPage(),
          routes: {
            '/cadastroPet': (_) => const Scaffold(
              body: Center(child: Text('Cadastro de pet aberto')),
            ),
          },
        ),
      );

      final visualRect = tester.getRect(find.byTooltip('Adicionar pet'));
      final targetRect = tester.getRect(
        find.byKey(const ValueKey('pets-add-target')),
      );
      expect(visualRect.size, const Size(107, 47));
      expect(visualRect.top, 643);
      expect(targetRect.size, const Size(107, 48));
      expect(targetRect.bottom, visualRect.bottom + 1);
      expect(find.bySemanticsLabel('Adicionar pet'), findsOneWidget);

      await tester.tapAt(Offset(targetRect.center.dx, targetRect.bottom - 0.5));
      await tester.pumpAndSettle();
      expect(find.text('Cadastro de pet aberto'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('D8 preserva o alvo do botão na composição desktop', (
    tester,
  ) async {
    viewport(tester, const Size(1280, 800));
    await tester.pumpWidget(const MaterialApp(home: PetsPage()));

    final visualRect = tester.getRect(find.byTooltip('Adicionar pet'));
    final targetRect = tester.getRect(
      find.byKey(const ValueKey('pets-add-target')),
    );
    expect(visualRect.size, const Size(107, 47));
    expect(targetRect.size, const Size(107, 48));
    expect(targetRect.bottom, visualRect.bottom + 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('D8 retains photos and truncates long names without overflow', (
    tester,
  ) async {
    viewport(tester, const Size(320, 640));
    var taps = 0;
    final pet = PetModel(
      name: 'Um nome de pet muito comprido para a largura disponível',
      imagePath: 'assets/imagens/figma/vethomepng-2.png',
      description: '',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 270,
              child: PetCardWidget(pet: pet, onTap: () => taps++),
            ),
          ),
        ),
      ),
    );
    final name = tester.widget<Text>(find.text(pet.name));
    expect(name.overflow, TextOverflow.ellipsis);
    final photo = tester.widget<Image>(
      find.descendant(of: find.byType(PetAvatar), matching: find.byType(Image)),
    );
    expect(photo.width, closeTo(27.9, 0.1));
    expect(photo.height, closeTo(27.9, 0.1));
    expect(photo.fit, BoxFit.cover);
    final ink = tester.widget<InkWell>(
      find.descendant(
        of: find.byType(PetCardWidget),
        matching: find.byType(InkWell),
      ),
    );
    for (final state in [
      WidgetState.hovered,
      WidgetState.focused,
      WidgetState.pressed,
    ]) {
      expect(ink.overlayColor!.resolve({state})!.a, greaterThan(0));
    }
    await tester.tap(find.byType(PetCardWidget));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('D10 keeps Figma brown icons when a destination is selected', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    const labels = ['Pets', 'Perfil', 'Conversa', 'Agenda', 'Configurações'];
    const figmaAssets = [
      'pets.png',
      'frame-53.png',
      'frame-52.png',
      'frame-50.png',
      'frame-49-2.png',
    ];

    Color composite(Color foreground, Color background) =>
        Color.alphaBlend(foreground, background);

    double linearChannel(double normalized) {
      return normalized <= .04045
          ? normalized / 12.92
          : math.pow((normalized + .055) / 1.055, 2.4).toDouble();
    }

    double luminance(Color color) =>
        .2126 * linearChannel(color.r) +
        .7152 * linearChannel(color.g) +
        .0722 * linearChannel(color.b);

    double contrastRatio(Color first, Color second) {
      final firstLuminance = luminance(first);
      final secondLuminance = luminance(second);
      final lighter = firstLuminance > secondLuminance
          ? firstLuminance
          : secondLuminance;
      final darker = firstLuminance > secondLuminance
          ? secondLuminance
          : firstLuminance;
      return (lighter + .05) / (darker + .05);
    }

    final navSurface = composite(VetColors.roseOverlay50, VetColors.pink);
    final selectedPetsSurface = composite(VetColors.roseOverlay50, navSurface);
    expect(
      contrastRatio(VetColors.brown, selectedPetsSurface),
      greaterThanOrEqualTo(3),
    );

    for (var selected = 0; selected < labels.length; selected++) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: VetBottomNav(
              selectedIndex: selected,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      for (var i = 0; i < labels.length; i++) {
        final destination = find.bySemanticsLabel(labels[i]);
        expect(destination, findsOneWidget);
        final semantics = tester.widget<Semantics>(destination);
        expect(semantics.properties.selected, i == selected);
        if (i == selected) {
          final image = tester.widget<Image>(
            find.descendant(of: destination, matching: find.byType(Image)),
          );
          expect(
            (image.image as AssetImage).assetName,
            endsWith(figmaAssets[i]),
          );
        }
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('D10 Pets circle uses the selected inset treatment', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await tester.pumpWidget(const MaterialApp(home: PetsPage()));
    final bar = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(VetBottomNav),
            matching: find.byType(Container),
          ),
        )
        .firstWhere((item) => item.decoration is inset_shadow.BoxDecoration);
    final outerSize = tester.getSize(find.byWidget(bar));
    final margin = bar.margin! as EdgeInsets;
    expect(
      Size(
        outerSize.width - margin.horizontal,
        outerSize.height - margin.vertical,
      ),
      const Size(366, 70),
    );
    expect(tester.getTopLeft(find.byWidget(bar)).dy + margin.top, 724);

    final pets = find.bySemanticsLabel('Pets');
    final circle = tester
        .widgetList<Container>(
          find.descendant(of: pets, matching: find.byType(Container)),
        )
        .map((item) => item.decoration)
        .whereType<inset_shadow.BoxDecoration>()
        .single;
    expect(circle.color, VetColors.roseOverlay50);
    final shadow = circle.boxShadow!.single as inset_shadow.BoxShadow;
    expect(shadow.inset, isTrue);
    expect(shadow.color, VetColors.shadowDark);
    expect(shadow.offset, const Offset(2, 2));
    expect(shadow.blurRadius, 2);
  });

  testWidgets('D10 hover, focus and press remain visible over PNG circles', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: VetBottomNav(
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    Color? foreground(String label) => tester
        .widgetList<Container>(
          find.descendant(
            of: find.bySemanticsLabel(label),
            matching: find.byType(Container),
          ),
        )
        .map((item) => item.foregroundDecoration)
        .whereType<BoxDecoration>()
        .single
        .color;

    final perfil = find.bySemanticsLabel('Perfil');
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(perfil));
    await tester.pump();
    expect(foreground('Perfil'), isNot(Colors.transparent));

    await mouse.moveTo(const Offset(0, 0));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(foreground('Pets'), isNot(Colors.transparent));

    final touch = await tester.startGesture(tester.getCenter(perfil));
    await tester.pump(const Duration(milliseconds: 150));
    expect(foreground('Perfil'), isNot(Colors.transparent));
    await touch.up();
    await mouse.removePointer();
  });

  testWidgets('D10 keeps five tappable, labelled destinations at 320px', (
    tester,
  ) async {
    viewport(tester, const Size(320, 640));
    final tapped = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: VetBottomNav(
            selectedIndex: 3,
            onSelected: tapped.add,
          ),
        ),
      ),
    );
    const labels = ['Pets', 'Perfil', 'Conversa', 'Agenda', 'Configurações'];
    for (var i = 0; i < labels.length; i++) {
      final destination = find.bySemanticsLabel(labels[i]);
      expect(tester.getSize(destination).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(destination).height, greaterThanOrEqualTo(48));
      await tester.tap(destination);
      await tester.pump();
    }
    expect(tapped, [0, 1, 2, 3, 4]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('D10 stays inside 320px mobile and 1280px desktop viewports', (
    tester,
  ) async {
    for (final size in [const Size(320, 640), const Size(1280, 800)]) {
      viewport(tester, size);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: VetBottomNav(
              selectedIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byType(VetBottomNav));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(size.width));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(size.height));
      expect(tester.takeException(), isNull);
    }
  });
}
