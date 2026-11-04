import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/agendamento_page.dart';

void main() {
  testWidgets('exibe o mes atual, navega adiante e seleciona um dia', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AgendamentoPage()),
      ),
    );
    await tester.pumpAndSettle();

    final agora = DateTime.now();
    final mesAtual = DateTime(agora.year, agora.month);
    final proximoMes = DateTime(agora.year, agora.month + 1);

    expect(find.text('${_meses[mesAtual.month - 1]} ${mesAtual.year}'), findsOneWidget);
    expect(find.byTooltip('Mês anterior'), findsNothing);

    await tester.tap(find.byTooltip('Próximo mês'));
    await tester.pumpAndSettle();

    expect(
      find.text('${_meses[proximoMes.month - 1]} ${proximoMes.year}'),
      findsOneWidget,
    );
    expect(find.byTooltip('Mês anterior'), findsOneWidget);

    final diaSelecionado = DateTime(proximoMes.year, proximoMes.month, 15);
    await tester.tap(
      find.byKey(
        ValueKey(
          'calendar-day-${diaSelecionado.year}-${diaSelecionado.month}-${diaSelecionado.day}',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('selected-calendar-day')), findsOneWidget);
    expect(find.textContaining(' - '), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

const _meses = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];
