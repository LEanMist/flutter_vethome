import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/convenio_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';

void main() {
  testWidgets('returns to services without completing the draft', (tester) async {
    final repository = await _abrirConvenio(tester);

    expect(find.text('Convênio'), findsOneWidget);
    expect(find.text('Mimi'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('convenio-petlove'))).width,
      lessThan(250),
    );

    await tester.tap(find.byTooltip('Voltar para serviços'));
    await tester.pumpAndSettle();

    expect(find.text('Serviços'), findsOneWidget);
    expect(await repository.findAll(), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not save when agreement confirmation is cancelled', (
    tester,
  ) async {
    final repository = await _abrirConvenio(tester);

    await tester.tap(find.byKey(const ValueKey('convenio-petlove')));
    await tester.pumpAndSettle();
    expect(find.text('Deseja continuar com PetLove?'), findsOneWidget);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('Convênio'), findsOneWidget);
    expect(await repository.findAll(), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saves the agreement after confirming from the arrow', (
    tester,
  ) async {
    final repository = await _abrirConvenio(tester);

    await tester.tap(find.byTooltip('Continuar com Doglife'));
    await tester.pumpAndSettle();
    expect(find.text('Deseja continuar com Doglife?'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    final agendamentos = await repository.findAll();
    expect(agendamentos, hasLength(1));
    expect(agendamentos.single.convenio, ConvenioAgendamento.doglife);
    expect(find.text('Serviços'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<InMemoryAgendamentoRepository> _abrirConvenio(
  WidgetTester tester,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final repository = InMemoryAgendamentoRepository();

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              const Text('Serviços'),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push<Agendamento>(
                    MaterialPageRoute(
                      builder: (_) => ConvenioPage(
                        rascunho: AgendamentoRascunho(
                          usuarioId: 'usuario-teste',
                          petId: 'pet-teste',
                          data: DateTime.now(),
                          horario: '12:00',
                          servicos: const [
                            ServicoAgendamento(
                              id: 'hemograma',
                              categoria: CategoriaServico.exames,
                              nome: 'Hemograma',
                            ),
                          ],
                        ),
                        petNome: 'Mimi',
                        petTipo: PetType.gato,
                        agendamentoRepository: repository,
                      ),
                    ),
                  ),
                  child: const Text('Abrir convênio'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir convênio'));
  await tester.pumpAndSettle();
  return repository;
}