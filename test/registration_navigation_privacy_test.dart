import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/cadastro_page.dart';
import 'package:flutter_vethome/pages/endereco_page.dart';
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
      'CPF': '12345678900',
      'Telefone/Celular': '11999999999',
      'E-mail': 'cliente@example.test',
      'Senha': password,
      'Confirmar Senha': password,
    }.entries) {
      await fill(tester, entry.key, entry.value);
    }

    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Endereço aberto'), findsOneWidget);
    expectNoPassword(received);
  });

  testWidgets('endereço remove senhas recebidas antes de abrir /cadastroPet', (
    tester,
  ) async {
    useLargeViewport(tester);
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

    await tester.ensureVisible(find.text('Pular por enquanto'));
    await tester.tap(find.text('Pular por enquanto'));
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
      'CPF': '12345678900',
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
}
