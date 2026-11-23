import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/widgets/seletor_horario.dart';

void main() {
  testWidgets('bloqueia horários passados de hoje e mantém os futuros', (
    tester,
  ) async {
    final hoje = DateTime(2030, 1, 15);
    await _abrirSeletor(
      tester,
      data: hoje,
      agora: () => DateTime(2030, 1, 15, 15),
      horarios: const ['12:00', '13:00', '14:00', '15:00', '16:00'],
    );
    for (final horario in ['12:00', '13:00', '14:00', '15:00']) {
      expect(
        tester
            .widget<ElevatedButton>(find.byKey(ValueKey('horario-$horario')))
            .onPressed,
        isNull,
      );
    }
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('horario-16:00')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('amanhã mantém horários livres, exceto os já reservados', (
    tester,
  ) async {
    await _abrirSeletor(
      tester,
      data: DateTime(2030, 1, 16),
      agora: () => DateTime(2030, 1, 15, 15),
      horarios: const ['12:00', '13:00', '14:00', '15:00', '16:00'],
      horariosOcupados: {'13:00'},
    );
    for (final horario in ['12:00', '14:00', '15:00', '16:00']) {
      expect(
        tester
            .widget<ElevatedButton>(find.byKey(ValueKey('horario-$horario')))
            .onPressed,
        isNotNull,
      );
    }
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('horario-13:00')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('atualiza o diálogo aberto quando o horário chega', (
    tester,
  ) async {
    var agora = DateTime(2030, 1, 15, 9, 59, 59);
    await _abrirSeletor(
      tester,
      data: DateTime(2030, 1, 15),
      agora: () => agora,
      horariosOcupados: {'09:00'},
    );
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('horario-10:00')))
          .onPressed,
      isNotNull,
    );
    agora = DateTime(2030, 1, 15, 10);
    await tester.pump(const Duration(seconds: 1));
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('horario-10:00')))
          .onPressed,
      isNull,
    );
    expect(
      find.text('Não há horários disponíveis para esta data.'),
      findsOneWidget,
    );
  });

  testWidgets('não seleciona horário que expirou antes da atualização visual', (
    tester,
  ) async {
    var agora = DateTime(2030, 1, 15, 9, 59, 59);
    await _abrirSeletor(
      tester,
      data: DateTime(2030, 1, 15),
      agora: () => agora,
    );
    agora = DateTime(2030, 1, 15, 10);
    await tester.tap(find.byKey(const ValueKey('horario-10:00')));
    await tester.pump();
    expect(find.byType(SeletorHorario), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('horario-10:00')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('horários ocupados ficam cinza e não podem ser selecionados', (
    tester,
  ) async {
    await _abrirSeletor(tester, horariosOcupados: {'09:00'});
    final ocupado = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('horario-09:00')),
    );
    final disponivel = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('horario-10:00')),
    );
    expect(ocupado.onPressed, isNull);
    expect(
      ocupado.style!.backgroundColor!.resolve({WidgetState.disabled}),
      Colors.grey,
    );
    expect(disponivel.onPressed, isNotNull);
    await tester.tap(find.byKey(const ValueKey('horario-09:00')));
    await tester.pumpAndSettle();
    expect(find.byType(SeletorHorario), findsOneWidget);
    expect(find.text('Todos os horários já foram agendados.'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('horario-10:00')));
    await tester.pumpAndSettle();
    expect(find.text('Resultado: 10:00'), findsOneWidget);
  });

  testWidgets('informa quando todos os horários estão ocupados', (
    tester,
  ) async {
    await _abrirSeletor(tester, horariosOcupados: {'09:00', '10:00'});
    expect(find.text('Todos os horários já foram agendados.'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('horario-10:00')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('exibe a data e devolve o horário selecionado', (tester) async {
    await _abrirSeletor(tester);

    expect(find.text('15 - Segunda-feira, Janeiro 2024'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('horario-09:00'))),
      const Size(90, 48),
    );
    await tester.tap(find.byKey(const ValueKey('horario-10:00')));
    await tester.pumpAndSettle();

    expect(find.text('Resultado: 10:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite alterar o tamanho e fechar sem selecionar', (
    tester,
  ) async {
    await _abrirSeletor(tester, larguraBotao: 110, alturaBotao: 56);

    expect(
      tester.getSize(find.byKey(const ValueKey('horario-09:00'))),
      const Size(110, 56),
    );
    await tester.tap(find.byTooltip('Fechar horários'));
    await tester.pumpAndSettle();

    expect(find.text('Resultado: cancelado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _abrirSeletor(
  WidgetTester tester, {
  double larguraBotao = 90,
  double alturaBotao = 48,
  Set<String> horariosOcupados = const {},
  DateTime? data,
  DateTime Function()? agora,
  List<String> horarios = const ['09:00', '10:00'],
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  String resultado = 'aguardando';
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Text('Resultado: $resultado'),
              ElevatedButton(
                onPressed: () async {
                  final selecionado = await showDialog<String>(
                    context: context,
                    builder: (_) => SeletorHorario(
                      data: data ?? DateTime(2024, 1, 15),
                      agora: agora ?? () => DateTime(2024, 1, 14),
                      horarios: horarios,
                      horariosOcupados: horariosOcupados,
                      larguraBotao: larguraBotao,
                      alturaBotao: alturaBotao,
                    ),
                  );
                  if (context.mounted) {
                    setState(() => resultado = selecionado ?? 'cancelado');
                  }
                },
                child: const Text('Abrir'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}
