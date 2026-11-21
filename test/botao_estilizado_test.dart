import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/widgets/botao_estilizado.dart';

void main() {
  testWidgets('exibe texto, respeita dimensões e executa a ação', (
    tester,
  ) async {
    var cliques = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BotaoEstilizado(
              texto: 'Salvar',
              largura: 180,
              altura: 56,
              tamanhoFonte: 20,
              onPressed: () => cliques++,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(BotaoEstilizado)), const Size(180, 56));
    expect(tester.widget<Text>(find.text('Salvar')).style!.fontSize, 20);
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(cliques, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('não executa ação quando desabilitado', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: BotaoEstilizado(texto: 'Salvar', onPressed: null),
          ),
        ),
      ),
    );

    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Salvar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
