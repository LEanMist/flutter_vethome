import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/pages/configuracoes_page.dart';
import 'package:flutter_vethome/pages/lista_enderecos.dart';
import 'package:flutter_vethome/pages/menu_page.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/services/cep_lookup_service.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/botao_estilizado.dart';

void main() {
  testWidgets('abre e fecha os dados de suporte', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ConfiguracoesPage())),
    );
    await tester.tap(find.text('Suporte'));
    await tester.pumpAndSettle();
    final dialogo = find.byType(Dialog);
    expect(dialogo, findsOneWidget);
    expect(
      find.descendant(of: dialogo, matching: find.text('Suporte')),
      findsOneWidget,
    );
    expect(find.text('Numero:'), findsOneWidget);
    expect(find.text('11 9793-8918'), findsOneWidget);
    expect(find.text('Email:'), findsOneWidget);
    expect(find.text('Kelvinpro@gmail.com'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(dialogo, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('abre opções de tema sem modificar o aplicativo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ConfiguracoesPage())),
    );
    await tester.tap(find.text('Tema do Aplicativo'));
    await tester.pumpAndSettle();
    expect(find.text('Modo escuro — em breve'), findsOneWidget);
    expect(find.text('Modo personalizado — em breve'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Modo escuro — em breve'), findsNothing);
  });

  testWidgets('lista endereços do usuário do menu e permite voltar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final primeiro = repository.findAll().single;
    repository.save(
      primeiro.copyWith(
        enderecosAdicionais: const [
          EnderecoUsuario(
            nome: 'Casa da avó',
            cep: '12345678',
            logradouro: 'Rua das Flores',
            numero: '42',
            complemento: 'Apto 2',
            cidade: 'São Paulo',
          ),
        ],
      ),
    );
    repository.save(
      Usuario(
        nome: 'Outro Usuário',
        dataNascimento: DateTime(1990),
        genero: GeneroUsuario.outro,
        cpf: '11144477735',
        telefone: '11987654321',
        cep: '01001000',
        endereco: 'Rua de outro usuário',
        numero: '5',
        complemento: '',
        cidade: 'São Paulo',
        email: 'outro@example.com',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MenuPage(usuarioRepository: repository, usuarioId: primeiro.id),
      ),
    );
    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meus Endereços'));
    await tester.pumpAndSettle();
    expect(find.text('Endereços'), findsOneWidget);
    expect(find.text('Endereço principal'), findsOneWidget);
    expect(find.textContaining('Rua de Teste'), findsOneWidget);
    expect(find.text('Casa da avó'), findsOneWidget);
    expect(find.textContaining('Rua das Flores, 42 - Apto 2'), findsOneWidget);
    expect(find.textContaining('Rua de outro usuário'), findsNothing);
    final editar = find.byType(BotaoEstilizado).first;
    final deletar = find.widgetWithText(ElevatedButton, 'Deletar').first;
    expect(tester.widget<BotaoEstilizado>(editar).corFundo, VetCores.branco50);
    expect(tester.widget<BotaoEstilizado>(editar).mostrarSombra, isFalse);
    expect(tester.widget<BotaoEstilizado>(editar).onPressed, isNotNull);
    final botaoDeletar = tester.widget<ElevatedButton>(deletar);
    expect(botaoDeletar.onPressed, isNotNull);
    expect(
      botaoDeletar.style!.backgroundColor!.resolve({}),
      VetCores.vermelhoEscuro,
    );
    expect(tester.getSize(editar), tester.getSize(deletar));
    expect(
      tester.getRect(editar).right,
      lessThan(tester.getRect(deletar).left),
    );
    expect(
      tester.getRect(editar).center.dy,
      closeTo(tester.getRect(deletar).center.dy, 0.1),
    );
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Meus Endereços'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('informa quando o usuário não é encontrado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfiguracoesPage(
            usuarioRepository: InMemoryUsuarioRepository(),
            usuarioId: 'inexistente',
          ),
        ),
      ),
    );
    await tester.tap(find.text('Meus Endereços'));
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível carregar os dados do usuário.'),
      findsOneWidget,
    );
  });

  testWidgets('confirma exclusão, promove o próximo e permite ficar sem endereço', (
    tester,
  ) async {
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuario = repository.findAll().single;
    repository.save(usuario.copyWith(enderecosAdicionais: const [
      EnderecoUsuario(nome: 'Casa', cep: '01001000', logradouro: 'Rua Nova',
          numero: '2', complemento: '', cidade: 'São Paulo'),
    ]));
    await _abrirLista(tester, repository);

    await tester.tap(_botaoDoCartao('Endereço principal', 'Deletar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Não'));
    await tester.pumpAndSettle();
    expect(repository.findAll().single.endereco, 'Rua de Teste');

    await tester.tap(_botaoDoCartao('Endereço principal', 'Deletar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sim'));
    await tester.pumpAndSettle();
    expect(repository.findAll().single.endereco, 'Rua Nova');
    expect(repository.findAll().single.nomeEnderecoPrincipal, 'Casa');
    expect(repository.findAll().single.enderecosAdicionais, isEmpty);
    expect(find.text('Casa'), findsOneWidget);

    await tester.tap(_botaoDoCartao('Casa', 'Deletar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sim'));
    await tester.pumpAndSettle();
    expect(repository.findAll().single.temEnderecoPrincipal, isFalse);
    expect(find.text('Nenhum endereço cadastrado.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edita apenas o endereço escolhido e valida a rua e cidade pelo CEP', (
    tester,
  ) async {
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuario = repository.findAll().single;
    repository.save(usuario.copyWith(enderecosAdicionais: const [
      EnderecoUsuario(nome: 'Casa', cep: '01001000', logradouro: 'Rua Nova',
          numero: '2', complemento: '', cidade: 'São Paulo'),
    ]));
    await _abrirLista(tester, repository, cepLookupService: _CepTeste());
    await tester.tap(_botaoDoCartao('Casa', 'Editar'));
    await tester.pumpAndSettle();
    Finder campo(String nome) => find.descendant(
      of: find.byKey(ValueKey('novo-endereco-$nome')),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(campo('logradouro')).controller!.text, 'Rua Nova');
    expect(tester.widget<TextField>(campo('número')).controller!.text, '2');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(find.text('Primeiro edite algum campo.'), findsOneWidget);

    await tester.ensureVisible(campo('logradouro'));
    await tester.enterText(campo('logradouro'), 'Rua inexistente');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(find.text('A rua ou a cidade não corresponde ao CEP informado.'), findsOneWidget);
    expect(repository.findAll().single.enderecosAdicionais.single.logradouro, 'Rua Nova');

    await tester.enterText(campo('logradouro'), 'Rua Nova');
    await tester.ensureVisible(campo('número'));
    await tester.enterText(campo('número'), '10');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(repository.findAll().single.enderecosAdicionais.single.numero, '10');
    expect(repository.findAll().single.endereco, 'Rua de Teste');
    expect(find.text('Editar endereço'), findsNothing);
    await tester.tap(_botaoDoCartao('Casa', 'Deletar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sim'));
    await tester.pumpAndSettle();
    expect(repository.findAll().single.enderecosAdicionais, isEmpty);
    expect(repository.findAll().single.endereco, 'Rua de Teste');
    expect(tester.takeException(), isNull);
  });

  testWidgets('editar o principal permite cancelar ou salvar sem alterar os adicionais', (
    tester,
  ) async {
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuario = repository.findAll().single;
    repository.save(usuario.copyWith(enderecosAdicionais: const [
      EnderecoUsuario(nome: 'Casa', cep: '01001000', logradouro: 'Rua Nova',
          numero: '2', complemento: '', cidade: 'São Paulo'),
    ]));
    await _abrirLista(tester, repository, cepLookupService: _CepTeste());
    await tester.tap(_botaoDoCartao('Endereço principal', 'Editar'));
    await tester.pumpAndSettle();
    Finder campo(String nome) => find.descendant(
      of: find.byKey(ValueKey('novo-endereco-$nome')),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(campo('número'));
    await tester.enterText(campo('número'), '99');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repository.findAll().single.numero, '1');
    await tester.tap(_botaoDoCartao('Endereço principal', 'Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(campo('logradouro'), 'Rua Nova');
    await tester.enterText(campo('cidade'), 'Outra cidade');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(find.text('A rua ou a cidade não corresponde ao CEP informado.'), findsOneWidget);
    await tester.enterText(campo('cidade'), 'São Paulo');
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(repository.findAll().single.endereco, 'Rua Nova');
    expect(repository.findAll().single.enderecosAdicionais.single.nome, 'Casa');
  });

  testWidgets('lista muitos endereços em tela compacta', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuario = repository.findAll().single;
    repository.save(
      usuario.copyWith(
        enderecosAdicionais: [
          for (var i = 1; i <= 8; i++)
            EnderecoUsuario(
              nome: 'Casa $i',
              cep: '01001000',
              logradouro: 'Rua $i',
              numero: '$i',
              complemento: '',
              cidade: 'São Paulo',
            ),
        ],
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(top: 24, bottom: 32),
            viewPadding: const EdgeInsets.only(top: 24, bottom: 32),
          ),
          child: child!,
        ),
        home: ListaEnderecos(
          usuarioRepository: repository,
          usuarioId: usuario.id,
        ),
      ),
    );
    final botao = find.widgetWithText(ElevatedButton, 'Novo Endereço');
    final posicao = tester.getRect(botao);
    expect(posicao.bottom, lessThanOrEqualTo(640 - 32));
    expect(tester.getRect(find.byType(ListView)).bottom, lessThan(posicao.top));
    await tester.scrollUntilVisible(
      find.text('Casa 8'),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Casa 8'), findsOneWidget);
    expect(tester.getRect(botao), posicao);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adiciona endereço ao usuário e permite cancelar', (tester) async {
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuario = repository.findAll().single;
    await _abrirLista(tester, repository, cepLookupService: _CepTeste());

    await tester.tap(find.text('Novo Endereço'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repository.findById(usuario.id!)!.enderecosAdicionais, isEmpty);

    await tester.tap(find.text('Novo Endereço'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(find.text('Campo obrigatório'), findsWidgets);
    expect(repository.findById(usuario.id!)!.enderecosAdicionais, isEmpty);

    await _preencherNovoEndereco(tester);
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    final salvo = repository.findById(usuario.id!)!;
    expect(salvo.endereco, usuario.endereco);
    expect(salvo.enderecosAdicionais.single.nome, 'Trabalho');
    expect(salvo.enderecosAdicionais.single.logradouro, 'Rua Nova');
    expect(find.text('Trabalho'), findsOneWidget);
    expect(find.text('Endereço adicionado.'), findsOneWidget);
  });

  testWidgets('novo endereço vira principal quando não há endereço', (tester) async {
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuario = repository.findAll().single;
    repository.save(usuario.copyWith(
      cep: '',
      endereco: '',
      numero: '',
      complemento: '',
      cidade: '',
    ));
    await _abrirLista(tester, repository, cepLookupService: _CepTeste());
    expect(find.text('Nenhum endereço cadastrado.'), findsOneWidget);
    await tester.tap(find.text('Novo Endereço'));
    await tester.pumpAndSettle();
    await _preencherNovoEndereco(tester);
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    final salvo = repository.findById(usuario.id!)!;
    expect(salvo.nomeEnderecoPrincipal, 'Trabalho');
    expect(salvo.endereco, 'Rua Nova');
    expect(salvo.enderecosAdicionais, isEmpty);
    expect(find.text('Trabalho'), findsOneWidget);
  });

  testWidgets('informa falha ao salvar novo endereço', (tester) async {
    final repository = _RepositorioComErroAoSalvar();
    await _abrirLista(tester, repository, cepLookupService: _CepTeste());
    await tester.tap(find.text('Novo Endereço'));
    await tester.pumpAndSettle();
    await _preencherNovoEndereco(tester);
    repository.falhar = true;
    await tester.tap(find.byKey(const ValueKey('salvar-novo-endereco')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Não foi possível salvar o endereço:'), findsOneWidget);
    expect(repository.findAll().single.enderecosAdicionais, isEmpty);
    expect(find.text('Endereço adicionado.'), findsNothing);
  });

  testWidgets('endereço comprido quebra linhas sem sair do cartão', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const endereco = EnderecoUsuario(
      nome: 'Casa',
      cep: '12345678',
      logradouro:
          'Rua das Flores e das Palmeiras com um nome bastante comprido '
          'próximo à Praça das Árvores e à Avenida das Hortênsias '
          'no bairro de Vila Jardim das Estações',
      numero: '123',
      complemento: 'Apartamento 42 bloco B',
      cidade: 'São Paulo',
    );
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuario = repository.findAll().single;
    repository.save(usuario.copyWith(enderecosAdicionais: [endereco]));
    await tester.pumpWidget(
      MaterialApp(
        home: ListaEnderecos(
          usuarioRepository: repository,
          usuarioId: usuario.id,
        ),
      ),
    );
    await tester.pumpAndSettle();
    Finder cartao(Finder texto) => find
        .ancestor(
          of: texto,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration != null &&
                (widget.constraints?.minHeight ?? 0) > 0,
          ),
        )
        .first;
    final cartaoCurto = cartao(find.text('Endereço principal'));
    final alturaCurta = tester.getSize(cartaoCurto).height;
    expect(alturaCurta, greaterThan(0));
    await tester.ensureVisible(find.text(endereco.enderecoCompleto));
    await tester.pumpAndSettle();
    final cartaoLongo = cartao(find.text(endereco.enderecoCompleto));
    expect(tester.getSize(cartaoLongo).height, greaterThan(alturaCurta));
    final botoes = find.descendant(
      of: cartaoLongo,
      matching: find.widgetWithText(ElevatedButton, 'Deletar'),
    );
    expect(
      tester.getRect(botoes).bottom,
      lessThan(tester.getRect(cartaoLongo).bottom),
    );
    final texto = tester.getRect(find.text(endereco.enderecoCompleto));
    double linhaDeBase(Finder finder) {
      final box = tester.renderObject<RenderBox>(finder);
      return tester.getTopLeft(finder).dy +
          box.getDryBaseline(box.constraints, TextBaseline.alphabetic)!;
    }

    Finder rotulo(String conteudo, String rotulo) => find.descendant(
      of: find
          .ancestor(of: find.text(conteudo), matching: find.byType(Row))
          .first,
      matching: find.text(rotulo),
    );
    expect(
      linhaDeBase(find.text(endereco.nome)),
      closeTo(linhaDeBase(rotulo(endereco.nome, 'Nome:')), 0.1),
    );
    expect(
      linhaDeBase(find.text(endereco.enderecoCompleto)),
      closeTo(linhaDeBase(rotulo(endereco.enderecoCompleto, 'Endereço:')), 0.1),
    );
    expect(texto.height, greaterThan(30));
    expect(texto.right, lessThanOrEqualTo(320 - 20 - 16));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _preencherNovoEndereco(WidgetTester tester) async {
  Future<void> preencher(String nome, String valor) async {
    final campo = find.descendant(
      of: find.byKey(ValueKey('novo-endereco-$nome')),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(campo);
    await tester.enterText(campo, valor);
    await tester.pumpAndSettle();
  }

  await preencher('nome do endereço', 'Trabalho');
  await preencher('cep', '01001000');
  await preencher('número', '42');
}

Future<void> _abrirLista(
  WidgetTester tester,
  InMemoryUsuarioRepository repository, {
  CepLookupService? cepLookupService,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    home: ListaEnderecos(
      usuarioRepository: repository,
      usuarioId: repository.findAll().single.id,
      cepLookupService: cepLookupService,
    ),
  ));
  await tester.pumpAndSettle();
}

Finder _botaoDoCartao(String nome, String botao) {
  final cartao = find.ancestor(
    of: find.text(nome),
    matching: find.byWidgetPredicate(
      (widget) => widget is Container &&
          widget.decoration != null &&
          (widget.constraints?.minHeight ?? 0) > 0,
    ),
  ).first;
  return find.descendant(
    of: cartao,
    matching: botao == 'Editar'
        ? find.byType(BotaoEstilizado)
        : find.widgetWithText(ElevatedButton, botao),
  );
}

class _CepTeste implements CepLookupService {
  @override
  Future<EnderecoCep?> consultar(String cep) async =>
      const EnderecoCep(logradouro: 'Rua Nova', cidade: 'São Paulo');
}

class _RepositorioComErroAoSalvar extends InMemoryUsuarioRepository {
  _RepositorioComErroAoSalvar() : super(incluirUsuarioTeste: true);

  bool falhar = false;

  @override
  void save(Usuario usuario, {String? senha}) {
    if (falhar) throw StateError('Falha ao salvar');
    super.save(usuario, senha: senha);
  }
}
