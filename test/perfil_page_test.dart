import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';

void main() {
  testWidgets(
    'opens photo source options when tapping the avatar placeholder',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerfilPage(usuarioRepository: InMemoryUsuarioRepository()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Tirar foto'), findsOneWidget);
      expect(find.text('Escolher da galeria'), findsOneWidget);
    },
  );

  testWidgets('opens photo source options from the profile photo row', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PerfilPage(usuarioRepository: InMemoryUsuarioRepository()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mudar Foto de Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Tirar foto'), findsOneWidget);
    expect(find.text('Escolher da galeria'), findsOneWidget);
  });

  testWidgets('shows the registered birth date below the profile photo', (
    tester,
  ) async {
    final repository = InMemoryUsuarioRepository()
      ..save(
        Usuario(
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
        ),
      );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PerfilPage(usuarioRepository: repository)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('20/05/1990'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows profile edit options without layout errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PerfilPage(usuarioRepository: InMemoryUsuarioRepository()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mudar Foto de Perfil'), findsOneWidget);
    expect(find.text('Mudar Nome de Perfil'), findsOneWidget);
    expect(find.text('Mudar Data de Nascimento'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirms or cancels a profile name edit', (tester) async {
    final repository = InMemoryUsuarioRepository()..save(_usuarioTeste());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PerfilPage(usuarioRepository: repository)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mudar Nome de Perfil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Maria Silva');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repository.findAll().single.nome, 'Ana Souza');

    await tester.tap(find.text('Mudar Nome de Perfil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Maria Silva');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(repository.findAll().single.nome, 'Maria Silva');
    expect(find.text('Maria Silva'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('updates the profile birth date from the date picker', (
    tester,
  ) async {
    final repository = InMemoryUsuarioRepository()..save(_usuarioTeste());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PerfilPage(usuarioRepository: repository)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Mudar Data de Nascimento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mudar Data de Nascimento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(repository.findAll().single.dataNascimento, DateTime(1990, 5, 15));
    expect(find.text('15/05/1990'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
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
