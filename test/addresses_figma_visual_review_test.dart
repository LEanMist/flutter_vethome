import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/pets/pets_theme.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';
import 'package:flutter_vethome/widgets/vet/vet_header.dart';

void main() {
  const address = SavedAddress(
    id: 'figma-address-visual',
    name: 'Casa da Irmã',
    street: 'Rua das Flores',
    number: '123',
    complement: 'Casa',
    city: 'São Paulo',
    cep: '01234-567',
  );
  late List<SavedAddress> originalAddresses;

  setUp(() {
    originalAddresses = List<SavedAddress>.of(VetRepository.addresses);
    VetRepository.addresses
      ..clear()
      ..add(address);
  });

  tearDown(() {
    VetRepository.addresses
      ..clear()
      ..addAll(originalAddresses);
  });

  Future<void> showAddresses(WidgetTester tester, Size viewport) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    if (viewport == const Size(390, 844)) {
      tester.view.padding = const FakeViewPadding(bottom: 24);
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(const MaterialApp(home: AddressesPage()));
    await tester.pumpAndSettle();
  }

  testWidgets('ADRESS_PAGE: cartão, botão e barra inferior em 390×844', (
    tester,
  ) async {
    await showAddresses(tester, const Size(390, 844));

    final card = find
        .ancestor(
          of: find.text('Casa da Irmã'),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is inset_shadow.BoxDecoration,
          ),
        )
        .first;
    expect(tester.getRect(card), const Rect.fromLTWH(30, 153, 320, 173));
    expect(
      tester.getRect(find.byKey(const ValueKey('addresses-list-viewport'))),
      const Rect.fromLTWH(0, 125, 370, 554),
    );
    final footer = find.byKey(const ValueKey('addresses-footer'));
    expect(tester.getRect(footer), const Rect.fromLTWH(0, 679, 390, 165));
    final footerBackground = find.descendant(
      of: footer,
      matching: find.byType(ColoredBox),
    );
    expect(tester.widget<ColoredBox>(footerBackground).color, VetColors.pink);
    final decoration =
        tester.widget<Container>(card).decoration!
            as inset_shadow.BoxDecoration;
    expect(decoration.color, VetColors.roseOverlay50);
    expect(decoration.borderRadius, BorderRadius.circular(25));

    for (final (label, rect, background, foreground) in [
      (
        'Editar',
        const Rect.fromLTWH(66, 281, 90, 34),
        const Color.fromRGBO(255, 255, 255, .5),
        VetColors.brown,
      ),
      (
        'Deletar',
        const Rect.fromLTWH(223, 281, 90, 34),
        const Color(0xFF940000),
        Colors.white,
      ),
    ]) {
      final actionFinder = find.widgetWithText(ElevatedButton, label);
      final action = tester.widget<ElevatedButton>(actionFinder);
      expect(tester.getRect(actionFinder), rect);
      expect(
        action.style?.backgroundColor?.resolve(const <WidgetState>{}),
        background,
      );
      expect(
        action.style?.foregroundColor?.resolve(const <WidgetState>{}),
        foreground,
      );
      final textStyle = action.style!.textStyle!.resolve(
        const <WidgetState>{},
      )!;
      expect(textStyle.fontFamily, PetsTheme.fontComfortaa);
      expect(textStyle.fontSize, 15);
      expect(textStyle.fontWeight, FontWeight.bold);
    }

    for (final (label, size) in [('Nome:', 18.0), ('Endereço:', 18.0)]) {
      final text = tester.widget<Text>(find.text(label));
      expect(text.style?.fontFamily, PetsTheme.fontComfortaa);
      expect(text.style?.fontWeight, FontWeight.bold);
      expect(text.style?.fontSize, size);
      expect(text.style?.color, VetColors.brown);
    }
    for (final valueFinder in [
      find.text('Casa da Irmã'),
      find.text('Rua das Flores\nCasa - 123\nSão Paulo'),
    ]) {
      final text = tester.widget<Text>(valueFinder);
      expect(text.style?.fontFamily, PetsTheme.fontComfortaa);
      expect(text.style?.fontSize, 12);
      expect(text.style?.fontWeight, FontWeight.bold);
      expect(text.style?.height, 1.67);
      expect(text.style?.color, VetColors.brownOnRoseCard);
    }
    final cardTextColor = VetColors.brownOnRoseCard;
    final cardBackground = Color.alphaBlend(
      VetColors.roseOverlay50,
      VetColors.pink,
    );
    expect(
      _contrastRatio(cardTextColor, cardBackground),
      greaterThanOrEqualTo(4.5),
    );

    final newAddressButton = find.widgetWithText(
      ElevatedButton,
      'Novo Endereço',
    );
    final button = tester.widget<ElevatedButton>(newAddressButton);
    expect(
      tester.getRect(newAddressButton),
      const Rect.fromLTWH(114.5, 710, 161, 67),
    );
    expect(
      button.style?.backgroundColor?.resolve(const <WidgetState>{}),
      VetColors.brown,
    );
    final buttonText = button.style!.textStyle!.resolve(const <WidgetState>{})!;
    // Figma ADRESS_PAGE 2783:716: Montserrat Alternates Bold, 15 px.
    expect(buttonText.fontFamily, PetsTheme.fontMontserratAlternates);
    expect(buttonText.fontSize, 15);
    expect(buttonText.fontWeight, FontWeight.bold);

    final nav = find.byType(VetBottomNav);
    expect(nav, findsOneWidget);
    expect(tester.getRect(nav), const Rect.fromLTWH(0, 794, 390, 50));
    expect(
      find.descendant(
        of: nav,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Configurações' &&
              widget.properties.selected == true,
        ),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'ADRESS_PAGE: ações de endereços distintos têm nomes acessíveis únicos',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        VetRepository.addresses.add(
          const SavedAddress(
            id: 'address-second-semantic',
            name: 'Trabalho',
            street: 'Rua do Trabalho',
            number: '22',
            city: 'São Paulo',
            cep: '01234-567',
          ),
        );
        await showAddresses(tester, const Size(390, 844));

        for (final (action, description) in [
          ('Editar', 'Casa da Irmã, Rua das Flores, 123'),
          ('Deletar', 'Casa da Irmã, Rua das Flores, 123'),
          ('Editar', 'Trabalho, Rua do Trabalho, 22'),
          ('Deletar', 'Trabalho, Rua do Trabalho, 22'),
        ]) {
          final target = find.bySemanticsLabel('$action endereço $description');
          expect(target, findsOneWidget);
          final data = tester.getSemantics(target).getSemanticsData();
          expect(data.flagsCollection.isButton, isTrue);
          expect(data.hasAction(SemanticsAction.tap), isTrue);
        }
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('ADRESS_PAGE: ações mantêm o visual e recebem toque em 48 px', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      for (final viewport in [const Size(390, 844), const Size(320, 640)]) {
        await showAddresses(tester, viewport);

        for (final action in ['Editar', 'Deletar']) {
          final label = '$action endereço Casa da Irmã, Rua das Flores, 123';
          final target = find.bySemanticsLabel(label);
          final targetRect = tester.getRect(target);
          final visual = find.widgetWithText(ElevatedButton, action);
          final visualRect = tester.getRect(visual);

          expect(targetRect.size, const Size(90, 48));
          expect(visualRect.size, const Size(90, 34));
          expect(visualRect.bottom, targetRect.bottom);

          await tester.tapAt(Offset(targetRect.center.dx, targetRect.top + 5));
          await tester.pumpAndSettle();

          if (action == 'Editar') {
            final dialog = find.byKey(const ValueKey('address-editor-dialog'));
            expect(dialog, findsOneWidget);
            Navigator.of(tester.element(dialog)).pop();
          } else {
            expect(find.text('Excluir endereço?'), findsOneWidget);
            await tester.tap(find.text('Cancelar'));
          }
          await tester.pumpAndSettle();
        }
      }
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('ADRESS_PAGE: barra de status não desloca o frame do Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(const MaterialApp(home: AddressesPage()));
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byType(VetHeader)),
      const Rect.fromLTWH(0, 0, 390, 125),
    );
    expect(tester.getTopLeft(find.text('Endereços')).dy, closeTo(46, 3.1));
    final card = find
        .ancestor(
          of: find.text('Casa da Irmã'),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is inset_shadow.BoxDecoration,
          ),
        )
        .first;
    expect(tester.getRect(card), const Rect.fromLTWH(30, 153, 320, 173));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ADRESS_PAGE: lista com rolagem termina acima do rodapé Figma', (
    tester,
  ) async {
    VetRepository.addresses.addAll(const [
      SavedAddress(
        id: 'figma-address-second',
        name: 'Trabalho',
        street: 'Rua do Trabalho',
        number: '22',
        city: 'São Paulo',
        cep: '01234-567',
      ),
      SavedAddress(
        id: 'figma-address-third',
        name: 'Outro endereço',
        street: 'Rua da Praça',
        number: '73',
        city: 'Perus',
        cep: '01234-567',
      ),
    ]);
    await showAddresses(tester, const Size(390, 844));

    final thirdCard = find
        .ancestor(
          of: find.text('Outro endereço'),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is inset_shadow.BoxDecoration,
          ),
        )
        .first;
    expect(tester.getRect(thirdCard), const Rect.fromLTWH(30, 545, 320, 175));
    expect(
      tester.getRect(find.byKey(const ValueKey('addresses-list-viewport'))),
      const Rect.fromLTWH(0, 125, 370, 554),
    );
    expect(
      tester.widget<Scrollbar>(find.byType(Scrollbar)).thumbVisibility,
      isTrue,
    );
    final scrollbarTheme = ScrollbarTheme.of(
      tester.element(find.byType(Scrollbar)),
    );
    expect(
      scrollbarTheme.thumbColor?.resolve(const <WidgetState>{}),
      VetColors.brown,
    );
    expect(scrollbarTheme.thickness?.resolve(const <WidgetState>{}), 3);
    expect(scrollbarTheme.radius, const Radius.circular(1.5));
    expect(tester.takeException(), isNull);
  });

  for (final viewport in [const Size(320, 640), const Size(1280, 800)]) {
    testWidgets('Endereços mantém responsividade em $viewport', (tester) async {
      await showAddresses(tester, viewport);
      expect(find.text('Endereços'), findsOneWidget);
      expect(find.text('Novo Endereço'), findsOneWidget);
      expect(
        find.byType(VetBottomNav),
        viewport.width < 900 ? findsOneWidget : findsNothing,
      );
      if (viewport.width >= 900) {
        final card = find
            .ancestor(
              of: find.text('Casa da Irmã'),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Container &&
                    widget.decoration is inset_shadow.BoxDecoration,
              ),
            )
            .first;
        expect(tester.getSize(card).height, 173);
      }
      expect(tester.takeException(), isNull);
    });
  }
}

double _contrastRatio(Color first, Color second) {
  final luminances = [_relativeLuminance(first), _relativeLuminance(second)]
    ..sort();
  return (luminances.last + 0.05) / (luminances.first + 0.05);
}

double _relativeLuminance(Color color) {
  double linearize(double value) {
    return value <= 0.04045
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linearize(color.r) +
      0.7152 * linearize(color.g) +
      0.0722 * linearize(color.b);
}
