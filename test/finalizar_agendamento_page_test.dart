import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/finalizar_agendamento_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/services/cep_lookup_service.dart';
import 'package:flutter_vethome/widgets/calendario.dart';
import 'package:flutter_vethome/widgets/campo_cadastro.dart';
import 'package:flutter_vethome/widgets/etiqueta_perfil.dart';
import 'package:flutter_vethome/widgets/seletor_horario.dart';

void main() {
  testWidgets('consulta o CEP e salva logradouro e cidade preenchidos', (
    tester,
  ) async {
    final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final service = _FakeCepLookupService(
      (cep) async =>
          const EnderecoCep(logradouro: 'Praça da Sé', cidade: 'São Paulo'),
    );
    await _abrirFinalizacao(
      tester,
      usuarioRepository: usuarios,
      cepLookupService: service,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('adicionar-endereco')),
    );
    await tester.tap(find.byKey(const ValueKey('adicionar-endereco')));
    await tester.pumpAndSettle();

    Finder campo(String nome) => find.descendant(
      of: find.byKey(ValueKey('novo-endereco-$nome')),
      matching: find.byType(TextField),
    );
    await tester.enterText(campo('nome do endereço'), 'Casa');
    await tester.enterText(campo('cep'), '01001-000');
    await tester.pumpAndSettle();
    expect(service.ceps, ['01001000']);
    expect(
      tester.widget<TextField>(campo('logradouro')).controller!.text,
      'Praça da Sé',
    );
    expect(
      tester.widget<TextField>(campo('cidade')).controller!.text,
      'São Paulo',
    );
    await tester.ensureVisible(campo('número'));
    await tester.enterText(campo('número'), '42');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    final endereco = usuarios.findAll().single.enderecosAdicionais.single;
    expect(endereco.logradouro, 'Praça da Sé');
    expect(endereco.cidade, 'São Paulo');
  });

  testWidgets('ignora respostas de CEP antigo e informa falha de consulta', (
    tester,
  ) async {
    final primeiraConsulta = Completer<EnderecoCep?>();
    final segundaConsulta = Completer<EnderecoCep?>();
    final service = _FakeCepLookupService(
      (cep) =>
          cep == '01001000' ? primeiraConsulta.future : segundaConsulta.future,
    );
    await _abrirFinalizacao(tester, cepLookupService: service);
    await tester.ensureVisible(
      find.byKey(const ValueKey('adicionar-endereco')),
    );
    await tester.tap(find.byKey(const ValueKey('adicionar-endereco')));
    await tester.pumpAndSettle();

    Finder campo(String nome) => find.descendant(
      of: find.byKey(ValueKey('novo-endereco-$nome')),
      matching: find.byType(TextField),
    );
    await tester.enterText(campo('cep'), '01001000');
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.enterText(campo('cep'), '02002000');
    await tester.pump();
    primeiraConsulta.complete(
      const EnderecoCep(logradouro: 'Rua antiga', cidade: 'Cidade antiga'),
    );
    await tester.pump();
    expect(
      tester.widget<TextField>(campo('logradouro')).controller!.text,
      isEmpty,
    );
    segundaConsulta.completeError(Exception('sem conexão'));
    await tester.pumpAndSettle();
    expect(
      find.text('Falha na consulta. Você pode preencher manualmente.'),
      findsOneWidget,
    );
    await tester.enterText(campo('logradouro'), 'Rua manual');
    expect(
      tester.widget<TextField>(campo('logradouro')).controller!.text,
      'Rua manual',
    );
  });

  testWidgets('cadastra novo endereço com campos e validação', (tester) async {
    final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final agendamentos = await _abrirFinalizacao(
      tester,
      usuarioRepository: usuarios,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('adicionar-endereco')),
    );
    await tester.tap(find.byKey(const ValueKey('adicionar-endereco')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widgetList<CampoCadastro>(find.byType(CampoCadastro))
          .map((campo) => campo.titulo),
      [
        'Nome do endereço',
        'CEP',
        'Logradouro',
        'Número',
        'Cidade',
        'Complemento',
      ],
    );
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(find.text('Campo obrigatório'), findsWidgets);
    expect(find.text('Informe um CEP válido'), findsOneWidget);
    expect(usuarios.findAll().single.enderecosAdicionais, isEmpty);

    Future<void> preencher(String chave, String valor) async {
      final campo = find.descendant(
        of: find.byKey(ValueKey('novo-endereco-$chave')),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(campo);
      await tester.enterText(campo, valor);
      await tester.pump();
    }

    await preencher('nome do endereço', 'Casa');
    await preencher('cep', '123');
    await preencher('logradouro', 'Rua das Flores');
    await preencher('número', '42');
    await preencher('cidade', 'São Paulo');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(find.text('Informe um CEP válido'), findsOneWidget);
    expect(usuarios.findAll().single.enderecosAdicionais, isEmpty);

    await preencher('cep', '01001-000');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    final endereco = usuarios.findAll().single.enderecosAdicionais.single;
    expect(endereco.nome, 'Casa');
    expect(endereco.cep, '01001-000');
    expect(endereco.cidade, 'São Paulo');
    expect(endereco.complemento, isEmpty);
    expect(find.byKey(const ValueKey('endereco-adicional-0')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
    await tester.pumpAndSettle();
    expect(
      (await agendamentos.findAll()).single.endereco,
      endereco.enderecoCompleto,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('adapta o cabeçalho ao espaço disponível', (tester) async {
    await _abrirFinalizacao(tester);

    final cabecalho = find
        .ancestor(
          of: find.text('Finalizar agendamento'),
          matching: find.byType(Container),
        )
        .first;
    expect(tester.getSize(cabecalho).height, 116);

    await tester.binding.setSurfaceSize(const Size(800, 900));
    await tester.pumpAndSettle();
    expect(tester.getSize(cabecalho).height, 128);

    await tester.binding.setSurfaceSize(const Size(800, 600));
    await tester.pumpAndSettle();
    expect(tester.getSize(cabecalho).height, 116);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edita o horário usando o seletor reutilizável', (tester) async {
    final repository = await _abrirFinalizacao(tester);

    await tester.tap(find.byKey(const ValueKey('resumo-Horário')));
    await tester.pumpAndSettle();
    expect(find.byType(SeletorHorario), findsOneWidget);
    await tester.tap(find.byTooltip('Fechar horários'));
    await tester.pumpAndSettle();
    expect(find.text('12:00'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('resumo-Horário')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('horario-14:00')));
    await tester.pumpAndSettle();
    expect(find.text('14:00'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
    await tester.pumpAndSettle();
    expect((await repository.findAll()).single.horario, '14:00');
    expect(tester.takeException(), isNull);
  });

  testWidgets('impede salvar horário reservado durante o rascunho', (
    tester,
  ) async {
    final repository = await _abrirFinalizacao(tester);
    await repository.save(
      Agendamento(
        usuarioId: 'outro-usuario',
        petId: 'outro-pet',
        data: DateTime.now(),
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
    await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
    await tester.pumpAndSettle();
    expect(
      find.text('Este horário já foi agendado. Escolha outro horário.'),
      findsOneWidget,
    );
    expect(await repository.findAll(), hasLength(1));

    await tester.tap(find.byKey(const ValueKey('resumo-Horário')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('horario-12:00')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('horario-13:00')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
    await tester.pumpAndSettle();
    expect(await repository.findAll(), hasLength(2));
  });

  testWidgets('ao editar a data mostra quando o dia está lotado', (
    tester,
  ) async {
    final repository = await _abrirFinalizacao(tester);
    final hoje = DateUtils.dateOnly(DateTime.now());
    final data = DateTime(hoje.year, hoje.month + 1, hoje.day == 10 ? 11 : 10);
    for (final horario in ['12:00', '13:00', '14:00', '15:00', '16:00']) {
      await repository.save(
        Agendamento(
          usuarioId: 'outro-usuario',
          petId: 'outro-pet',
          data: data,
          horario: horario,
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
    }

    await _escolherData(tester, data);
    expect(find.text('Todos os horários já foram agendados.'), findsOneWidget);
    for (final horario in ['12:00', '13:00', '14:00', '15:00', '16:00']) {
      expect(
        tester
            .widget<ElevatedButton>(find.byKey(ValueKey('horario-$horario')))
            .onPressed,
        isNull,
      );
    }
    await tester.tap(find.byTooltip('Fechar horários'));
    await tester.pumpAndSettle();
    expect(find.text(_formatarData(hoje)), findsOneWidget);
  });

  testWidgets(
    'edita data com calendário e confirma horário sem alterações parciais',
    (tester) async {
      final repository = await _abrirFinalizacao(tester);
      final hoje = DateUtils.dateOnly(DateTime.now());
      final data = DateTime(
        hoje.year,
        hoje.month + 1,
        hoje.day == 10 ? 11 : 10,
      );
      final dataOriginal = _formatarData(hoje);

      await tester.tap(find.byKey(const ValueKey('resumo-Data')));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarioAgendamento), findsOneWidget);
      expect(find.byType(EtiquetaPerfil), findsNothing);
      final fundo = tester.widget<Container>(
        find.byKey(const ValueKey('fundo-calendario')),
      );
      final borda = (fundo.decoration! as BoxDecoration).borderRadius;
      expect(borda, BorderRadius.circular(26));
      final tamanho = tester.getSize(find.byType(CalendarioAgendamento));
      expect(tamanho.width, greaterThan(340));
      expect(tamanho.height, 323);
      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarioAgendamento), findsOneWidget);
      await tester.tap(find.byTooltip('Fechar calendário'));
      await tester.pumpAndSettle();
      expect(find.text(dataOriginal), findsOneWidget);

      await _escolherData(tester, data);
      expect(find.byType(SeletorHorario), findsOneWidget);
      await tester.tap(find.byTooltip('Fechar horários'));
      await tester.pumpAndSettle();
      expect(find.text(dataOriginal), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);

      await _escolherData(tester, data);
      await tester.tap(find.byKey(const ValueKey('horario-16:00')));
      await tester.pumpAndSettle();
      expect(find.text(_formatarData(data)), findsOneWidget);
      expect(find.text('16:00'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
      await tester.pumpAndSettle();
      final salvo = (await repository.findAll()).single;
      expect(salvo.data, data);
      expect(salvo.horario, '16:00');
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _escolherData(WidgetTester tester, DateTime data) async {
  await tester.tap(find.byKey(const ValueKey('resumo-Data')));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Próximo mês'));
  await tester.pumpAndSettle();
  await tester.tap(
    find.byKey(ValueKey('calendar-day-${data.year}-${data.month}-${data.day}')),
  );
  await tester.pumpAndSettle();
}

String _formatarData(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/'
    '${data.month.toString().padLeft(2, '0')}/${data.year}';

Future<InMemoryAgendamentoRepository> _abrirFinalizacao(
  WidgetTester tester, {
  InMemoryUsuarioRepository? usuarioRepository,
  CepLookupService? cepLookupService,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final usuarios =
      usuarioRepository ?? InMemoryUsuarioRepository(incluirUsuarioTeste: true);
  final repository = InMemoryAgendamentoRepository();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FinalizarAgendamentoPage(
                  rascunho: AgendamentoRascunho(
                    usuarioId: usuarios.findAll().single.id!,
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
                  petNome: 'Luna',
                  petTipo: PetType.cachorro,
                  convenio: ConvenioAgendamento.petlove,
                  usuarioRepository: usuarios,
                  agendamentoRepository: repository,
                  cepLookupService:
                      cepLookupService ??
                      _FakeCepLookupService((_) async => null),
                ),
              ),
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
  return repository;
}

class _FakeCepLookupService implements CepLookupService {
  _FakeCepLookupService(this.resultado);

  final Future<EnderecoCep?> Function(String) resultado;
  final ceps = <String>[];

  @override
  Future<EnderecoCep?> consultar(String cep) {
    ceps.add(cep);
    return resultado(cep);
  }
}
