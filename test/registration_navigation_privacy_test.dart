import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/cliente/cadastro_page.dart';
import 'package:flutter_vethome/pages/cliente/pet/cadastroPet_page.dart';
import 'package:flutter_vethome/pages/cliente/endereco/endereco_page.dart';
import 'package:flutter_vethome/routes/app_routes.dart';
import 'package:flutter_vethome/widgets.dart';

class _ImmediateStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) async {}
}

void main() {
  const password = 'senha-apenas-do-formulario';

  setUp(() async {
    await VetRepository.initialize(storage: _ImmediateStorage());
  });

  void useLargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1024, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Finder inputFor(String label) => find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == label,
    ),
    matching: find.byType(TextFormField),
  );

  Future<void> fill(WidgetTester tester, String label, String value) async {
    final input = inputFor(label);
    await tester.ensureVisible(input);
    await tester.enterText(input, value);
  }

  void expectNoPassword(Map<String, String> arguments) {
    expect(
      arguments.keys.where((key) => key.toLowerCase().contains('senha')),
      isEmpty,
    );
    expect(arguments.values, isNot(contains(password)));
  }

  testWidgets('cadastro não envia senhas nos argumentos de /endereco', (
    tester,
  ) async {
    useLargeViewport(tester);
    late Map<String, String> received;
    await tester.pumpWidget(
      MaterialApp(
        home: const CadastroScreen(),
        routes: {
          '/endereco': (context) {
            received = Map<String, String>.from(
              ModalRoute.of(context)!.settings.arguments! as Map,
            );
            return const Scaffold(body: Text('Endereço aberto'));
          },
        },
      ),
    );

    for (final entry in const {
      'Nome Completo': 'Cliente Seguro',
      'Data de Nascimento': '05/02/1995',
      'CPF': '52998224725',
      'Telefone/Celular': '+55 (11) 99999-9999',
      'E-mail': 'cliente+teste@example.test',
      'Senha': password,
      'Confirmar Senha': password,
    }.entries) {
      await fill(tester, entry.key, entry.value);
    }

    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.tap(find.text('Continuar'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Endereço aberto'), findsOneWidget);
    expectNoPassword(received);
    expect(received['client.Telefone/Celular'], '(11) 99999-9999');
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.byType(CadastroScreen), findsOneWidget);
    expect(
      tester.widget<TextFormField>(inputFor('Nome Completo')).controller!.text,
      'Cliente Seguro',
    );
  });

  testWidgets('cadastro rejeita entradas comuns inválidas', (tester) async {
    useLargeViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: CadastroScreen()));

    for (final (label, value, error) in const [
      ('Nome Completo', '   ', 'Preencha este campo'),
      ('Data de Nascimento', '29/02/2023', 'Use uma data válida (DD/MM/AAAA)'),
      ('Data de Nascimento', '01/01/2999', 'Use uma data válida (DD/MM/AAAA)'),
      ('CPF', '11111111111', 'Informe um CPF válido'),
      ('CPF', '52998224726', 'Informe um CPF válido'),
      ('Telefone/Celular', '1199', 'Informe um telefone com 10 ou 11 dígitos'),
      ('E-mail', 'teste@dominio..test', 'Informe um e-mail válido'),
      ('E-mail', 'teste@-dominio.test', 'Informe um e-mail válido'),
      ('Senha', '12345', 'Use ao menos 6 caracteres'),
    ]) {
      await fill(tester, label, value);
      await tester.ensureVisible(find.text('Continuar'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      final field = find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == label,
      );
      expect(
        find.descendant(of: field, matching: find.text(error)),
        findsOneWidget,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('endereço remove senhas recebidas antes de abrir /cadastroPet', (
    tester,
  ) async {
    useLargeViewport(tester);
    VetRepository.clientName = 'Tutor Teste';
    VetRepository.clientEmail = 'tutor@example.test';
    late Map<String, String> received;
    await tester.pumpWidget(
      MaterialApp(
        home: const EnderecoScreen(
          initialData: {
            'client.Senha': password,
            'client.Confirmar Senha': password,
            'flow': 'cadastro',
          },
        ),
        routes: {
          '/cadastroPet': (context) {
            received = Map<String, String>.from(
              ModalRoute.of(context)!.settings.arguments! as Map,
            );
            return const Scaffold(body: Text('Cadastro Pet aberto'));
          },
        },
      ),
    );

    await tester.ensureVisible(find.text('Pular'));
    await tester.tap(find.text('Pular'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cadastro Pet aberto'), findsOneWidget);
    expectNoPassword(received);
    expect(received, containsPair('flow', 'cadastro'));
  });

  testWidgets('confirmação local continua bloqueando senhas diferentes', (
    tester,
  ) async {
    useLargeViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: const CadastroScreen(),
        routes: {
          '/endereco': (_) => const Scaffold(body: Text('Não deve abrir')),
        },
      ),
    );

    for (final entry in const {
      'Nome Completo': 'Cliente Seguro',
      'Data de Nascimento': '05/02/1995',
      'CPF': '52998224725',
      'Telefone/Celular': '11999999999',
      'E-mail': 'cliente@example.test',
      'Senha': password,
      'Confirmar Senha': 'senha-diferente',
    }.entries) {
      await fill(tester, entry.key, entry.value);
    }

    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(find.text('As senhas não coincidem'), findsOneWidget);
    expect(find.text('Não deve abrir'), findsNothing);
  });

  testWidgets('senha mínima conta espaços intencionais e rejeita só espaços', (
    tester,
  ) async {
    useLargeViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: const CadastroScreen(),
        routes: {
          '/endereco': (_) => const Scaffold(body: Text('Etapa endereço')),
        },
      ),
    );

    for (final entry in const {
      'Nome Completo': 'Cliente Seguro',
      'Data de Nascimento': '05/02/1995',
      'CPF': '52998224725',
      'Telefone/Celular': '11999999999',
      'E-mail': 'cliente@example.test',
      'Senha': '      ',
      'Confirmar Senha': '      ',
    }.entries) {
      await fill(tester, entry.key, entry.value);
    }

    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(find.text('Preencha este campo'), findsWidgets);
    expect(find.text('Etapa endereço'), findsNothing);

    await fill(tester, 'Senha', '1234  ');
    await fill(tester, 'Confirmar Senha', '1234  ');
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Etapa endereço'), findsOneWidget);
    expect(find.text('As senhas não coincidem'), findsNothing);
    expect(find.text('Use ao menos 6 caracteres'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pular pet pelo link direto apresenta o cadastro do tutor', (
    tester,
  ) async {
    useLargeViewport(tester);
    await tester.pumpWidget(
      MaterialApp(initialRoute: '/cadastroPet', routes: AppRoutes.routes),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CadastroPetScreen), findsOneWidget);
    expect(find.text('Continuar').hitTestable(), findsOneWidget);
    expect(find.text('Pular').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();
    expect(find.byType(CadastroScreen), findsOneWidget);
    expect(
      find.text(
        'Preencha os dados do tutor. Depois, você pode cadastrar ou pular o pet.',
      ),
      findsOneWidget,
    );
    expect(VetRepository.clientEmail, isEmpty);
  });

  testWidgets(
    'pular por link direto recupera Cadastro e permite omitir endereço',
    (tester) async {
      tester.view.physicalSize = const Size(656, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(initialRoute: '/endereco', routes: AppRoutes.routes),
      );
      await tester.pumpAndSettle();
      final skip = find.text('Pular').hitTestable();
      expect(skip, findsOneWidget);
      await tester.tap(skip);
      await tester.pumpAndSettle();
      expect(find.byType(CadastroScreen), findsOneWidget);
      expect(
        find.text(
          'Preencha os dados do tutor. Depois, você pode pular o endereço.',
        ),
        findsOneWidget,
      );
      expect(VetRepository.clientEmail, isEmpty);

      for (final entry in const {
        'Nome Completo': 'Tutor Teste',
        'Data de Nascimento': '05021995',
        'CPF': '52998224725',
        'Telefone/Celular': '11999999999',
        'E-mail': 'tutor@example.test',
        'Senha': password,
        'Confirmar Senha': password,
      }.entries) {
        await fill(tester, entry.key, entry.value);
        await tester.pump();
      }
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.byType(EnderecoScreen), findsOneWidget);
      expect(skip, findsOneWidget);
      await tester.tap(skip);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(find.byType(CadastroPetScreen), findsOneWidget);
      expect(VetRepository.clientEmail, 'tutor@example.test');
      expect(VetRepository.addresses, isEmpty);
    },
  );
}
