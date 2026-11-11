import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/pages/agendamento_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';

void main() {
  testWidgets('exibe o mes atual, navega adiante e seleciona um dia', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AgendamentoPage())),
    );
    await tester.pumpAndSettle();

    final agora = DateTime.now();
    final mesAtual = DateTime(agora.year, agora.month);
    final proximoMes = DateTime(agora.year, agora.month + 1);

    expect(
      find.text('${_meses[mesAtual.month - 1]} ${mesAtual.year}'),
      findsOneWidget,
    );
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
    expect(
      find.text('15 - ${_diasDaSemana[diaSelecionado.weekday % 7]}'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('avisa quando nao ha pets cadastrados', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgendamentoPage(petRepository: InMemoryPetRepository()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agendar consulta'));
    await tester.pumpAndSettle();

    expect(
      find.text('Cadastre um pet primeiro para agendar consulta.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancela o rascunho na tela de serviços após confirmação', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final petRepository = InMemoryPetRepository()..save(_petTeste('Luna'));
    final usuarioRepository = InMemoryUsuarioRepository()
      ..save(_usuarioTeste());
    final agendamentoRepository = InMemoryAgendamentoRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgendamentoPage(
            petRepository: petRepository,
            usuarioRepository: usuarioRepository,
            agendamentoRepository: agendamentoRepository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agendar consulta'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha seu Pet'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    await tester.tap(find.text('Luna'));
    await tester.pumpAndSettle();

    final hoje = DateUtils.dateOnly(DateTime.now());
    final dataEsperada =
        '${hoje.day} - ${_diasDaSemana[hoje.weekday % 7]}, '
        '${_meses[hoje.month - 1]} ${hoje.year}';
    expect(find.text(dataEsperada), findsOneWidget);
    for (final horario in ['12:00', '13:00', '14:00', '15:00', '16:00']) {
      expect(find.text(horario), findsOneWidget);
    }

    await tester.tap(find.byKey(const ValueKey('horario-13:00')));
    await tester.pumpAndSettle();

    expect(find.text('Serviços'), findsOneWidget);
    expect(find.textContaining('Luna'), findsOneWidget);
    expect(find.textContaining('13:00'), findsOneWidget);
    final layoutException = tester.takeException();
    if (layoutException is FlutterError) {
      print(layoutException.diagnostics.map((item) => item.toString()).join('\n'));
    }
    expect(layoutException, isNull);
    expect(find.byKey(const ValueKey('categoria-exames')), findsOneWidget);
    expect(find.byKey(const ValueKey('categoria-vacinas')), findsOneWidget);
    expect(find.text('Hemograma'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('categoria-exames')));
    await tester.pumpAndSettle();
    expect(find.text('Hemograma'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('categoria-exames')));
    await tester.pumpAndSettle();
    expect(find.text('Hemograma'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('servico-microchipagem')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Checkbox>(find.byKey(const ValueKey('servico-microchipagem')))
          .value,
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('servico-hemograma')));
    await tester.pumpAndSettle();
    expect(find.text('Convênio'), findsNothing);
    expect(find.text('Continuar'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.ancestor(
              of: find.text('Continuar'),
              matching: find.byType(ElevatedButton),
            ),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Deseja sair do agendamento?'), findsOneWidget);

    await tester.tap(find.text('Não'));
    await tester.pumpAndSettle();
    expect(find.text('Serviços'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Convênio'), findsOneWidget);
    expect(find.text('Cão'), findsOneWidget);
    expect(find.text('PetLove'), findsOneWidget);
    expect(find.text('Doglife'), findsOneWidget);
    expect(find.text('Particular'), findsOneWidget);
    expect(find.text('Doglife'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar para serviços'));
    await tester.pumpAndSettle();
    expect(find.text('Serviços'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sim'));
    await tester.pumpAndSettle();

    expect(find.text('Serviços'), findsNothing);
    expect(await agendamentoRepository.findAll(), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('continua para convenio e salva o agendamento completo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final petRepository = InMemoryPetRepository()..save(_petTeste('Luna'));
    final usuarioRepository = InMemoryUsuarioRepository()
      ..save(_usuarioTeste());
    final agendamentoRepository = InMemoryAgendamentoRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgendamentoPage(
            petRepository: petRepository,
            usuarioRepository: usuarioRepository,
            agendamentoRepository: agendamentoRepository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agendar consulta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Luna'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('horario-13:00')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('servico-hemograma')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('convenio-doglife')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluir agendamento'));
    await tester.pumpAndSettle();

    final agendamentos = await agendamentoRepository.findAll();
    expect(agendamentos, hasLength(1));
    expect(
      agendamentos.single.usuarioId,
      usuarioRepository.findAll().single.id,
    );
    expect(agendamentos.single.petId, petRepository.findAll().single.id);
    expect(agendamentos.single.horario, '13:00');
    expect(agendamentos.single.convenio, ConvenioAgendamento.doglife);
    expect(agendamentos.single.servicos.single.id, 'hemograma');
    expect(find.text('Luna - 13:00'), findsWidgets);
    expect(find.text('Convênio'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Pet _petTeste(String nome) {
  return Pet(
    tipo: PetType.cachorro,
    nome: nome,
    genero: PetGenero.femea,
    peso: 5,
    dataNascimento: DateTime(2023, 1, 1),
    raca: 'Poodle',
  );
}

Usuario _usuarioTeste() {
  return Usuario(
    nome: 'Ana Souza',
    dataNascimento: DateTime(1990, 5, 20),
    genero: GeneroUsuario.feminino,
    cpf: '529.982.247-25',
    telefone: '11987654321',
    cep: '01001000',
    endereco: 'Rua das Flores',
    numero: '42',
    complemento: '',
    cidade: 'São Paulo',
    email: 'ana@example.com',
  );
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

const _diasDaSemana = [
  'Domingo',
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
];
