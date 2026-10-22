import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  testWidgets('D8 keeps the 390px panel and gives pet rows an inset shadow', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await tester.pumpWidget(const MaterialApp(home: PetsPage()));

    final panel = find.byKey(const ValueKey('pets-list-panel'));
    expect(tester.getSize(panel), const Size(346, 428));
    final panelDecoration = tester.widget<Container>(panel).decoration!;
    expect(panelDecoration, isA<BoxDecoration>());
    expect((panelDecoration as BoxDecoration).boxShadow, isNull);
    expect(panelDecoration.color, VetColors.roseOverlay25);

    final card = find.byType(PetCardWidget).first;
    expect(tester.getSize(card).width, closeTo(321, 1));
    expect(tester.getSize(card).height, 52);
    final decoration = tester
        .widgetList<DecoratedBox>(
          find.descendant(of: card, matching: find.byType(DecoratedBox)),
        )
        .map((widget) => widget.decoration)
        .whereType<inset_shadow.BoxDecoration>()
        .single;
    expect(decoration.color, VetColors.roseOverlay50);
    expect(decoration.borderRadius, BorderRadius.circular(25));
    final shadow = decoration.boxShadow!.single as inset_shadow.BoxShadow;
    expect(shadow.inset, isTrue);
    expect(shadow.color, VetColors.shadowDark);
    expect(shadow.offset, const Offset(2, 2));
    expect(shadow.blurRadius, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('D8 stays usable at 320px and in pet choice', (tester) async {
    viewport(tester, const Size(320, 640));
    await tester.pumpWidget(const MaterialApp(home: PetsPage()));
    expect(find.byType(PetCardWidget), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MaterialApp(home: EscolhaPetScreen()));
    expect(find.byType(PetCardWidget), findsWidgets);
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

  testWidgets('D10 selects each of the five exported icon states', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    const labels = ['Pets', 'Perfil', 'Whatsapp', 'Agenda', 'Configurações'];
    const selectedAssets = [
      'pets-6.png',
      'frame-51-2.png',
      'frame-52-5.png',
      'frame-52-3.png',
      'frame-49.png',
    ];
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
            endsWith(selectedAssets[i]),
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
    const labels = ['Pets', 'Perfil', 'Whatsapp', 'Agenda', 'Configurações'];
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
}
