import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/cadastro_page.dart';
import 'package:flutter_vethome/pages/menu_page.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/services/cep_lookup_service.dart';

void main() {
  testWidgets('password focus border fills the complete field height', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: InformacoesCadastroPage()));

    for (final index in [13, 14]) {
      final passwordField = find.byType(TextField).at(index);
      await tester.ensureVisible(passwordField);
      await tester.tap(passwordField);
      await tester.pump();

      final inputDecorator = find.descendant(
        of: passwordField,
        matching: find.byType(InputDecorator),
      );
      expect(tester.getSize(inputDecorator).height, 50);
      final decoration = tester
          .widget<InputDecorator>(inputDecorator)
          .decoration;
      expect(
        decoration.contentPadding!.resolve(TextDirection.ltr).vertical,
        greaterThan(0),
      );
    }
  });

  testWidgets('does not save an empty registration', (tester) async {
    final repository = InMemoryUsuarioRepository();

    await tester.pumpWidget(
      MaterialApp(home: InformacoesCadastroPage(usuarioRepository: repository)),
    );

    final botaoCadastrar = find.text('Cadastrar');
    await tester.ensureVisible(botaoCadastrar);
    await tester.tap(botaoCadastrar);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repository.findAll(), isEmpty);
    expect(find.text('Informe seu nome completo.'), findsWidgets);
    expect(find.text('Informe sua data de nascimento.'), findsOneWidget);
  });

  testWidgets('saves a valid registration', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = InMemoryUsuarioRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: InformacoesCadastroPage(
          usuarioRepository: repository,
          cepLookupService: _FakeCepLookupService(),
        ),
      ),
    );

    Future<void> preencherCampo(int index, String valor) async {
      final campo = find.byType(TextField).at(index);
      await tester.ensureVisible(campo);
      await tester.enterText(campo, valor);
    }

    await preencherCampo(0, 'Ana Souza');

    final campoData = find.byType(TextField).at(1);
    await tester.ensureVisible(campoData);
    await tester.tap(campoData);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final campoGenero = find.byType(TextField).at(2);
    await tester.ensureVisible(campoGenero);
    await tester.tap(campoGenero);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Feminino'));
    await tester.pumpAndSettle();

    await preencherCampo(3, '52998224725');
    await preencherCampo(4, '11987654321');
    await preencherCampo(5, '11987654321');
    await preencherCampo(6, '01001000');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).at(7)).controller!.text,
      'Rua das Flores',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(9)).controller!.text,
      'São Paulo',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(8)).controller!.text,
      isEmpty,
    );
    await preencherCampo(8, '42');
    await preencherCampo(10, 'Apto 2');
    await preencherCampo(11, 'ana@example.com');
    await preencherCampo(12, 'ana@example.com');
    await preencherCampo(13, 'SenhaForte1');
    await preencherCampo(14, 'SenhaForte1');

    final botaoCadastrar = find.text('Cadastrar');
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    await tester.tap(botaoCadastrar);

    await tester.pump();
    expect(repository.findAll(), hasLength(1));
    expect(repository.findAll().single.nome, 'Ana Souza');
    expect(repository.findByEmail('ana@example.com'), isNotNull);
    expect(
      repository.autenticar('ana@example.com', 'SenhaForte1')?.email,
      'ana@example.com',
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(MenuPage), findsOneWidget);
    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Souza'), findsOneWidget);
  });

  for (final caso in ['rua', 'cidade', 'inexistente', 'sem rua', 'falha']) {
    testWidgets('não cadastra quando a confirmação do CEP falha: $caso', (
      tester,
    ) async {
      final repository = InMemoryUsuarioRepository();
      var chamadas = 0;
      final service = _FakeCepLookupService((_) async {
        chamadas++;
        if (chamadas == 1) {
          return const EnderecoCep(
            logradouro: 'Rua das Flores',
            cidade: 'São Paulo',
          );
        }
        if (caso == 'falha') throw Exception('rede');
        if (caso == 'inexistente') return null;
        if (caso == 'sem rua') {
          return const EnderecoCep(logradouro: '', cidade: 'São Paulo');
        }
        return const EnderecoCep(
          logradouro: 'Rua das Flores',
          cidade: 'São Paulo',
        );
      });
      await _preencherCadastro(tester, repository, service);
      if (caso == 'rua' || caso == 'cidade') {
        final campo = find.byType(TextField).at(caso == 'rua' ? 7 : 9);
        await tester.ensureVisible(campo);
        await tester.enterText(campo, 'Divergente');
      }
      final botao = find.text('Cadastrar');
      await tester.ensureVisible(botao);
      await tester.tap(botao);
      await tester.pumpAndSettle();
      expect(repository.findAll(), isEmpty);
      expect(find.byType(InformacoesCadastroPage), findsOneWidget);
      final mensagem = caso == 'falha'
          ? 'Não foi possível consultar o CEP. Tente novamente.'
          : caso == 'inexistente' || caso == 'sem rua'
          ? 'Não foi possível confirmar a rua e a cidade para este CEP.'
          : 'A rua ou a cidade não corresponde ao CEP informado.';
      expect(find.text(mensagem), findsWidgets);
    });
  }

  testWidgets(
    'não cadastra dados alterados durante a consulta nem consulta duas vezes',
    (tester) async {
      final repository = InMemoryUsuarioRepository();
      final pendente = Completer<EnderecoCep?>();
      var chamadas = 0;
      final service = _FakeCepLookupService((_) {
        chamadas++;
        if (chamadas == 1) {
          return Future.value(
            const EnderecoCep(
              logradouro: 'Rua das Flores',
              cidade: 'São Paulo',
            ),
          );
        }
        return pendente.future;
      });
      await _preencherCadastro(tester, repository, service);
      final botao = find.text('Cadastrar');
      await tester.ensureVisible(botao);
      await tester.tap(botao);
      await tester.pump();
      await tester.tap(botao);
      expect(chamadas, 2);
      final campoEmail = find.byType(TextField).at(11);
      await tester.ensureVisible(campoEmail);
      await tester.enterText(campoEmail, 'novo@example.com');
      pendente.complete(
        const EnderecoCep(logradouro: 'Rua das Flores', cidade: 'São Paulo'),
      );
      await tester.pumpAndSettle();
      expect(repository.findAll(), isEmpty);
      expect(
        find.text('Os dados mudaram. Cadastre novamente.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'consulta automática não substitui endereço editado enquanto espera',
    (tester) async {
      final pendente = Completer<EnderecoCep?>();
      await tester.pumpWidget(
        MaterialApp(
          home: InformacoesCadastroPage(
            usuarioRepository: InMemoryUsuarioRepository(),
            cepLookupService: _FakeCepLookupService((_) => pendente.future),
          ),
        ),
      );
      final cep = find.byType(TextField).at(6);
      final endereco = find.byType(TextField).at(7);
      final cidade = find.byType(TextField).at(9);
      await tester.ensureVisible(cep);
      await tester.enterText(cep, '01001000');
      await tester.ensureVisible(endereco);
      await tester.enterText(endereco, 'Rua digitada');
      await tester.ensureVisible(cidade);
      await tester.enterText(cidade, 'Cidade digitada');
      pendente.complete(
        const EnderecoCep(
          logradouro: 'Rua consultada',
          cidade: 'Cidade consultada',
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(endereco).controller!.text,
        'Rua digitada',
      );
      expect(
        tester.widget<TextField>(cidade).controller!.text,
        'Cidade digitada',
      );
    },
  );
}

class _FakeCepLookupService implements CepLookupService {
  _FakeCepLookupService([this.resposta]);

  final Future<EnderecoCep?> Function(String)? resposta;

  @override
  Future<EnderecoCep?> consultar(String cep) async {
    if (resposta != null) return resposta!(cep);
    return const EnderecoCep(logradouro: 'Rua das Flores', cidade: 'São Paulo');
  }
}

Future<void> _preencherCadastro(
  WidgetTester tester,
  InMemoryUsuarioRepository repository,
  CepLookupService service,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: InformacoesCadastroPage(
        usuarioRepository: repository,
        cepLookupService: service,
      ),
    ),
  );
  Future<void> preencher(int index, String valor) async {
    final campo = find.byType(TextField).at(index);
    await tester.ensureVisible(campo);
    await tester.enterText(campo, valor);
  }

  await preencher(0, 'Ana Souza');
  await tester.ensureVisible(find.byType(TextField).at(1));
  await tester.tap(find.byType(TextField).at(1));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byType(TextField).at(2));
  await tester.tap(find.byType(TextField).at(2));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Feminino'));
  await tester.pumpAndSettle();
  await preencher(3, '52998224725');
  await preencher(4, '11987654321');
  await preencher(5, '11987654321');
  await preencher(6, '01001000');
  await tester.pumpAndSettle();
  await preencher(8, '42');
  await preencher(11, 'ana@example.com');
  await preencher(12, 'ana@example.com');
  await preencher(13, 'SenhaForte1');
  await preencher(14, 'SenhaForte1');
}
