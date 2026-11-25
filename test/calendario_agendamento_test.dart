import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/agendamento_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/calendario.dart';
import 'package:flutter_vethome/widgets/etiqueta_perfil.dart';

void main() {
  testWidgets('remove concluídos automaticamente e mantém o histórico', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuarioId = usuarios.findAll().single.id!;
    var agora = DateTime.now();
    final repository = InMemoryAgendamentoRepository(agora: () => agora);
    final data = DateUtils.dateOnly(agora).add(const Duration(days: 1));
    Agendamento novo(String horario, String nome, StatusAgendamento status) =>
        Agendamento(
          usuarioId: usuarioId,
          petId: 'pet',
          data: data,
          horario: horario,
          servicos: [
            ServicoAgendamento(
              id: nome,
              categoria: CategoriaServico.exames,
              nome: nome,
            ),
          ],
          convenio: ConvenioAgendamento.particular,
          status: status,
        );
    final primeiro = await repository.save(
      novo('12:00', 'Primeiro', StatusAgendamento.ativo),
    );
    final segundo = await repository.save(
      novo('13:00', 'Segundo', StatusAgendamento.ativo),
    );
    await repository.save(novo('14:00', 'Cancelado', StatusAgendamento.cancelado));
    await repository.save(novo('15:00', 'Concluído', StatusAgendamento.concluido));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgendamentoPage(
            usuarioId: usuarioId,
            usuarioRepository: usuarios,
            agendamentoRepository: repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Primeiro'), findsOneWidget);
    expect(find.text('Segundo'), findsOneWidget);
    expect(find.text('Cancelado'), findsNothing);
    expect(find.text('Concluído'), findsNothing);

    agora = primeiro.dataHoraConclusao;
    await tester.pump(
      primeiro.dataHoraConclusao.difference(DateTime.now()) +
          const Duration(seconds: 1),
    );
    await tester.pump();
    expect(find.text('Primeiro'), findsNothing);
    expect(find.text('Segundo'), findsOneWidget);
    expect((await repository.findById(primeiro.id!))!.status, StatusAgendamento.concluido);
    expect(await repository.findByUsuarioId(usuarioId), hasLength(4));
    agora = segundo.dataHoraConclusao;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('Segundo'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('lista de agendamentos limita a rolagem em $platform', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
      final id = usuarios.findAll().single.id!;
      final repository = InMemoryAgendamentoRepository();
      final data = DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1));
      for (var i = 0; i < 10; i++) {
        await repository.save(
          Agendamento(
            usuarioId: id,
            petId: 'pet',
            data: data.add(Duration(days: i)),
            horario: '12:00',
            servicos: [
              ServicoAgendamento(
                id: '$i',
                categoria: CategoriaServico.exames,
                nome: 'Exame $i',
              ),
            ],
            convenio: ConvenioAgendamento.particular,
          ),
        );
      }
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: Scaffold(
            body: AgendamentoPage(
              usuarioId: id,
              usuarioRepository: usuarios,
              agendamentoRepository: repository,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final lista = find.byKey(const ValueKey('lista-agendamentos'));
      final scroll = tester.state<ScrollableState>(
        find.descendant(of: lista, matching: find.byType(Scrollable)),
      );
      expect(
        find.descendant(of: lista, matching: find.byType(StretchingOverscrollIndicator)),
        findsNothing,
      );
      expect(
        find.descendant(of: lista, matching: find.byType(GlowingOverscrollIndicator)),
        findsNothing,
      );
      final inicio = await tester.startGesture(tester.getCenter(lista));
      await inicio.moveBy(const Offset(0, 300));
      await tester.pump();
      expect(scroll.position.pixels, scroll.position.minScrollExtent);
      await inicio.up();
      await tester.pumpAndSettle();
      await tester.drag(lista, const Offset(0, -3000));
      await tester.pumpAndSettle();
      final fim = await tester.startGesture(tester.getCenter(lista));
      await fim.moveBy(const Offset(0, -300));
      await tester.pump();
      expect(scroll.position.pixels, scroll.position.maxScrollExtent);
      await fim.up();
      await tester.pumpAndSettle();
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      expect(find.text('Exame 0'), findsOneWidget);
      final barra = find.ancestor(of: lista, matching: find.byType(Scrollbar));
      final scrollbar = tester.widget<Scrollbar>(barra);
      expect(scrollbar.thumbVisibility, isTrue);
      expect(scrollbar.interactive, isTrue);
      final tema = tester.widget<ScrollbarTheme>(
        find.ancestor(of: barra, matching: find.byType(ScrollbarTheme)).first,
      );
      expect(tema.data.thumbColor!.resolve({}), VetCores.marrom);
      scroll.position.jumpTo(scroll.position.minScrollExtent);
      await tester.pumpAndSettle();
      final area = tester.getRect(lista);
      final customPaint = find.ancestor(
        of: lista,
        matching: find.byWidgetPredicate(
          (widget) => widget is CustomPaint && widget.foregroundPainter is ScrollbarPainter,
        ),
      );
      final painter = tester.widget<CustomPaint>(customPaint).foregroundPainter! as ScrollbarPainter;
      expect(
        painter.hitTestOnlyThumbInteractive(
          Offset(area.width - 2, 10),
          PointerDeviceKind.touch,
        ),
        isTrue,
      );
      await tester.dragFrom(
        Offset(area.right - 2, area.top + 10),
        const Offset(0, 60),
      );
      await tester.pumpAndSettle();
      expect(scroll.position.pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('oculta barra sem rolagem e atualiza lista ao cancelar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final id = usuarios.findAll().single.id!;
    final repository = InMemoryAgendamentoRepository();
    final atualizacao = ValueNotifier<int>(0);
    addTearDown(atualizacao.dispose);
    final agendamento = await repository.save(
      Agendamento(
        usuarioId: id,
        petId: 'pet',
        data: DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1)),
        horario: '12:00',
        servicos: const [
          ServicoAgendamento(
            id: 'teste',
            categoria: CategoriaServico.exames,
            nome: 'Exame cancelado',
          ),
        ],
        convenio: ConvenioAgendamento.particular,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgendamentoPage(
            usuarioId: id,
            usuarioRepository: usuarios,
            agendamentoRepository: repository,
            atualizacaoAgendamentos: atualizacao,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final lista = find.byKey(const ValueKey('lista-agendamentos'));
    final scroll = tester.state<ScrollableState>(
      find.descendant(of: lista, matching: find.byType(Scrollable)),
    );
    expect(scroll.position.maxScrollExtent, 0);
    final customPaint = find.ancestor(
      of: lista,
      matching: find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.foregroundPainter is ScrollbarPainter,
      ),
    );
    final painter = tester.widget<CustomPaint>(customPaint).foregroundPainter! as ScrollbarPainter;
    expect(
      painter.hitTestOnlyThumbInteractive(
        Offset(tester.getSize(lista).width - 2, 10),
        PointerDeviceKind.touch,
      ),
      isFalse,
    );
    expect(find.text('Exame cancelado'), findsOneWidget);

    await repository.save(agendamento.copyWith(status: StatusAgendamento.cancelado));
    atualizacao.value++;
    await tester.pumpAndSettle();
    expect(find.text('Exame cancelado'), findsNothing);
    expect((await repository.findById(agendamento.id!))!.status, StatusAgendamento.cancelado);
    expect(tester.takeException(), isNull);
  });

  testWidgets('seletor de agendamento mostra somente pets do usuário', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuarioId = usuarios.findAll().single.id!;
    final pets = InMemoryPetRepository();
    Pet criarPet(String usuarioId, String nome) => Pet(
      usuarioId: usuarioId,
      nome: nome,
      tipo: PetType.cachorro,
      genero: PetGenero.femea,
      peso: 4,
      dataNascimento: DateTime(2020),
      raca: 'Poodle',
    );
    pets.save(criarPet(usuarioId, 'Pet próprio'));
    pets.save(criarPet('outro-usuario', 'Pet de outra conta'));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgendamentoPage(
            usuarioId: usuarioId,
            usuarioRepository: usuarios,
            petRepository: pets,
            agendamentoRepository: InMemoryAgendamentoRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agendar consulta'));
    await tester.pumpAndSettle();
    expect(find.text('Pet próprio'), findsOneWidget);
    expect(find.text('Pet de outra conta'), findsNothing);
  });

  testWidgets(
    'lista apenas os agendamentos do usuário com data, horário e primeiro serviço',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
      final usuarioId = usuarios.findAll().single.id!;
      final repository = InMemoryAgendamentoRepository();
      final amanha = DateUtils.dateOnly(
        DateTime.now(),
      ).add(const Duration(days: 1));
      Agendamento agendamento(
        String usuario,
        DateTime data,
        String horario,
        List<ServicoAgendamento> servicos,
      ) => Agendamento(
        usuarioId: usuario,
        petId: 'pet',
        data: data,
        horario: horario,
        servicos: servicos,
        convenio: ConvenioAgendamento.particular,
      );
      const hemograma = ServicoAgendamento(
        id: 'hemograma',
        categoria: CategoriaServico.exames,
        nome: 'Hemograma',
      );
      const creatina = ServicoAgendamento(
        id: 'creatina',
        categoria: CategoriaServico.exames,
        nome: 'Creatina',
      );
      const vacina = ServicoAgendamento(
        id: 'vacina',
        categoria: CategoriaServico.vacinas,
        nome: 'Vacina',
      );
      await repository.save(
        agendamento(usuarioId, amanha, '12:00', [hemograma, creatina]),
      );
      await repository.save(
        agendamento(usuarioId, amanha.add(const Duration(days: 1)), '13:00', [
          vacina,
        ]),
      );
      await repository.save(
        agendamento('outro-usuario', amanha, '14:00', [creatina]),
      );

      Widget pagina(String id) => MaterialApp(
        home: Scaffold(
          body: AgendamentoPage(
            usuarioId: id,
            usuarioRepository: usuarios,
            agendamentoRepository: repository,
          ),
        ),
      );
      await tester.pumpWidget(pagina(usuarioId));
      await tester.pumpAndSettle();
      final lista = find.byKey(const ValueKey('lista-agendamentos'));
      final data =
          '${amanha.day.toString().padLeft(2, '0')}/${amanha.month.toString().padLeft(2, '0')}/${amanha.year}';
      final dataFinder = find.descendant(of: lista, matching: find.text(data));
      final horarioFinder = find.descendant(
        of: lista,
        matching: find.text('12:00'),
      );
      expect(dataFinder, findsOneWidget);
      expect(horarioFinder, findsOneWidget);
      expect(tester.getSize(dataFinder).height, lessThan(22));
      expect(
        tester.getTopLeft(dataFinder).dy,
        lessThan(tester.getTopLeft(horarioFinder).dy),
      );
      expect(find.text('Hemograma'), findsOneWidget);
      expect(find.text('Vacina'), findsOneWidget);
      expect(find.text('Creatina'), findsNothing);
      expect(
        find.byKey(const ValueKey('separador-agendamentos')),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(find.text('Hemograma')).style!.color,
        VetCores.branco,
      );
      final caixaServico = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Hemograma'),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Container &&
                    widget.decoration is inset.BoxDecoration,
              ),
            )
            .first,
      );
      final decoracao = caixaServico.decoration! as inset.BoxDecoration;
      expect(
        decoracao.boxShadow!.any(
          (sombra) => sombra is inset.BoxShadow && sombra.inset,
        ),
        isTrue,
      );

      await tester.pumpWidget(pagina('outro-usuario'));
      await tester.pumpAndSettle();
      expect(find.text('Hemograma'), findsNothing);
      expect(find.text('Vacina'), findsNothing);
      expect(find.text('Creatina'), findsOneWidget);
      await tester.binding.setSurfaceSize(const Size(320, 640));
      await tester.pumpAndSettle();
      expect(find.text('Creatina'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('calendário redimensionado mantém navegação e seleção', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var data = DateUtils.dateOnly(DateTime.now());
    final proximoMes = DateTime(data.year, data.month + 1);
    final diaEscolhido = DateTime(
      proximoMes.year,
      proximoMes.month,
      data.day == 15 ? 16 : 15,
    );
    late StateSetter atualizar;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                atualizar = setState;
                return CalendarioAgendamento(
                  largura: 300,
                  escala: 0.75,
                  dataSelecionada: data,
                  onDataSelecionada: (selecionada) =>
                      setState(() => data = selecionada),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(CalendarioAgendamento)),
      const Size(300, 307.5),
    );
    expect(find.byType(EtiquetaPerfil), findsOneWidget);
    final fundo = tester.widget<Container>(
      find.byKey(const ValueKey('fundo-calendario')),
    );
    expect(
      (fundo.decoration! as BoxDecoration).borderRadius,
      const BorderRadius.vertical(bottom: Radius.circular(26)),
    );
    expect(find.byTooltip('Mês anterior'), findsNothing);
    if (data.day > 1) {
      final ontem = data.subtract(const Duration(days: 1));
      await tester.tap(
        find.byKey(
          ValueKey('calendar-day-${ontem.year}-${ontem.month}-${ontem.day}'),
        ),
      );
      await tester.pumpAndSettle();
      expect(data, DateUtils.dateOnly(DateTime.now()));
    }
    await tester.tap(find.byTooltip('Próximo mês'));
    await tester.pumpAndSettle();
    expect(data.year, proximoMes.year);
    expect(data.month, proximoMes.month);
    await tester.tap(
      find.byKey(
        ValueKey(
          'calendar-day-${diaEscolhido.year}-${diaEscolhido.month}-${diaEscolhido.day}',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(data, diaEscolhido);
    expect(find.byKey(const ValueKey('selected-calendar-day')), findsOneWidget);

    final novaData = DateTime(proximoMes.year, proximoMes.month + 2, 10);
    atualizar(() => data = novaData);
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        ValueKey('calendar-day-${novaData.year}-${novaData.month}-11'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a data escolhida no calendário é usada ao agendar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final hoje = DateTime.now();
    final dia = hoje.day == 15 ? 16 : 15;
    final data = DateTime(hoje.year, hoje.month + 1, dia);
    final agendamentos = InMemoryAgendamentoRepository();
    await agendamentos.save(
      Agendamento(
        usuarioId: 'outro-usuario',
        petId: 'outro-pet',
        data: data,
        horario: '12:00',
        servicos: const [
          ServicoAgendamento(
            id: 'exame',
            categoria: CategoriaServico.exames,
            nome: 'Exame',
          ),
        ],
        convenio: ConvenioAgendamento.particular,
      ),
    );
    final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final pets = InMemoryPetRepository()
      ..save(
        Pet(
          usuarioId: usuarios.findAll().single.id!,
          nome: 'Luna',
          tipo: PetType.cachorro,
          genero: PetGenero.femea,
          peso: 4,
          dataNascimento: DateTime(2020),
          raca: 'Poodle',
        ),
      );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgendamentoPage(
            petRepository: pets,
            usuarioRepository: usuarios,
            agendamentoRepository: agendamentos,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CalendarioAgendamento)).height, 410);
    await tester.tap(find.byTooltip('Próximo mês'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        ValueKey('calendar-day-${data.year}-${data.month}-${data.day}'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agendar consulta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Luna'));
    await tester.pumpAndSettle();

    expect(find.textContaining('${data.day} - '), findsWidgets);
    expect(find.byKey(const ValueKey('horario-12:00')), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('horario-12:00')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('horario-13:00')))
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });
}
