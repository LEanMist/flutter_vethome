import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/cadastro_page.dart';
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
    await tester.pumpAndSettle();

    expect(repository.findAll(), isEmpty);
    expect(find.text('Informe seu nome completo.'), findsWidgets);
    expect(find.text('Informe sua data de nascimento.'), findsOneWidget);
  });

  testWidgets('saves a valid registration', (tester) async {
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

    expect(repository.findAll(), hasLength(1));
    expect(repository.findAll().single.nome, 'Ana Souza');
    expect(repository.findByEmail('ana@example.com'), isNotNull);
  });
}

class _FakeCepLookupService implements CepLookupService {
  @override
  Future<EnderecoCep?> consultar(String cep) async {
    return const EnderecoCep(logradouro: 'Rua das Flores', cidade: 'São Paulo');
  }
}
