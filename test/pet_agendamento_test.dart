import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/menu_page.dart';
import 'package:flutter_vethome/pages/pet_perfil_page.dart';
import 'package:flutter_vethome/pages/servicos_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/widgets/calendario.dart';
import 'package:flutter_vethome/widgets/seletor_horario.dart';

class _Repositorios {
  _Repositorios()
    : usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true),
      pets = InMemoryPetRepository(),
      agendamentos = InMemoryAgendamentoRepository() {
    pets.save(
      Pet(
        id: 'max',
        usuarioId: usuarios.findAll().single.id!,
        nome: 'Max',
        tipo: PetType.cachorro,
        genero: PetGenero.macho,
        peso: 7,
        dataNascimento: DateTime(2020),
        raca: 'Labrador',
      ),
    );
  }

  final InMemoryUsuarioRepository usuarios;
  final InMemoryPetRepository pets;
  final InMemoryAgendamentoRepository agendamentos;
}

class _AgendamentosComFalha extends InMemoryAgendamentoRepository {
  @override
  Future<List<Agendamento>> findAll() async => throw StateError('erro de rede');
}

Future<void> _abrirMenu(WidgetTester tester, _Repositorios repositorios) async {
  await tester.binding.setSurfaceSize(const Size(390, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: MenuPage(
        usuarioRepository: repositorios.usuarios,
        usuarioId: repositorios.usuarios.findAll().single.id!,
        petRepository: repositorios.pets,
        agendamentoRepository: repositorios.agendamentos,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _abrirPerfil(WidgetTester tester) async {
  await tester.tap(find.text('Max'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Nova Consulta'));
  await tester.pumpAndSettle();
}

Future<void> _selecionarDiaFuturo(WidgetTester tester, DateTime data) async {
  await tester.tap(find.byTooltip('Próximo mês'));
  await tester.pumpAndSettle();
  await tester.tap(
    find.byKey(ValueKey('calendar-day-${data.year}-${data.month}-${data.day}')),
  );
  await tester.pumpAndSettle();
}

DateTime _diaProximoMes() {
  final hoje = DateTime.now();
  return DateTime(hoje.year, hoje.month + 1, hoje.day == 15 ? 16 : 15);
}

void main() {
  testWidgets('agenda pelo perfil e atualiza a aba de agendamentos', (
    tester,
  ) async {
    final repositorios = _Repositorios();
    final data = _diaProximoMes();
    await repositorios.agendamentos.save(
      Agendamento(
        usuarioId: 'outra-conta',
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
    await _abrirMenu(tester, repositorios);
    await _abrirPerfil(tester);
    await tester.tap(find.text('Nova Consulta'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarioAgendamento), findsOneWidget);
    await _selecionarDiaFuturo(tester, data);
    expect(find.byType(SeletorHorario), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('horario-12:00')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('horario-13:00')));
    await tester.pumpAndSettle();
    final servicos = tester.widget<ServicosPage>(find.byType(ServicosPage));
    expect(
      servicos.rascunho.usuarioId,
      repositorios.usuarios.findAll().single.id,
    );
    expect(servicos.rascunho.petId, 'max');
    expect(servicos.rascunho.data, data);
    expect(servicos.rascunho.horario, '13:00');
    expect(servicos.petNome, 'Max');

    await tester.tap(find.byKey(const ValueKey('servico-microchipagem')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('convenio-particular')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('salvar-agendamento')),
    );
    await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
    await tester.pumpAndSettle();
    final salvos = await repositorios.agendamentos.findByUsuarioId(
      repositorios.usuarios.findAll().single.id!,
    );
    expect(salvos, hasLength(1));
    expect(salvos.single.petId, 'max');
    expect(salvos.single.data, data);
    expect(salvos.single.horario, '13:00');
    expect(salvos.single.servicos.single.id, 'microchipagem');
    expect(find.byType(PetPerfilPage), findsOneWidget);
    expect(find.text('Agendamento concluído para Max.'), findsOneWidget);
    expect(find.text('Microchipagem'), findsOneWidget);

    await tester.tap(find.byTooltip('Agendamentos'));
    await tester.pumpAndSettle();
    expect(find.text('Microchipagem'), findsOneWidget);
    expect(find.text('13:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancela cada etapa do perfil sem reservar horário', (
    tester,
  ) async {
    final repositorios = _Repositorios();
    final data = _diaProximoMes();
    await _abrirMenu(tester, repositorios);
    await _abrirPerfil(tester);
    await tester.tap(find.text('Nova Consulta'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Fechar calendário'));
    await tester.pumpAndSettle();
    expect(find.byType(PetPerfilPage), findsOneWidget);

    await tester.tap(find.text('Nova Consulta'));
    await tester.pumpAndSettle();
    await _selecionarDiaFuturo(tester, data);
    await tester.tap(find.byTooltip('Fechar horários'));
    await tester.pumpAndSettle();
    expect(find.byType(PetPerfilPage), findsOneWidget);

    await tester.tap(find.text('Nova Consulta'));
    await tester.pumpAndSettle();
    await _selecionarDiaFuturo(tester, data);
    await tester.tap(find.byKey(const ValueKey('horario-12:00')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Não'));
    await tester.pumpAndSettle();
    expect(find.byType(ServicosPage), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sim'));
    await tester.pumpAndSettle();
    expect(find.byType(PetPerfilPage), findsOneWidget);
    expect(await repositorios.agendamentos.findAll(), isEmpty);

    await tester.tap(find.text('Nova Consulta'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CalendarioAgendamento>(find.byType(CalendarioAgendamento))
          .dataSelecionada,
      DateUtils.dateOnly(DateTime.now()),
    );
    await tester.tap(find.byKey(const ValueKey('selected-calendar-day')));
    await tester.pumpAndSettle();
    for (final horario in horariosDisponiveisAgendamento) {
      expect(
        tester
                .widget<ElevatedButton>(
                  find.byKey(ValueKey('horario-$horario')),
                )
                .onPressed ==
            null,
        horarioJaPassou(DateTime.now(), horario),
      );
    }
    await tester.tap(find.byTooltip('Fechar horários'));
    await tester.pumpAndSettle();
    expect(await repositorios.agendamentos.findAll(), isEmpty);
  });

  testWidgets('atualiza o perfil aberto após agendar pela outra aba', (
    tester,
  ) async {
    final repositorios = _Repositorios();
    final data = _diaProximoMes();
    await _abrirMenu(tester, repositorios);
    await _abrirPerfil(tester);
    expect(find.text('Nenhum Agendamento Futuro'), findsOneWidget);

    await tester.tap(find.byTooltip('Agendamentos'));
    await tester.pumpAndSettle();
    await _selecionarDiaFuturo(tester, data);
    await tester.tap(find.text('Agendar consulta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Max'));
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
    await tester.ensureVisible(
      find.byKey(const ValueKey('salvar-agendamento')),
    );
    await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Pets'));
    await tester.pumpAndSettle();

    expect(find.byType(PetPerfilPage), findsOneWidget);
    expect(find.text('Microchipagem'), findsOneWidget);
    expect(find.text('Nenhum Agendamento Futuro'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'cancelar serviços volta à aba de agendamentos quando essa é a origem',
    (tester) async {
      final repositorios = _Repositorios();
      final data = _diaProximoMes();
      await _abrirMenu(tester, repositorios);
      await tester.tap(find.byTooltip('Agendamentos'));
      await tester.pumpAndSettle();
      await _selecionarDiaFuturo(tester, data);
      await tester.tap(find.text('Agendar consulta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Max'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('horario-12:00')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sim'));
      await tester.pumpAndSettle();
      expect(find.text('Agendar consulta'), findsOneWidget);
      expect(find.byType(ServicosPage), findsNothing);
      expect(await repositorios.agendamentos.findAll(), isEmpty);
    },
  );

  testWidgets('informa falha ao consultar horários em tela pequena', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 550));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repositorios = _Repositorios();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetPerfilPage(
            petId: 'max',
            usuarioId: repositorios.usuarios.findAll().single.id!,
            petRepository: repositorios.pets,
            usuarioRepository: repositorios.usuarios,
            agendamentoRepository: _AgendamentosComFalha(),
            onVoltar: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nova Consulta').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Nova Consulta'));
    await tester.pumpAndSettle();
    await _selecionarDiaFuturo(tester, _diaProximoMes());
    expect(
      find.textContaining('Não foi possível consultar os horários:'),
      findsOneWidget,
    );
    expect(find.byType(ServicosPage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
