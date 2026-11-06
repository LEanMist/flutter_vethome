import 'package:flutter/material.dart';
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

    final continueButton = find.widgetWithText(ElevatedButton, 'Continuar');
    expect(tester.getTopLeft(continueButton).dy, closeTo(663, 1));
    expect(
      tester
          .widget<ElevatedButton>(continueButton)
          .style
          ?.backgroundColor
          ?.resolve(<WidgetState>{}),
      VetColors.rose,
    );
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
    expect(tester.takeException(), isNull);
  });
}

Future<void> _noop(PetFormValue _) async {}
