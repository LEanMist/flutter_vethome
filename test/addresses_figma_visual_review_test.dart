import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/pets/pets_theme.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

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
    final decoration =
        tester.widget<Container>(card).decoration!
            as inset_shadow.BoxDecoration;
    expect(decoration.color, VetColors.roseOverlay50);
    expect(decoration.borderRadius, BorderRadius.circular(25));

    for (final (label, size) in [('Nome:', 18.0), ('Endereço:', 18.0)]) {
      final text = tester.widget<Text>(find.text(label));
      expect(text.style?.fontFamily, PetsTheme.fontComfortaa);
      expect(text.style?.fontWeight, FontWeight.bold);
      expect(text.style?.fontSize, size);
    }

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
    // Figma 2783:716: Montserrat Alternates Bold, 15 px.
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

  for (final viewport in [const Size(320, 640), const Size(1280, 800)]) {
    testWidgets('Endereços mantém responsividade em $viewport', (tester) async {
      await showAddresses(tester, viewport);
      expect(find.text('Endereços'), findsOneWidget);
      expect(find.text('Novo Endereço'), findsOneWidget);
      expect(
        find.byType(VetBottomNav),
        viewport.width < 900 ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
