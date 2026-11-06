import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/endereco_page.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';
import 'package:flutter_vethome/widgets/address_form.dart';

List<String> _addressAssetNames(WidgetTester tester) => tester
    .widgetList<Image>(find.byType(Image))
    .map((image) => image.image)
    .whereType<AssetImage>()
    .map((image) => image.assetName)
    .where((assetName) => assetName.contains('address-prefix-'))
    .toList();

Size _addressAssetSize(WidgetTester tester, String assetName) => tester.getSize(
  find
      .byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == assetName,
      )
      .first,
);

void main() {
  const address = SavedAddress(
    id: 'figma-edit-address',
    name: 'Casa da Irmã',
    street: 'Rua das Flores',
    number: '73',
    complement: 'Caixa da Água',
    city: 'Perus - São Paulo',
    cep: '34556-234',
  );

  testWidgets('EDIT_ADRESS_WIDGET mantém campos e ações do Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const MaterialApp(home: AddressEditorPage(address: address)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Numero'), findsOneWidget);
    expect(find.text('Número'), findsNothing);
    expect(find.text('Complemento'), findsOneWidget);
    expect(find.text('Complemento (opcional)'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Excluir'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Salvar'), findsOneWidget);
    expect(find.text('Salvar endereço'), findsNothing);

    final prefixAssets = _addressAssetNames(tester);
    expect(
      prefixAssets,
      containsAll([
        'assets/imagens/figma/address-prefix-home.png',
        'assets/imagens/figma/address-prefix-number.png',
        'assets/imagens/figma/address-prefix-city-circle.png',
        'assets/imagens/figma/address-prefix-city.png',
      ]),
    );
    expect(
      prefixAssets
          .where((assetName) => assetName.endsWith('address-prefix-home.png'))
          .length,
      4,
    );
    expect(
      prefixAssets
          .where((assetName) => assetName.endsWith('address-prefix-number.png'))
          .length,
      1,
    );
    expect(
      _addressAssetSize(tester, 'assets/imagens/figma/address-prefix-home.png'),
      const Size(58, 56),
    );
    expect(
      _addressAssetSize(
        tester,
        'assets/imagens/figma/address-prefix-number.png',
      ),
      const Size(58, 56),
    );
    expect(
      _addressAssetSize(
        tester,
        'assets/imagens/figma/address-prefix-city-circle.png',
      ),
      const Size(58, 56),
    );
    expect(
      _addressAssetSize(tester, 'assets/imagens/figma/address-prefix-city.png'),
      const Size(29, 25),
    );

    final deleteButton = find.widgetWithText(OutlinedButton, 'Excluir');
    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar');
    expect(tester.getSize(deleteButton), const Size(90, 34));
    expect(tester.getSize(saveButton), const Size(90, 34));
    expect(
      tester.getTopLeft(saveButton).dx - tester.getTopRight(deleteButton).dx,
      closeTo(79, 1),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    expect(find.text('Excluir endereço?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(AddressEditorPage), findsOneWidget);
  });

  testWidgets('REGISTER_ADRESS_PAGE usa os ícones originais do Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddressForm(
            title: 'Endereço',
            onSaved: (_) async {},
            onSkip: () async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final prefixAssets = _addressAssetNames(tester);
    expect(find.text('Logradouro'), findsOneWidget);
    expect(find.text('Numero'), findsOneWidget);
    expect(
      prefixAssets,
      contains('assets/imagens/figma/address-prefix-home.png'),
    );
    expect(
      prefixAssets,
      contains('assets/imagens/figma/address-prefix-number.png'),
    );
    expect(
      prefixAssets,
      contains('assets/imagens/figma/address-prefix-city-circle.png'),
    );
    expect(
      prefixAssets,
      contains('assets/imagens/figma/address-prefix-city.png'),
    );
    expect(
      prefixAssets
          .where((assetName) => assetName.endsWith('address-prefix-home.png'))
          .length,
      4,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('REGISTER_ADRESS_PAGE preserva posições com área segura real', (
    tester,
  ) async {
    // Carrega a fonte real para não medir o texto de Figma com Ahem.
    final fontLoader = FontLoader(VH.bodyFontFamily)
      ..addFont(rootBundle.load('assets/fonts/MontserratAlternatesBold.ttf'));
    await fontLoader.load();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: const EnderecoScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final title = find.text('Endereço');
    expect(tester.getTopLeft(title).dy, 31);
    expect(
      tester.getRect(find.byKey(const ValueKey('address-registration-panel'))),
      const Rect.fromLTWH(50, 88, 290, 565),
    );
    expect(
      tester.getRect(find.widgetWithText(ElevatedButton, 'Continuar')),
      const Rect.fromLTWH(104.5, 683, 181, 65),
    );
    expect(tester.getTopLeft(find.text('Pular')).dy, closeTo(764, 1));
    final skipStyle = tester
        .renderObject<RenderParagraph>(find.text('Pular'))
        .text
        .style!;
    expect(skipStyle.fontFamily, VH.bodyFontFamily);
    expect(skipStyle.fontSize, 15);
    expect(skipStyle.fontWeight, FontWeight.bold);
    expect(skipStyle.color, VH.secondary);
    expect(tester.takeException(), isNull);
  });
}
