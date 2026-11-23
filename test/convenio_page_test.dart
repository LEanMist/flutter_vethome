import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/agendamento_page.dart';
import 'package:flutter_vethome/pages/convenio_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';

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

  testWidgets('confirms agreement and saves only on the final screen', (
    tester,
  ) async {
    final repository = await _abrirConvenio(tester);

    await tester.tap(find.byTooltip('Continuar com Doglife'));
    await tester.pumpAndSettle();
    expect(find.text('Deseja continuar com Doglife?'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Finalizar agendamento'), findsOneWidget);
    expect(find.text('Doglife'), findsOneWidget);
    expect(find.text('Hemograma'), findsOneWidget);
    expect(find.text('Endereço principal'), findsOneWidget);
    expect(await repository.findAll(), isEmpty);

    await tester.tap(find.byTooltip('Voltar para convênio'));
    await tester.pumpAndSettle();
    expect(find.text('Convênio'), findsOneWidget);
    expect(await repository.findAll(), isEmpty);

    await tester.tap(find.byTooltip('Continuar com Doglife'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('descricao-agendamento')),
      'Informação importante',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
    await tester.pumpAndSettle();

    final agendamentos = await repository.findAll();
    expect(agendamentos, hasLength(1));
    expect(agendamentos.single.convenio, ConvenioAgendamento.doglife);
    expect(agendamentos.single.servicos.single.id, 'hemograma');
    expect(agendamentos.single.endereco, contains('Rua de Teste'));
    expect(agendamentos.single.descricao, 'Informação importante');
    expect(find.text('Serviços'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('returns completed appointment to the calendar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final usuarioRepository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final petRepository = InMemoryPetRepository()
      ..save(
        Pet(
          usuarioId: usuarioRepository.findAll().single.id!,
          nome: 'Mimi',
          tipo: PetType.gato,
          genero: PetGenero.femea,
          peso: 4,
          dataNascimento: DateTime(2020),
          raca: 'Sem raça definida',
        ),
      );
    final repository = InMemoryAgendamentoRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgendamentoPage(
            petRepository: petRepository,
            usuarioRepository: usuarioRepository,
            agendamentoRepository: repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final hoje = DateUtils.dateOnly(DateTime.now());
    final amanha = hoje.add(const Duration(days: 1));
    if (amanha.month != hoje.month) {
      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(ValueKey(
      'calendar-day-${amanha.year}-${amanha.month}-${amanha.day}',
    )));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agendar consulta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mimi'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('horario-12:00')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('servico-microchipagem')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('convenio-particular')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(await repository.findAll(), isEmpty);
    await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
    await tester.pumpAndSettle();
    expect(await repository.findAll(), hasLength(1));
    expect(find.text('12:00'), findsOneWidget);
    expect(find.text('Microchipagem'), findsOneWidget);
    expect(find.text('Agendamento concluído para Mimi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<InMemoryAgendamentoRepository> _abrirConvenio(
  WidgetTester tester,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final repository = InMemoryAgendamentoRepository();
  final usuarioRepository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
  final usuario = usuarioRepository.findAll().single;

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
                          usuarioId: usuario.id!,
                          petId: 'pet-teste',
                          data: DateTime.now().add(const Duration(days: 1)),
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
                        usuarioRepository: usuarioRepository,
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