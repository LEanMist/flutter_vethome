import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/usuario.dart';
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
    expect(find.text('Informe seu e-mail e sua senha.'), findsOneWidget);
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

    expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
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

  testWidgets('rejects login with username even with the correct password', (
    tester,
  ) async {
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
    expect(find.byType(MenuPage), findsNothing);
    expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
  });

  testWidgets('opens the profile for the authenticated user', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true)
      ..save(_usuarioAna(), senha: 'SenhaForte1');

    await tester.pumpWidget(
      MaterialApp(home: LoginPage(usuarioRepository: repository)),
    );
    await tester.enterText(find.byType(TextField).at(0), 'ana@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'SenhaForte1');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text('Usuario Teste'), findsNothing);
  });

  testWidgets(
    'confirma saída, limpa a navegação e permite entrar em outra conta',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = InMemoryUsuarioRepository(incluirUsuarioTeste: true)
        ..save(_usuarioAna(), senha: 'SenhaForte1');
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LoginPage(usuarioRepository: repository),
                  ),
                ),
                child: const Text('Iniciar'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Iniciar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'ana@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'SenhaForte1');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Configurações'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();
      expect(find.text('Deseja sair da sua conta?'), findsOneWidget);
      await tester.tap(find.text('Não'));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
      expect(find.text('Deseja sair da sua conta?'), findsNothing);

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sim'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(MenuPage), findsNothing);
      expect(navigatorKey.currentState!.canPop(), isFalse);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        isEmpty,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        isEmpty,
      );
      expect(repository.findByEmail('ana@example.com'), isNotNull);

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
      await tester.tap(find.byTooltip('Perfil'));
      await tester.pumpAndSettle();
      expect(find.text('Usuario Teste'), findsOneWidget);
      expect(find.text('Ana Souza'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'pet cadastrado aparece somente para seu usuário após trocar de conta',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true)
        ..save(_usuarioAna(), senha: 'SenhaForte1');
      await tester.pumpWidget(
        MaterialApp(home: LoginPage(usuarioRepository: usuarios)),
      );
      Future<void> entrar(String email, String senha) async {
        await tester.enterText(find.byType(TextField).at(0), email);
        await tester.enterText(find.byType(TextField).at(1), senha);
        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();
      }

      Future<void> sair() async {
        await tester.tap(find.byTooltip('Configurações'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sair'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sim'));
        await tester.pumpAndSettle();
      }

      await entrar('ana@example.com', 'SenhaForte1');
      await tester.tap(find.byTooltip('Adicionar pet'));
      await tester.pumpAndSettle();
      final campos = find.byType(TextField);
      await tester.ensureVisible(campos.at(0));
      await tester.tap(campos.at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cachorro'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(campos.at(1));
      await tester.enterText(campos.at(1), 'Luna da Ana');
      await tester.ensureVisible(campos.at(3));
      await tester.enterText(campos.at(3), '4');
      await tester.ensureVisible(campos.at(5));
      await tester.enterText(campos.at(5), 'Poodle');
      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();
      expect(find.text('Luna da Ana'), findsOneWidget);

      await sair();
      await entrar(
        InMemoryUsuarioRepository.usuarioTesteEmail,
        InMemoryUsuarioRepository.usuarioTesteSenha,
      );
      expect(find.text('Luna da Ana'), findsNothing);
      expect(find.text('Nenhum pet cadastrado ainda.'), findsOneWidget);
      await tester.tap(find.byTooltip('Agendamentos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agendar consulta'));
      await tester.pumpAndSettle();
      expect(
        find.text('Cadastre um pet primeiro para agendar consulta.'),
        findsOneWidget,
      );
      expect(find.text('Luna da Ana'), findsNothing);

      await sair();
      await entrar('ana@example.com', 'SenhaForte1');
      expect(find.text('Luna da Ana'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Usuario _usuarioAna() {
  return Usuario(
    nome: 'Ana Souza',
    dataNascimento: DateTime(1990, 5, 20),
    genero: GeneroUsuario.feminino,
    cpf: '111.444.777-35',
    telefone: '11987654321',
    cep: '01001000',
    endereco: 'Rua das Flores',
    numero: '42',
    complemento: '',
    cidade: 'São Paulo',
    email: 'ana@example.com',
  );
}
