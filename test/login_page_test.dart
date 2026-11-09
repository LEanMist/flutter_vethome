import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/pages/menu_page.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';

void main() {
  testWidgets('rejects empty credentials', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);

    await tester.pumpWidget(
      MaterialApp(home: LoginPage(usuarioRepository: repository)),
    );

    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(
      find.text('Informe seu usuário ou e-mail e sua senha.'),
      findsOneWidget,
    );
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('rejects invalid credentials', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);

    await tester.pumpWidget(
      MaterialApp(home: LoginPage(usuarioRepository: repository)),
    );
    await tester.enterText(find.byType(TextField).at(0), 'naoexiste');
    await tester.enterText(find.byType(TextField).at(1), 'senhaerrada');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Usuário/e-mail ou senha inválidos.'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('allows login with seeded test account email', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);

    await tester.pumpWidget(
      MaterialApp(home: LoginPage(usuarioRepository: repository)),
    );
    await tester.enterText(
      find.byType(TextField).at(0),
      InMemoryUsuarioRepository.usuarioTesteEmail,
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      InMemoryUsuarioRepository.usuarioTesteSenha,
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.byType(MenuPage), findsOneWidget);
  });

  testWidgets('allows login with seeded test account username', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    await tester.pumpWidget(
      MaterialApp(home: LoginPage(usuarioRepository: repository)),
    );
    await tester.enterText(
      find.byType(TextField).at(0),
      InMemoryUsuarioRepository.usuarioTesteNome,
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      InMemoryUsuarioRepository.usuarioTesteSenha,
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.byType(MenuPage), findsOneWidget);
  });
}
