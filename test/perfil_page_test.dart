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
}
