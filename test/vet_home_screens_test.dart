import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/screens/outros.dart';
import 'package:flutter_vethome/screens/pets.dart' show ConvenioScreen;
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets.dart';

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

  testWidgets('agenda mostra janeiro de 2026 e consultas de exemplo', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AgendaScreen()));

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

    await tester.ensureVisible(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar pet'), findsOneWidget);
    expect(find.text('Nome do pet'), findsOneWidget);
    expect(find.text('Nascimento (DD/MM/AAAA)'), findsOneWidget);
    expect(find.text('Excluir'), findsOneWidget);
  });

  testWidgets('convênio pode ser selecionado antes de continuar', (
    tester,
  ) async {
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

    await tester.tap(find.text('Doglife'));
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Doglife'), findsOneWidget);
  });
}
