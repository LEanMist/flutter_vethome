import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/screens/outros.dart';
import 'package:flutter_vethome/screens/pets.dart' show ConvenioScreen;
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/vet_bottom_nav.dart';

void main() {
  test('paleta base segue as cores exatas da referência', () {
    expect(VetColors.pink, const Color(0xFFFAD3D5));
    expect(VetColors.rose, const Color(0xFFC08081));
    expect(VetColors.brown, const Color(0xFF68442E));
  });

  testWidgets('título do cabeçalho usa Comfortaa', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: VHHeader('Referência'))),
    );

    final title = tester.widget<Text>(find.text('Referência'));
    expect(title.style?.fontFamily, 'Comfortaa');
  });

  testWidgets('campo Figma usa fontes Medium e sombra interna sem contorno', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 292,
            child: VHField('Nome Completo', Icons.person, figmaForm: true),
          ),
        ),
      ),
    );

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.style.fontFamily, 'Comfortaa_500');
    expect(editable.style.fontFamilyFallback, const ['Comfortaa']);
    expect(editable.style.fontSize, 15);
    expect(editable.style.fontWeight, FontWeight.w500);

    final label = tester.widget<Text>(find.text('Nome Completo'));
    expect(label.style?.fontFamily, 'MontserratAlternates_500');
    expect(label.style?.fontFamilyFallback, const ['MontserratAlternates']);
    expect(label.style?.fontSize, 14);
    expect(label.style?.fontWeight, FontWeight.w500);

    final input = tester.widget<InputDecorator>(find.byType(InputDecorator));
    final enabledBorder = input.decoration.enabledBorder as OutlineInputBorder;
    expect(enabledBorder.borderSide, BorderSide.none);

    final insetDecoration = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(VHField),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((widget) => widget.decoration)
        .whereType<inset_shadow.BoxDecoration>()
        .single;
    final shadow = insetDecoration.boxShadow!.single as inset_shadow.BoxShadow;
    expect(shadow.inset, isTrue);
    expect(shadow.color, VetColors.shadowDark);
    expect(shadow.offset, const Offset(2, 2));
    expect(shadow.blurRadius, 2);
  });

  testWidgets('botão VH usa tipografia e sombra explícitas do Figma', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PillButton(label: 'Salvar', onTap: () => taps++),
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('Salvar'));
    expect(label.style?.fontFamily, 'Comfortaa');
    expect(label.style?.fontSize, 18);
    expect(label.style?.fontWeight, FontWeight.w700);

    final decoration = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(PillButton),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((widget) => widget.decoration)
        .whereType<BoxDecoration>()
        .singleWhere((value) => value.boxShadow?.isNotEmpty ?? false);
    final shadow = decoration.boxShadow!.single;
    expect(shadow.color, VetColors.shadowDark);
    expect(shadow.offset, const Offset(2, 2));
    expect(shadow.blurRadius, 5);

    await tester.tap(find.text('Salvar'));
    expect(taps, 1);
  });

  testWidgets('navegação inferior mantém cinco rotas e sombra interna', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VetBottomNav(selectedIndex: 0, onSelected: (_) {}),
        ),
      ),
    );

    for (final label in const [
      'Pets',
      'Perfil',
      'Whatsapp',
      'Agenda',
      'Configurações',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }

    final decoration = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(VetBottomNav),
            matching: find.byType(Container),
          ),
        )
        .map((widget) => widget.decoration)
        .whereType<inset_shadow.BoxDecoration>()
        .single;
    final shadow = decoration.boxShadow!.single as inset_shadow.BoxShadow;
    expect(shadow.inset, isTrue);
    expect(shadow.color, VetColors.shadowDark);
    expect(shadow.offset, const Offset(2, 2));
    expect(shadow.blurRadius, 2);
  });

  testWidgets('tela Pets carrega os assets exportados do Figma', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PetsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Fernando'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.contains('/figma/'),
      ),
      findsAtLeastNWidgets(5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('perfil cabe na viewport mobile sem overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('agenda abre uma data específica e mantém exemplos separados', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: AgendaScreen(initialDate: DateTime(2026, 1, 13))),
    );

    expect(find.text('Janeiro 2026'), findsOneWidget);
    expect(find.text('Hemograma'), findsOneWidget);
    expect(find.text('Creatinina'), findsOneWidget);
    expect(find.text('Urina'), findsOneWidget);
  });

  testWidgets('configuracoes nao mostra voltar e mantem navegacao inferior', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));

    expect(find.text('Configurações'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.bySemanticsLabel('Pets'), findsOneWidget);
  });

  testWidgets('editar pet abre um modal com os dados existentes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: DetalhesPetPage(pet: VetRepository.pets.first)),
    );

    await tester.ensureVisible(find.byTooltip('Editar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar pet'), findsOneWidget);
    expect(find.text('Nome do pet'), findsOneWidget);
    expect(find.text('Nascimento'), findsOneWidget);
    expect(find.text('Excluir'), findsOneWidget);
  });

  testWidgets('convênio avança imediatamente ao tocar no card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ConvenioScreen(),
        routes: {
          '/nova-consulta': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, Object>;
            return Scaffold(body: Text(args['plan'].toString()));
          },
        },
      ),
    );

    await tester.tap(find.text('DogLife'));
    await tester.pumpAndSettle();

    expect(find.text('DogLife'), findsOneWidget);
  });
}
