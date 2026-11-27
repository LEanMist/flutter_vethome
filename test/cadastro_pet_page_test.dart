import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/cadastro_pet_page.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/campo_cadastro.dart';

void main() {
  testWidgets('pet type and gender use bottom sheet selectors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CadastroPetPage(
          usuarioId: 'usuario-1',
          destinoBuilder: (_) => const SizedBox.shrink(),
        ),
      ),
    );

    final primeiroCampo = find.byType(CampoCadastro).first;
    final icone = find.descendant(
      of: primeiroCampo,
      matching: find.byIcon(Icons.pets),
    );
    expect(tester.widget<Icon>(icone).color, VetCores.rosaEscuro);
    final campos = find.byType(TextField);
    expect(
      tester.widget<TextField>(campos.first).style!.color,
      VetCores.marrom,
    );
    expect(tester.widget<TextField>(campos.first).textAlign, TextAlign.start);
    await tester.ensureVisible(campos.at(0));
    await tester.tap(campos.at(0));
    await tester.pumpAndSettle();

    expect(find.text('Selecione o tipo de animal'), findsOneWidget);
    await tester.tap(find.text('Gato'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(campos.at(0)).controller!.text, 'Gato');

    await tester.ensureVisible(campos.at(2));
    await tester.tap(campos.at(2));
    await tester.pumpAndSettle();

    expect(find.text('Selecione o gênero do pet'), findsOneWidget);
    await tester.tap(find.text('Fêmea'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(campos.at(2)).controller!.text, 'Fêmea');
  });

  testWidgets('campo de gênero usa o asset marrom', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CadastroPetPage(
          usuarioId: 'usuario-1',
          destinoBuilder: (_) => const SizedBox.shrink(),
        ),
      ),
    );

    final imagemGenero = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/imagens/genero_iconeMarrom50.png',
    );
    expect(imagemGenero, findsOneWidget);
    expect(
      tester.widget<Image>(imagemGenero).filterQuality,
      FilterQuality.none,
    );
    expect(tester.widget<Image>(imagemGenero).width, 28);
  });

  testWidgets('cor configurável também se aplica ao campo editável', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CampoCadastro(
            titulo: 'Nome',
            icone: Icons.pets,
            altura: 40,
            largura: 200,
            tamanhoIcone: 32,
            tamanhoIconeInterno: 19,
            fonteLabel: 11,
            corTexto: Colors.white,
          ),
        ),
      ),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).style!.color,
      Colors.white,
    );
  });
}
