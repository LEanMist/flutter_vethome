import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/pages/finalizar_agendamento_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/services/cep_lookup_service.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/botao_estilizado.dart';
import 'package:flutter_vethome/widgets/calendario.dart';
import 'package:flutter_vethome/widgets/campo_cadastro.dart';
import 'package:flutter_vethome/widgets/etiqueta_perfil.dart';
import 'package:flutter_vethome/widgets/endereco.dart';
import 'package:flutter_vethome/widgets/seletor_horario.dart';

void main() {
  for (final tipo in [PetType.cachorro, PetType.gato]) {
    testWidgets('resumo mostra nome e ícone de $tipo sem foto', (tester) async {
      await _abrirFinalizacao(tester, petTipo: tipo);
      final resumo = find.byKey(const ValueKey('resumo-Pet'));
      expect(find.descendant(of: resumo, matching: find.text('Luna')), findsOneWidget);
      expect(
        tester.getRect(resumo).bottom,
        lessThanOrEqualTo(tester.getRect(find.byKey(const ValueKey('resumo-Serviços'))).top),
      );
      final imagem = tester.widget<Image>(
        find.descendant(of: resumo, matching: find.byType(Image)),
      );
      expect(
        tester.getSize(find.descendant(of: resumo, matching: find.byType(Image))),
        const Size(56, 56),
      );
      final asset = imagem.image as AssetImage;
      expect(
        asset.assetName,
        tipo == PetType.gato
            ? 'assets/imagens/gato.png'
            : 'assets/imagens/cachorro.png',
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('rolagem da finalização respeita os limites em $platform', (tester) async {
      await _abrirFinalizacao(
        tester,
        platform: platform,
        tamanhoTela: const Size(320, 640),
      );
      final lista = find.descendant(
        of: find.byType(FinalizarAgendamentoPage),
        matching: find.byType(ListView),
      );
      final scroll = tester.state<ScrollableState>(
        find.descendant(of: lista, matching: find.byType(Scrollable)),
      );
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      final barra = find.ancestor(of: lista, matching: find.byType(Scrollbar));
      expect(tester.widget<Scrollbar>(barra).thumbVisibility, isTrue);
      expect(tester.widget<Scrollbar>(barra).interactive, isTrue);
      final tema = tester.widget<ScrollbarTheme>(
        find.ancestor(of: barra, matching: find.byType(ScrollbarTheme)).first,
      );
      expect(tema.data.thumbColor!.resolve({}), VetCores.marrom);
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
        const Offset(0, 80),
      );
      await tester.pumpAndSettle();
      expect(scroll.position.pixels, greaterThan(0));
      scroll.position.jumpTo(scroll.position.minScrollExtent);
      await tester.pumpAndSettle();
      expect(find.byType(StretchingOverscrollIndicator), findsNothing);
      expect(find.byType(GlowingOverscrollIndicator), findsNothing);

      final inicio = await tester.startGesture(tester.getCenter(lista));
      await inicio.moveBy(const Offset(0, 300));
      await tester.pump();
      expect(scroll.position.pixels, scroll.position.minScrollExtent);
      await inicio.up();
      await tester.pumpAndSettle();

      await tester.drag(lista, const Offset(0, -3000));
      await tester.pumpAndSettle();
      await tester.drag(lista, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(scroll.position.pixels, scroll.position.maxScrollExtent);
      final fim = await tester.startGesture(tester.getCenter(lista));
      await fim.moveBy(const Offset(0, -300));
      await tester.pump();
      expect(scroll.position.pixels, scroll.position.maxScrollExtent);
      await fim.up();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('descricao-agendamento')), findsOneWidget);
      expect(find.byKey(const ValueKey('salvar-agendamento')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('número do endereço aceita apenas dígitos', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<EnderecoUsuario>(
                context: context,
                builder: (_) => const NovoEndereco(),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    final numero = find.descendant(
      of: find.byKey(const ValueKey('novo-endereco-número')),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(numero);
    await tester.enterText(numero, '12a -3');
    final campo = tester.widget<TextField>(numero);
    expect(campo.keyboardType, TextInputType.number);
    expect(campo.controller!.text, '123');
  });

  testWidgets('edição não salva número antigo com caracteres não numéricos', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<EnderecoUsuario>(
                context: context,
                builder: (_) => const NovoEndereco(
                  enderecoInicial: EnderecoUsuario(
                    nome: 'Casa',
                    cep: '01001000',
                    logradouro: 'Rua Nova',
                    numero: '12A',
                    complemento: '',
                    cidade: 'São Paulo',
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
    final nome = find.descendant(
      of: find.byKey(const ValueKey('novo-endereco-nome do endereço')),
      matching: find.byType(TextField),
    );
    await tester.enterText(nome, 'Trabalho');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(find.text('Informe apenas números'), findsOneWidget);
    expect(find.text('Editar endereço'), findsOneWidget);
  });

  for (final caso in ['inexistente', 'sem rua', 'falha']) {
    testWidgets('não salva edição quando CEP está $caso', (tester) async {
      EnderecoUsuario? resultado;
      final service = _FakeCepLookupService((_) async {
        if (caso == 'falha') throw Exception('rede');
        if (caso == 'sem rua') {
          return const EnderecoCep(logradouro: '', cidade: 'São Paulo');
        }
        return null;
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  resultado = await showDialog<EnderecoUsuario>(
                    context: context,
                    builder: (_) => NovoEndereco(
                      enderecoInicial: const EnderecoUsuario(
                        nome: 'Casa',
                        cep: '01001000',
                        logradouro: 'Rua Nova',
                        numero: '2',
                        complemento: '',
                        cidade: 'São Paulo',
                      ),
                      cepLookupService: service,
                    ),
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      final numero = find.descendant(
        of: find.byKey(const ValueKey('novo-endereco-número')),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(numero);
      await tester.enterText(numero, '3');
      await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
      await tester.pumpAndSettle();
      expect(find.text('Editar endereço'), findsOneWidget);
      expect(resultado, isNull);
      expect(
        find.text(
          caso == 'falha'
              ? 'Não foi possível consultar o CEP. Tente novamente.'
              : 'Não foi possível confirmar a rua e a cidade para este CEP.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(resultado, isNull);
    });
  }

  testWidgets('não salva dados alterados durante a consulta', (tester) async {
    final consulta = Completer<EnderecoCep?>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<EnderecoUsuario>(
                context: context,
                builder: (_) => NovoEndereco(
                  enderecoInicial: const EnderecoUsuario(
                    nome: 'Casa',
                    cep: '01001000',
                    logradouro: 'Rua Nova',
                    numero: '2',
                    complemento: '',
                    cidade: 'São Paulo',
                  ),
                  cepLookupService: _FakeCepLookupService(
                    (_) => consulta.future,
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
    final numero = find.descendant(
      of: find.byKey(const ValueKey('novo-endereco-número')),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(numero);
    await tester.enterText(numero, '3');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pump();
    await tester.enterText(numero, '4');
    consulta.complete(
      const EnderecoCep(logradouro: 'Rua Nova', cidade: 'São Paulo'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Editar endereço'), findsOneWidget);
    expect(find.text('Os dados mudaram. Salve novamente.'), findsOneWidget);
  });

  testWidgets('diálogo reutilizável devolve o endereço à tela que o abriu', (
    tester,
  ) async {
    EnderecoUsuario? resultado;
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                resultado = await showDialog<EnderecoUsuario>(
                  context: context,
                  builder: (_) => NovoEndereco(
                    cepLookupService: _FakeCepLookupService(
                      (_) async => const EnderecoCep(
                        logradouro: 'Rua Teste',
                        cidade: 'São Paulo',
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Abrir formulário'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir formulário'));
    await tester.pumpAndSettle();
    final dialogo = find
        .ancestor(
          of: find.text('Adicionar endereço'),
          matching: find.byType(Material),
        )
        .first;
    final cancelar = find.byType(BotaoEstilizado);
    final salvar = find.byKey(const ValueKey('salvar-novo-endereco'));
    expect(tester.getSize(dialogo).width, 350);
    expect(tester.getSize(cancelar), const Size(125, 49));
    expect(tester.getSize(salvar), tester.getSize(cancelar));
    final primeiroCampo = find.byKey(
      const ValueKey('novo-endereco-nome do endereço'),
    );
    final cepCampo = find.byKey(const ValueKey('novo-endereco-cep'));
    expect(tester.getSize(primeiroCampo).width, 302);
    expect(tester.getRect(primeiroCampo).left, tester.getRect(cepCampo).left);

    await tester.binding.setSurfaceSize(const Size(320, 844));
    await tester.pumpAndSettle();
    expect(tester.getSize(dialogo).width, 280);
    expect(tester.getSize(salvar), tester.getSize(cancelar));
    expect(
      tester.getRect(cancelar).right,
      lessThan(tester.getRect(salvar).left),
    );
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpAndSettle();
    Finder campo(String nome) => find.descendant(
      of: find.byKey(ValueKey('novo-endereco-$nome')),
      matching: find.byType(TextField),
    );
    await tester.enterText(campo('nome do endereço'), 'Casa');
    await tester.enterText(campo('cep'), '01001000');
    await tester.pumpAndSettle();
    await tester.ensureVisible(campo('número'));
    await tester.enterText(campo('número'), '42');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(resultado?.nome, 'Casa');
    expect(resultado?.logradouro, 'Rua Teste');
    expect(resultado?.cidade, 'São Paulo');
    expect(resultado?.numero, '42');
    expect(tester.takeException(), isNull);
  });

  testWidgets('posiciona cancelar e salvar em lados opostos', (tester) async {
    final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    await _abrirFinalizacao(tester, usuarioRepository: usuarios);
    await tester.ensureVisible(
      find.byKey(const ValueKey('adicionar-endereco')),
    );
    await tester.tap(find.byKey(const ValueKey('adicionar-endereco')));
    await tester.pumpAndSettle();

    final cancelar = tester.getRect(find.byType(BotaoEstilizado));
    final salvar = tester.getRect(
      find.byKey(const ValueKey('salvar-novo-endereco')),
    );
    final acoes = tester.getRect(find.byType(OverflowBar));
    expect(cancelar.left - acoes.left, lessThanOrEqualTo(16));
    expect(acoes.right - salvar.right, lessThanOrEqualTo(16));
    expect(cancelar.center.dy, closeTo(salvar.center.dy, 1));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Adicionar endereço'), findsNothing);
    expect(usuarios.findAll().single.enderecosAdicionais, isEmpty);
    expect(tester.takeException(), isNull);
  });

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
    expect(find.text('Falha na consulta. Tente novamente.'), findsOneWidget);
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
      cepLookupService: _FakeCepLookupService(
        (_) async => const EnderecoCep(
          logradouro: 'Rua das Flores',
          cidade: 'São Paulo',
        ),
      ),
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

  testWidgets('exige endereço e aceita criar o primeiro para finalizar', (
    tester,
  ) async {
    final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuario = usuarios.findAll().single;
    usuarios.save(
      usuario.copyWith(
        cep: '',
        endereco: '',
        numero: '',
        complemento: '',
        cidade: '',
      ),
    );
    final agendamentos = await _abrirFinalizacao(
      tester,
      usuarioRepository: usuarios,
      cepLookupService: _FakeCepLookupService(
        (_) async =>
            const EnderecoCep(logradouro: 'Rua Nova', cidade: 'São Paulo'),
      ),
    );
    expect(find.byKey(const ValueKey('endereco-principal')), findsNothing);
    await tester.ensureVisible(
      find.byKey(const ValueKey('salvar-agendamento')),
    );
    await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
    await tester.pumpAndSettle();
    expect(
      find.text('Selecione um endereço para o atendimento.'),
      findsOneWidget,
    );
    expect(await agendamentos.findAll(), isEmpty);

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
    await tester.enterText(campo('cep'), '01001000');
    await tester.pumpAndSettle();
    await tester.ensureVisible(campo('número'));
    await tester.enterText(campo('número'), '42');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(usuarios.findAll().single.nomeEnderecoPrincipal, 'Casa');
    expect(usuarios.findAll().single.endereco, 'Rua Nova');
    expect(usuarios.findAll().single.enderecosAdicionais, isEmpty);
    await tester.ensureVisible(
      find.byKey(const ValueKey('salvar-agendamento')),
    );
    await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
    await tester.pumpAndSettle();
    expect(
      (await agendamentos.findAll()).single.endereco,
      contains('Rua Nova'),
    );
  });

  testWidgets('adapta o cabeçalho ao espaço disponível', (tester) async {
    await _abrirFinalizacao(tester);

    final cabecalho = find
        .ancestor(of: find.text('Finalizar'), matching: find.byType(Container))
        .first;
    expect(tester.getSize(cabecalho).height, 120);

    await tester.binding.setSurfaceSize(const Size(800, 900));
    await tester.pumpAndSettle();
    expect(tester.getSize(cabecalho).height, 160);

    await tester.binding.setSurfaceSize(const Size(800, 600));
    await tester.pumpAndSettle();
    expect(tester.getSize(cabecalho).height, 120);
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

  testWidgets('impede finalizar quando o horário já passou', (tester) async {
    final repository = await _abrirFinalizacao(
      tester,
      data: DateTime.now(),
      horario: '00:00',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('salvar-agendamento')),
    );
    await tester.tap(find.byKey(const ValueKey('salvar-agendamento')));
    await tester.pumpAndSettle();
    expect(
      find.text('Este horário já passou. Escolha outro horário.'),
      findsOneWidget,
    );
    expect(await repository.findAll(), isEmpty);
    expect(find.byType(FinalizarAgendamentoPage), findsOneWidget);
  });

  testWidgets('impede salvar horário reservado durante o rascunho', (
    tester,
  ) async {
    final repository = await _abrirFinalizacao(tester);
    await repository.save(
      Agendamento(
        usuarioId: 'outro-usuario',
        petId: 'outro-pet',
        data: DateTime.now().add(const Duration(days: 1)),
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
    final hoje = DateUtils.dateOnly(
      DateTime.now().add(const Duration(days: 1)),
    );
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
      final hoje = DateUtils.dateOnly(
        DateTime.now().add(const Duration(days: 1)),
      );
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
  DateTime? data,
  String horario = '12:00',
  PetType petTipo = PetType.cachorro,
  TargetPlatform? platform,
  Size tamanhoTela = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(tamanhoTela);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final usuarios =
      usuarioRepository ?? InMemoryUsuarioRepository(incluirUsuarioTeste: true);
  final repository = InMemoryAgendamentoRepository();
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FinalizarAgendamentoPage(
                  rascunho: AgendamentoRascunho(
                    usuarioId: usuarios.findAll().single.id!,
                    petId: 'pet-teste',
                    data: data ?? DateTime.now().add(const Duration(days: 1)),
                    horario: horario,
                    servicos: const [
                      ServicoAgendamento(
                        id: 'hemograma',
                        categoria: CategoriaServico.exames,
                        nome: 'Hemograma',
                      ),
                    ],
                  ),
                  petNome: 'Luna',
                  petTipo: petTipo,
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
