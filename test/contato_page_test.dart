import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/pages/contato_page.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';

void main() {
  testWidgets('envia mensagens consecutivas pelo botao', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ContatoPage()),
      ),
    );
    await tester.pumpAndSettle();

    final campo = find.byType(TextField);
    final botaoEnviar = find.byTooltip('Enviar mensagem');

    await tester.enterText(campo, 'Primeira mensagem');
    await tester.tap(botaoEnviar);
    await tester.pumpAndSettle();
    expect(find.text('Primeira mensagem'), findsOneWidget);

    await tester.enterText(campo, 'Segunda mensagem');
    await tester.tap(botaoEnviar);
    await tester.pumpAndSettle();

    expect(find.text('Primeira mensagem'), findsOneWidget);
    expect(find.text('Segunda mensagem'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('usa o nome cadastrado e os estilos definidos', (tester) async {
    final repository = InMemoryUsuarioRepository()
      ..save(_usuarioTeste('Ana Souza'));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContatoPage(usuarioRepository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Mensagem de teste');
    await tester.tap(find.byTooltip('Enviar mensagem'));
    await tester.pumpAndSettle();

    final nome = tester.widget<Text>(find.text('Ana Souza').last);
    final mensagem = tester.widget<Text>(find.text('Mensagem de teste'));
    expect(nome.style?.fontSize, 14);
    expect(nome.style?.fontFamily, startsWith('Comfortaa'));
    expect(mensagem.style?.fontSize, 13);
    expect(mensagem.style?.fontFamily, startsWith('Comfortaa'));
    expect(find.text('Mensagem de teste'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('usa fallback quando nenhum usuario esta cadastrado', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContatoPage(usuarioRepository: InMemoryUsuarioRepository()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Mensagem de teste');
    await tester.tap(find.byTooltip('Enviar mensagem'));
    await tester.pumpAndSettle();

    expect(find.text('Nome não cadastrado'), findsWidgets);
    expect(find.text('Mensagem de teste'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Usuario _usuarioTeste(String nome) {
  return Usuario(
    nome: nome,
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