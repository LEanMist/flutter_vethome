import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/endereco_page.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';
import 'package:flutter_vethome/widgets/address_form.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

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

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Editar endereço'), findsNothing);
    final editorPanel = find.byKey(const ValueKey('address-editor-panel'));
    final editorRect = tester.getRect(editorPanel);
    expect(editorRect.size, const Size(290, 633));
    expect(editorRect.left, 50);
    expect(editorRect.top, 105.5);

    expect(find.text('Numero'), findsOneWidget);
    expect(find.text('Logradouro'), findsOneWidget);
    expect(find.text('Endereço'), findsNothing);
    expect(find.text('Número'), findsNothing);
    expect(find.text('Complemento'), findsOneWidget);
    expect(find.text('Complemento (opcional)'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Excluir'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Salvar'), findsOneWidget);
    expect(find.text('Salvar endereço'), findsNothing);

    for (final (label, labelTop, fieldTop) in const [
      ('CEP', 14.0, 34.0),
      ('Logradouro', 106.0, 127.0),
      ('Numero', 199.0, 219.0),
      ('Complemento', 291.0, 311.0),
      ('Cidade', 383.0, 403.0),
      ('Nome', 475.0, 495.0),
    ]) {
      final labelRect = tester.getRect(find.text(label));
      expect(labelRect.left, closeTo(editorRect.left + 20, 1));
      expect(labelRect.top, closeTo(editorRect.top + labelTop, 1));
      final input = find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is VHField && widget.label == label,
        ),
        matching: find.byType(TextFormField),
      );
      final fieldRect = tester.getRect(input);
      expect(fieldRect.left, closeTo(editorRect.left + 15, 1));
      expect(fieldRect.top, closeTo(editorRect.top + fieldTop, 1));
      expect(fieldRect.width, closeTo(259, 1));
      expect(fieldRect.height, closeTo(56, 1));
    }

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
    final deleteTarget = find.byKey(const ValueKey('address-delete-target'));
    final saveTarget = find.byKey(const ValueKey('address-save-target'));
    final saveStyle = tester.widget<ElevatedButton>(saveButton).style!;
    expect(tester.getSize(deleteTarget), const Size(90, 48));
    expect(tester.getSize(saveTarget), const Size(90, 48));
    expect(
      tester.getRect(deleteButton),
      const Rect.fromLTWH(65, 681.5, 90, 34),
    );
    expect(tester.getRect(saveButton), const Rect.fromLTWH(234, 681.5, 90, 34));
    expect(
      tester.getTopLeft(deleteButton).dy - tester.getTopLeft(deleteTarget).dy,
      14,
    );
    expect(
      tester.getBottomRight(saveButton).dy,
      tester.getBottomRight(saveTarget).dy,
    );
    expect(saveStyle.backgroundColor!.resolve({}), VH.primary);
    expect(saveStyle.foregroundColor!.resolve({}), Colors.white);
    expect(
      saveStyle.textStyle!.resolve(const <WidgetState>{})!.fontFamily,
      'Comfortaa',
    );
    expect(saveStyle.textStyle!.resolve(const <WidgetState>{})!.fontSize, 15);
    expect(
      tester.getTopLeft(saveButton).dx - tester.getTopRight(deleteButton).dx,
      closeTo(79, 1),
    );
    expect(tester.takeException(), isNull);

    final deleteTargetRect = tester.getRect(deleteTarget);
    await tester.tapAt(
      Offset(deleteTargetRect.center.dx, deleteTargetRect.top + 5),
    );
    await tester.pumpAndSettle();
    expect(find.text('Excluir endereço?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(AddressEditorPage), findsOneWidget);
  });

  testWidgets('EDIT_ADRESS_WIDGET: cartão compacto expõe o nome do diálogo', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: AddressEditorPage(address: address, modal: true),
        ),
      );
      await tester.pumpAndSettle();

      final dialog = find.byKey(const ValueKey('address-editor-dialog'));
      expect(dialog, findsOneWidget);
      expect(find.bySemanticsLabel('Editar endereço'), findsOneWidget);
      expect(find.text('Editar endereço'), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('address-editor-panel'))),
        const Size(290, 633),
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('novo endereço mantém contraste acessível no botão rosa', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AddressEditorPage()));
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar endereço');
    final saveStyle = tester.widget<ElevatedButton>(saveButton).style!;
    expect(saveStyle.backgroundColor!.resolve({}), VH.secondary);
    expect(
      saveStyle.foregroundColor!.resolve({}),
      VetColors.calendarTextOnRose,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('novo endereço mantém Salvar visível em tela baixa', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(const MaterialApp(home: AddressEditorPage()));
    await tester.pumpAndSettle();

    final footer = find.byKey(
      const ValueKey('address-form-pinned-save-footer'),
    );
    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar endereço');
    expect(footer, findsOneWidget);
    expect(saveButton, findsOneWidget);
    expect(tester.getRect(footer).bottom, lessThanOrEqualTo(616));
    expect(tester.getRect(saveButton).bottom, lessThanOrEqualTo(616));
    expect(tester.takeException(), isNull);
  });

  testWidgets('novo endereço mantém Salvar visível com texto a 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const AddressEditorPage(),
      ),
    );
    await tester.pumpAndSettle();

    final footer = find.byKey(
      const ValueKey('address-form-pinned-save-footer'),
    );
    expect(footer, findsOneWidget);
    expect(tester.getRect(footer).bottom, lessThanOrEqualTo(456));
    expect(
      tester.getRect(find.text('Salvar endereço')).bottom,
      lessThanOrEqualTo(456),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('novo endereço mantém Salvar acima do teclado aberto', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const MaterialApp(home: AddressEditorPage()));
    await tester.pumpAndSettle();

    final footer = find.byKey(
      const ValueKey('address-form-pinned-save-footer'),
    );
    expect(footer, findsOneWidget);
    expect(tester.getRect(footer).bottom, lessThanOrEqualTo(360));
    expect(tester.takeException(), isNull);
  });

  testWidgets('novo endereço permite confirmar com teclado e texto a 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const AddressEditorPage(),
      ),
    );
    await tester.pumpAndSettle();

    final footer = find.byKey(
      const ValueKey('address-form-pinned-save-footer'),
    );
    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar endereço');
    expect(footer, findsOneWidget);
    expect(tester.getRect(footer).bottom, lessThanOrEqualTo(200));
    expect(tester.getRect(saveButton).bottom, lessThanOrEqualTo(200));
    expect(tester.takeException(), isNull);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Informe um CEP com 8 números'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor Figma mantém Salvar acessível em tela baixa', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const MaterialApp(home: AddressEditorPage(address: address)),
    );
    await tester.pumpAndSettle();

    final panel = find.byKey(const ValueKey('address-editor-panel'));
    expect(tester.getSize(panel), const Size(290, 633));
    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(saveButton).dy, lessThanOrEqualTo(617));
    expect(tester.takeException(), isNull);
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
      const Rect.fromLTWH(49, 88, 290, 565),
    );
    final registrationPanel = tester.widget<Container>(
      find.byKey(const ValueKey('address-registration-panel')),
    );
    expect(registrationPanel.clipBehavior, Clip.antiAlias);
    final panelDecoration =
        registrationPanel.decoration! as inset_shadow.BoxDecoration;
    expect(panelDecoration.boxShadow, hasLength(1));
    final panelShadow =
        panelDecoration.boxShadow!.single as inset_shadow.BoxShadow;
    expect(panelShadow.color, VetColors.shadowDark);
    expect(panelShadow.offset, const Offset(2, 2));
    expect(panelShadow.blurRadius, 5);
    expect(panelShadow.inset, isTrue);
    for (final (label, labelTop, fieldTop) in const [
      ('CEP', 102.0, 122.0),
      ('Logradouro', 194.0, 215.0),
      ('Numero', 287.0, 307.0),
      ('Complemento', 379.0, 399.0),
      ('Cidade', 471.0, 491.0),
      ('Nome', 563.0, 583.0),
    ]) {
      final labelRect = tester.getRect(find.text(label));
      expect(labelRect.left, closeTo(69, 1));
      expect(labelRect.top, closeTo(labelTop, 1));

      final field = find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is VHField && widget.label == label,
        ),
        matching: find.byType(TextFormField),
      );
      final fieldRect = tester.getRect(field);
      expect(fieldRect.left, closeTo(64, 1));
      expect(fieldRect.top, closeTo(fieldTop, 1));
      expect(fieldRect.width, closeTo(259, 1));
      expect(fieldRect.height, closeTo(56, 1));
    }
    expect(
      tester.getRect(find.widgetWithText(ElevatedButton, 'Continuar')),
      const Rect.fromLTWH(104.5, 683, 181, 65),
    );
    final continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continuar'),
    );
    expect(
      continueButton.style?.backgroundColor?.resolve(const <WidgetState>{}),
      VH.secondary,
    );
    expect(
      continueButton.style?.foregroundColor?.resolve(const <WidgetState>{}),
      VetColors.calendarTextOnRose,
    );
    expect(
      _contrastRatio(VetColors.calendarTextOnRose, VH.secondary),
      greaterThanOrEqualTo(4.5),
    );
    expect(tester.getTopLeft(find.text('Pular')).dy, closeTo(764, 1));
    final skipStyle = tester
        .renderObject<RenderParagraph>(find.text('Pular'))
        .text
        .style!;
    expect(skipStyle.fontFamily, VH.bodyFontFamily);
    expect(skipStyle.fontSize, 15);
    expect(skipStyle.fontWeight, FontWeight.bold);
    expect(skipStyle.color, VH.foreground);
    expect(
      _contrastRatio(skipStyle.color!, VH.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor de endereço oferece navegação e protege alterações', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const AddressEditorPage(address: address),
        routes: {
          '/config': (_) => const Scaffold(body: Text('Config destino')),
        },
      ),
    );
    await tester.pumpAndSettle();

    final settingsTab = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'Configurações',
    );
    expect(find.byType(VetBottomNav), findsOneWidget);
    await tester.tap(settingsTab);
    await tester.pumpAndSettle();
    expect(find.text('Sair da edição?'), findsOneWidget);

    await tester.tap(find.text('Continuar editando'));
    await tester.pumpAndSettle();
    expect(find.byType(AddressEditorPage), findsOneWidget);

    await tester.tap(settingsTab);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair sem salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Config destino'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edição compacta de endereço também oferece troca de tela', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const AddressEditorPage(address: address, modal: true),
              ),
              child: const Text('Abrir edição'),
            ),
          ),
        ),
        routes: {
          '/config': (_) => const Scaffold(body: Text('Config destino')),
        },
      ),
    );
    await tester.tap(find.text('Abrir edição'));
    await tester.pumpAndSettle();

    final routeMenu = find.byKey(
      const ValueKey('address-editor-modal-route-menu'),
    );
    expect(routeMenu, findsOneWidget);
    await tester.tap(routeMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurações').last);
    await tester.pumpAndSettle();
    expect(find.text('Sair da edição?'), findsOneWidget);

    await tester.tap(find.text('Continuar editando'));
    await tester.pumpAndSettle();
    expect(routeMenu, findsOneWidget);

    await tester.tap(routeMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurações').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair sem salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Config destino'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
