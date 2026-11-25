import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/pet_perfil_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';

Pet _pet(String id) => Pet(
  id: id,
  usuarioId: 'usuario',
  nome: id,
  tipo: PetType.cachorro,
  genero: PetGenero.macho,
  peso: 4,
  dataNascimento: DateTime(2020),
  raca: 'Poodle',
);

Agendamento _agendamento({
  required DateTime data,
  required String nome,
  String petId = 'max',
  String usuarioId = 'usuario',
  StatusAgendamento status = StatusAgendamento.ativo,
}) => Agendamento(
  usuarioId: usuarioId,
  petId: petId,
  data: data,
  horario: '13:00',
  status: status,
  servicos: [
    ServicoAgendamento(
      id: 'primeiro',
      categoria: CategoriaServico.exames,
      nome: nome,
    ),
    const ServicoAgendamento(
      id: 'segundo',
      categoria: CategoriaServico.vacinas,
      nome: 'Segundo serviço',
    ),
  ],
  convenio: ConvenioAgendamento.particular,
);

class _RepositorioComErro extends InMemoryAgendamentoRepository {
  @override
  Future<List<Agendamento>> findByPetId(String petId) =>
      Future.error(StateError('falha'));
}

void main() {
  testWidgets('exibe apenas ativos do pet e rola conteúdos longos', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final pets = InMemoryPetRepository()..save(_pet('max'));
    final repository = InMemoryAgendamentoRepository();
    final amanha = DateUtils.dateOnly(
      DateTime.now(),
    ).add(const Duration(days: 1));
    const nomeLongo =
        'Exame com um nome bastante extenso que precisa se ajustar '
        'ao espaço disponível sem cortar o conteúdo';
    await repository.save(_agendamento(data: amanha, nome: nomeLongo));
    for (var i = 1; i < 6; i++) {
      await repository.save(
        _agendamento(
          data: amanha.add(Duration(days: i)),
          nome: 'Serviço ativo $i',
        ),
      );
    }
    await repository.save(
      _agendamento(
        data: amanha.add(const Duration(days: 6)),
        nome: 'Outro pet',
        petId: 'outro',
      ),
    );
    await repository.save(
      _agendamento(
        data: amanha.add(const Duration(days: 7)),
        nome: 'Outra conta',
        usuarioId: 'outra',
      ),
    );
    await repository.save(
      _agendamento(
        data: amanha.add(const Duration(days: 8)),
        nome: 'Cancelado',
        status: StatusAgendamento.cancelado,
      ),
    );
    await repository.save(
      _agendamento(
        data: amanha.add(const Duration(days: 9)),
        nome: 'Concluído',
        status: StatusAgendamento.concluido,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetPerfilPage(
            petId: 'max',
            usuarioId: 'usuario',
            petRepository: pets,
            agendamentoRepository: repository,
            onVoltar: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Próximo Agendamento'));
    await tester.pumpAndSettle();
    final data =
        '${amanha.day.toString().padLeft(2, '0')}/'
        '${amanha.month.toString().padLeft(2, '0')}/${amanha.year} - 13:00';
    expect(find.text(data), findsOneWidget);
    expect(find.text(nomeLongo), findsOneWidget);
    final titulo = tester.getTopLeft(find.text('Próximo Agendamento')).dx;
    expect(tester.getTopLeft(find.text(data)).dx, closeTo(titulo, 0.1));
    expect(tester.getTopLeft(find.text(nomeLongo)).dx, closeTo(titulo, 0.1));
    expect(tester.getSize(find.text(nomeLongo)).height, greaterThan(40));
    expect(find.text('Segundo serviço'), findsNothing);
    expect(find.text('Outro pet'), findsNothing);
    expect(find.text('Outra conta'), findsNothing);
    expect(find.text('Cancelado'), findsNothing);
    expect(find.text('Concluído'), findsNothing);
    expect(find.text('Nenhum Agendamento Futuro'), findsNothing);
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);

    final lista = find.byKey(const ValueKey('agendamentos-do-pet'));
    final scroll = tester.state<ScrollableState>(
      find.descendant(of: lista, matching: find.byType(Scrollable)).first,
    );
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    await tester.drag(lista, const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('mostra mensagem vazia e distingue falha de carregamento', (
    tester,
  ) async {
    final pets = InMemoryPetRepository()..save(_pet('max'));
    Widget pagina(AgendamentoRepository repository) => MaterialApp(
      home: Scaffold(
        body: PetPerfilPage(
          petId: 'max',
          usuarioId: 'usuario',
          petRepository: pets,
          agendamentoRepository: repository,
          onVoltar: () {},
        ),
      ),
    );
    await tester.pumpWidget(pagina(InMemoryAgendamentoRepository()));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum Agendamento Futuro'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    await tester.pumpWidget(pagina(_RepositorioComErro()));
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível carregar os agendamentos.'),
      findsOneWidget,
    );
    expect(find.text('Nenhum Agendamento Futuro'), findsNothing);
    expect(find.byTooltip('Tentar novamente'), findsOneWidget);
  });

  testWidgets('o cartão ocupa o espaço livre e a lista rola internamente', (
    tester,
  ) async {
    final pets = InMemoryPetRepository()..save(_pet('max'));
    final data = DateUtils.dateOnly(
      DateTime.now(),
    ).add(const Duration(days: 1));
    final repository = InMemoryAgendamentoRepository();
    await repository.save(_agendamento(data: data, nome: 'Exame'));
    final atualizacao = ValueNotifier<int>(0);
    addTearDown(atualizacao.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetPerfilPage(
            petId: 'max',
            usuarioId: 'usuario',
            petRepository: pets,
            agendamentoRepository: repository,
            atualizacaoAgendamentos: atualizacao,
            onVoltar: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final cartao = find.byKey(const ValueKey('cartao-agendamentos-pet'));
    final altura = tester.getSize(cartao).height;
    await repository.save(
      _agendamento(
        data: data.add(const Duration(days: 1)),
        nome:
            'Outro exame com um nome bastante extenso para ocupar mais espaço',
      ),
    );
    atualizacao.value++;
    await tester.pumpAndSettle();
    expect(tester.getSize(cartao).height, closeTo(altura, 0.1));
    final lista = find.byKey(const ValueKey('agendamentos-do-pet'));
    final scroll = tester.state<ScrollableState>(
      find.descendant(of: lista, matching: find.byType(Scrollable)).first,
    );
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  for (final alturaTela in [800.0, 844.0, 900.0]) {
    testWidgets(
      'somente a lista rola e o botão permanece visível em tela $alturaTela',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(390, alturaTela));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final pets = InMemoryPetRepository()..save(_pet('max'));
        final repository = InMemoryAgendamentoRepository();
        final data = DateUtils.dateOnly(
          DateTime.now(),
        ).add(const Duration(days: 1));
        await repository.save(_agendamento(data: data, nome: 'Exame'));
        final atualizacao = ValueNotifier<int>(0);
        addTearDown(atualizacao.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: const SizedBox(height: 92),
              body: PetPerfilPage(
                petId: 'max',
                usuarioId: 'usuario',
                petRepository: pets,
                agendamentoRepository: repository,
                atualizacaoAgendamentos: atualizacao,
                onVoltar: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final cartao = find.byKey(const ValueKey('cartao-agendamentos-pet'));
        final botao = find.text('Nova Consulta');
        final alturaInicial = tester.getSize(cartao).height;
        final posicaoBotao = tester.getCenter(botao);
        if (alturaTela == 900) {
          final lista = find.byKey(const ValueKey('agendamentos-do-pet'));
          final scroll = tester.state<ScrollableState>(
            find.descendant(of: lista, matching: find.byType(Scrollable)),
          );
          expect(scroll.position.maxScrollExtent, 0);
          final customPaint = find.ancestor(
            of: lista,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is CustomPaint && widget.foregroundPainter is ScrollbarPainter,
            ),
          );
          final painter =
              tester.widget<CustomPaint>(customPaint).foregroundPainter! as ScrollbarPainter;
          expect(
            painter.hitTestOnlyThumbInteractive(
              Offset(tester.getSize(lista).width - 2, 10),
              PointerDeviceKind.touch,
            ),
            isFalse,
          );
        }

        for (var i = 1; i < 10; i++) {
          await repository.save(
            _agendamento(
              data: data.add(Duration(days: i)),
              nome: 'Serviço de nome longo número $i para o animal',
            ),
          );
        }
        atualizacao.value++;
        await tester.pumpAndSettle();

        final lista = find.byKey(const ValueKey('agendamentos-do-pet'));
        final scrollLista = tester.state<ScrollableState>(
          find.descendant(of: lista, matching: find.byType(Scrollable)).first,
        );
        expect(tester.getSize(cartao).height, closeTo(alturaInicial, 0.1));
        if (alturaTela == 900) {
          expect(tester.getSize(cartao).height, 250);
        }
        expect(find.byType(Scrollable), findsOneWidget);
        expect(scrollLista.position.maxScrollExtent, greaterThan(0));
        expect(tester.getCenter(botao), posicaoBotao);
        expect(botao.hitTestable(), findsOneWidget);
        expect(
          tester.getBottomLeft(cartao).dy,
          lessThan(tester.getTopLeft(botao).dy),
        );

        final barra = find.ancestor(of: lista, matching: find.byType(Scrollbar));
        final tema = tester.widget<ScrollbarTheme>(
          find.ancestor(of: barra, matching: find.byType(ScrollbarTheme)).first,
        );
        expect(tema.data.thumbColor!.resolve({}), VetCores.marrom);
        final customPaint = find.ancestor(
          of: lista,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is CustomPaint && widget.foregroundPainter is ScrollbarPainter,
          ),
        );
        final painter =
            tester.widget<CustomPaint>(customPaint).foregroundPainter! as ScrollbarPainter;
        final area = tester.getRect(lista);
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
        expect(scrollLista.position.pixels, greaterThan(0));
        scrollLista.position.jumpTo(0);
        await tester.pumpAndSettle();
        final inicio = await tester.startGesture(tester.getCenter(lista));
        await inicio.moveBy(const Offset(0, 200));
        await tester.pump();
        expect(scrollLista.position.pixels, 0);
        await inicio.up();
        await tester.pumpAndSettle();
        await tester.drag(lista, const Offset(0, -180));
        await tester.pumpAndSettle();
        expect(scrollLista.position.pixels, greaterThan(0));
        await tester.drag(lista, const Offset(0, -3000));
        await tester.pumpAndSettle();
        final fim = await tester.startGesture(tester.getCenter(lista));
        await fim.moveBy(const Offset(0, -200));
        await tester.pump();
        expect(scrollLista.position.pixels, scrollLista.position.maxScrollExtent);
        await fim.up();
        await tester.pumpAndSettle();
        expect(find.descendant(
          of: lista,
          matching: find.byType(StretchingOverscrollIndicator),
        ), findsNothing);
        expect(tester.getCenter(botao), posicaoBotao);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('atualiza o status e a lista ao retomar o aplicativo', (
    tester,
  ) async {
    final pets = InMemoryPetRepository()..save(_pet('max'));
    final data = DateUtils.dateOnly(
      DateTime.now(),
    ).add(const Duration(days: 1));
    var agora = data.add(const Duration(hours: 12));
    final repository = InMemoryAgendamentoRepository(agora: () => agora);
    final agendamento = await repository.save(
      _agendamento(data: data, nome: 'Exame agendado'),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetPerfilPage(
            petId: 'max',
            usuarioId: 'usuario',
            petRepository: pets,
            agendamentoRepository: repository,
            onVoltar: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Exame agendado'), findsOneWidget);

    agora = data.add(const Duration(hours: 14));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Exame agendado'), findsNothing);
    expect(find.text('Nenhum Agendamento Futuro'), findsOneWidget);
    expect(
      (await repository.findById(agendamento.id!))!.status,
      StatusAgendamento.concluido,
    );
  });
}
