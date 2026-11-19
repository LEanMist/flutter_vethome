import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/pages/cadastroPet_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/pet_photo_button.dart';
import 'package:flutter_vethome/widgets/pet_form.dart';

void main() {
  testWidgets('cadastro mobile segue a composição REGISTER_PET_PAGE', (
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
        theme: VetTheme.light(VH.primary),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1)),
          child: child!,
        ),
        home: const CadastroPetScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final title = find.text('Cadastro Pet');
    final panel = find.byKey(const ValueKey('pet-registration-panel'));
    expect(tester.getTopLeft(title).dy, closeTo(60, 1));
    expect(tester.getTopLeft(panel), const Offset(49, 139));
    expect(tester.getSize(panel), const Size(290, 480));
    expect(find.byType(PetPhotoButton), findsNothing);
    expect(find.text('Castração'), findsNothing);
    expect(find.text('kg'), findsOneWidget);
    await _expectWeightSuffixWithinInput(tester);

    for (final entry in const {
      'Tipo de Animal': 153.0,
      'Nome do Pet': 246.0,
      'Gênero/Sexo': 338.0,
      'Peso': 338.0,
      'Data de Nascimento': 431.0,
      'Raça': 524.0,
    }.entries) {
      expect(
        tester.getTopLeft(find.text(entry.key)).dy,
        closeTo(entry.value, 1),
        reason: entry.key,
      );
    }

    final inputGeometry = <String, (double, double)>{
      'Tipo de Animal': (173, 259),
      'Nome do Pet': (266, 259),
      'Gênero/Sexo': (358, 122),
      'Peso': (358, 124),
      'Data de Nascimento': (452, 259),
      'Raça': (545, 259),
    };
    for (final entry in inputGeometry.entries) {
      final field = find
          .ancestor(of: find.text(entry.key), matching: find.byType(VHField))
          .first;
      final input = find
          .descendant(of: field, matching: find.byType(TextFormField))
          .first;
      expect(tester.getTopLeft(input).dy, closeTo(entry.value.$1, 1));
      expect(tester.getSize(input), Size(entry.value.$2, 56));
    }

    final weightField = find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == 'Peso',
    );
    final weightInput = find.descendant(
      of: weightField,
      matching: find.byType(TextFormField),
    );
    await tester.enterText(weightInput, '24');
    await tester.pumpAndSettle();
    expect(tester.widget<TextFormField>(weightInput).controller?.text, '24');
    expect(tester.widget<VHField>(weightField).suffixText, 'kg');
    expect(
      find.descendant(of: weightField, matching: find.text('kg')),
      findsOneWidget,
    );
    await _expectWeightSuffixWithinInput(tester);

    final continueButton = find.widgetWithText(ElevatedButton, 'Continuar');
    final continueStyle = tester.widget<ElevatedButton>(continueButton).style!;
    expect(tester.getTopLeft(continueButton).dy, closeTo(663, 1));
    expect(
      continueStyle.backgroundColor?.resolve(<WidgetState>{}),
      VetColors.rose,
    );
    expect(
      continueStyle.foregroundColor?.resolve(<WidgetState>{}),
      VetColors.calendarTextOnRose,
    );
    final skip = find.text('Pular');
    expect(skip, findsOneWidget);
    final skipStyle = tester.renderObject<RenderParagraph>(skip).text.style!;
    expect(skipStyle.fontFamily, VH.bodyFontFamily);
    expect(skipStyle.fontSize, 15);
    expect(skipStyle.fontWeight, FontWeight.bold);
    expect(skipStyle.color, VetColors.brown);
    // O rótulo de 15 px precisa de 4,5:1 contra o fundo rosa.
    final textLuminance = skipStyle.color!.computeLuminance();
    final backgroundLuminance = VetColors.pink.computeLuminance();
    final contrast = (backgroundLuminance + .05) / (textLuminance + .05);
    expect(contrast, greaterThanOrEqualTo(4.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('foto e castração continuam disponíveis ao editar o pet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: Scaffold(
          body: PetForm(
            title: 'Editar pet',
            pet: PetModel(name: 'Toby', imagePath: '', description: ''),
            onSaved: _noop,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PetPhotoButton), findsOneWidget);
    expect(find.text('Castração'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cadastro pet compacto permite validar e alcançar Continuar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: const CadastroPetScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('pet-form-mobile-grid')), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    await _expectWeightSuffixWithinInput(tester);
    final continueButton = find.widgetWithText(ElevatedButton, 'Continuar');
    await tester.ensureVisible(continueButton);
    expect(tester.getRect(continueButton).bottom, lessThanOrEqualTo(640));

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Obrigatório'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Continuar foca o primeiro campo inválido do cadastro', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: VetTheme.light(VH.primary),
          home: const CadastroPetScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      final species = find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Tipo de Animal',
      );
      final speciesInput = find.descendant(
        of: species,
        matching: find.byType(EditableText),
      );
      expect(
        tester.widget<EditableText>(speciesInput).focusNode.hasFocus,
        isTrue,
      );
      expect(find.text('Obrigatório'), findsWidgets);
      final selectorSemantics = tester
          .getSemantics(find.bySemanticsLabel('Tipo de Animal'))
          .getSemanticsData();
      expect(selectorSemantics.value, contains('Erro: Obrigatório'));
      expect(selectorSemantics.hint, contains('Erro: Obrigatório'));
      expect(
        selectorSemantics.validationResult,
        ui.SemanticsValidationResult.invalid,
      );

      final speciesError = find.descendant(
        of: species,
        matching: find.text('Obrigatório'),
      );
      expect(speciesError, findsOneWidget);
      await tester.tap(speciesInput);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cachorro'));
      await tester.pumpAndSettle();

      final correctedSemantics = tester
          .getSemantics(find.bySemanticsLabel('Tipo de Animal'))
          .getSemanticsData();
      expect(correctedSemantics.value, 'Cachorro');
      expect(correctedSemantics.hint, isNot(contains('Erro:')));
      expect(
        correctedSemantics.validationResult,
        ui.SemanticsValidationResult.none,
      );
      expect(speciesError, findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('o rótulo Figma identifica semanticamente o campo', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: VetTheme.light(VH.primary),
          home: const CadastroPetScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final selector = find.bySemanticsLabel('Tipo de Animal');
      final data = tester.getSemantics(selector).getSemanticsData();

      expect(data.label, 'Tipo de Animal');
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.value, 'Nenhuma opção selecionada');
      expect(data.flagsCollection.isExpanded, ui.Tristate.isFalse);
      expect(data.hint, contains('Enter ou Espaço'));

      await tester.tap(selector);
      await tester.pumpAndSettle();
      final expandedData = tester.getSemantics(selector).getSemanticsData();
      expect(expandedData.flagsCollection.isExpanded, ui.Tristate.isTrue);
      expect(expandedData.hint, contains('Lista aberta'));
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('seletor de espécie abre e seleciona com o teclado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: const CadastroPetScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final species = find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == 'Tipo de Animal',
    );
    final speciesInput = find.descendant(
      of: species,
      matching: find.byType(EditableText),
    );
    tester.widget<EditableText>(speciesInput).focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Cachorro'), findsOneWidget);
    expect(find.text('Gato'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    final cachorroTile = find.ancestor(
      of: find.text('Cachorro'),
      matching: find.byType(ListTile),
    );
    final gatoTile = find.ancestor(
      of: find.text('Gato'),
      matching: find.byType(ListTile),
    );
    expect(tester.widget<ListTile>(cachorroTile).tileColor, isNull);
    expect(tester.widget<ListTile>(gatoTile).tileColor, isNotNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(tester.widget<EditableText>(speciesInput).controller.text, 'Gato');
    expect(find.text('Gato'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Cachorro'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Cachorro'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opção ativa permanece visível ao navegar uma lista longa', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 300,
              child: VHField(
                'Opção',
                Icons.list,
                controller: controller,
                choices: List.generate(12, (index) => 'Opção $index'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final input = find.descendant(
      of: find.byType(VHField),
      matching: find.byType(EditableText),
    );
    tester.widget<EditableText>(input).focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    for (var index = 0; index < 8; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    }

    final activeOption = find.ancestor(
      of: find.text('Opção 8'),
      matching: find.byType(ListTile),
    );
    expect(activeOption, findsOneWidget);
    final menuRect = tester.getRect(find.byType(ListView));
    expect(menuRect.contains(tester.getRect(activeOption).center), isTrue);
    expect(tester.widget<ListTile>(activeOption).tileColor, isNotNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(controller.text, 'Opção 8');
    expect(tester.takeException(), isNull);
  });

  testWidgets('cadastro em coluna estreita usa a largura disponível', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget responsiveForm() => MaterialApp(
      theme: VetTheme.light(VH.primary),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 390,
            height: 844,
            child: PetForm(
              title: 'Cadastro Pet',
              onSaved: _noop,
              onSkip: () async {},
            ),
          ),
        ),
      ),
    );

    const fieldLabels = [
      'Tipo de Animal',
      'Nome do Pet',
      'Gênero/Sexo',
      'Peso',
      'Data de Nascimento',
      'Raça',
    ];

    Map<String, Rect> inputRectsRelativeToPanel() {
      final panelRect = tester.getRect(
        find.byKey(const ValueKey('pet-registration-panel')),
      );
      return {
        for (final label in fieldLabels)
          label: tester
              .getRect(
                find
                    .descendant(
                      of: find.byWidgetPredicate(
                        (widget) => widget is VHField && widget.label == label,
                      ),
                      matching: find.byType(TextFormField),
                    )
                    .first,
              )
              .shift(Offset(-panelRect.left, -panelRect.top)),
      };
    }

    await tester.pumpWidget(responsiveForm());
    await tester.pumpAndSettle();

    for (final label in fieldLabels) {
      final field = tester.widget<VHField>(
        find.byWidgetPredicate(
          (widget) => widget is VHField && widget.label == label,
        ),
      );
      expect(field.figmaForm, isTrue, reason: label);
      expect(field.labelAbove, isTrue, reason: label);
    }
    expect(
      tester.getSize(find.byKey(const ValueKey('pet-registration-panel'))),
      const Size(290, 480),
    );
    final tabletWindowRects = inputRectsRelativeToPanel();

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(responsiveForm());
    await tester.pumpAndSettle();
    final mobileWindowRects = inputRectsRelativeToPanel();

    for (final label in fieldLabels) {
      final tabletRect = tabletWindowRects[label]!;
      final mobileRect = mobileWindowRects[label]!;
      expect(mobileRect.left, closeTo(tabletRect.left, .01), reason: label);
      expect(mobileRect.top, closeTo(tabletRect.top, .01), reason: label);
      expect(mobileRect.width, closeTo(tabletRect.width, .01), reason: label);
      expect(mobileRect.height, closeTo(tabletRect.height, .01), reason: label);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('cadastro mostra rótulo e ícones conforme Figma e espécie', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: const CadastroPetScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Tipo de Animal',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cachorro').last);
    await tester.pumpAndSettle();

    expect(find.text('Nome do Cachorro(a)'), findsOneWidget);
    expect(
      find.image(
        const AssetImage('assets/imagens/figma/register-pet-species.png'),
      ),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage('assets/imagens/figma/frame-6.png')),
      findsOneWidget,
    );

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Tipo de Animal',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gato').last);
    await tester.pumpAndSettle();
    expect(find.text('Nome do Gato(a)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cadastro desktop também oculta foto e castração', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CadastroPetScreen()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('pet-form-desktop-grid')), findsOneWidget);
    expect(find.byType(PetPhotoButton), findsNothing);
    expect(find.text('Castração'), findsNothing);
    expect(find.text('kg'), findsOneWidget);
    await _expectWeightSuffixWithinInput(tester);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _expectWeightSuffixWithinInput(WidgetTester tester) async {
  final weightField = find.byWidgetPredicate(
    (widget) => widget is VHField && widget.label == 'Peso',
  );
  final weightSuffix = find.descendant(
    of: weightField,
    matching: find.text('kg'),
  );
  final weightInput = find.descendant(
    of: weightField,
    matching: find.byType(TextFormField),
  );
  await tester.ensureVisible(weightSuffix);

  final suffixBounds = tester.getRect(weightSuffix);
  final inputBounds = tester.getRect(weightInput);
  expect(suffixBounds.left, greaterThan(inputBounds.left));
  expect(suffixBounds.right, lessThanOrEqualTo(inputBounds.right));
  expect(suffixBounds.top, greaterThanOrEqualTo(inputBounds.top));
  expect(suffixBounds.bottom, lessThanOrEqualTo(inputBounds.bottom));
}

Future<void> _noop(PetFormValue _) async {}
