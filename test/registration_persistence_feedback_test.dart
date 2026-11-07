import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/cadastroPet_page.dart';
import 'package:flutter_vethome/pages/endereco_page.dart';

class _RegistrationStorage extends LocalStorage {
  bool fail = false;
  int saveCalls = 0;
  Completer<void>? retry;

  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) async {
    saveCalls++;
    if (!fail) return;
    if (saveCalls == 1) throw StateError('falha simulada no endereço');
    await (retry = Completer<void>()).future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _RegistrationStorage storage;
  setUp(() async {
    storage = _RegistrationStorage();
    await VetRepository.initialize(storage: storage);
  });

  Future<void> skip(
    WidgetTester tester, {
    String label = 'Pular',
  }) async {
    final button = find.widgetWithText(TextButton, label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<void> openRegistration(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const EnderecoScreen(
          initialData: {
            'client.Nome Completo': 'Tutor Teste',
            'client.E-mail': 'tutor@example.test',
          },
        ),
        routes: {
          '/cadastroPet': (context) => CadastroPetScreen(
            initialData:
                ModalRoute.of(context)!.settings.arguments!
                    as Map<String, String>,
          ),
          '/sucesso': (_) => const Scaffold(body: Text('Cadastro concluído')),
        },
      ),
    );
    await skip(tester, label: 'Pular');
    expect(find.byType(CadastroPetScreen), findsOneWidget);
    expect(storage.saveCalls, 1);
  }

  testWidgets(
    'pular pet só tenta gravar novamente se a primeira gravação falhar',
    (tester) async {
      final petCount = VetRepository.pets.length;
      await openRegistration(tester);
      await skip(tester);
      expect(find.text('Cadastro concluído'), findsOneWidget);
      expect(VetRepository.clientName, 'Tutor Teste');
      expect(VetRepository.pets, hasLength(petCount));
      expect(storage.saveCalls, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      storage = _RegistrationStorage()..fail = true;
      final initialized = VetRepository.initialize(storage: storage);
      await tester.pump();
      await initialized;
      await openRegistration(tester);
      await skip(tester);
      expect(find.text('Cadastro concluído'), findsNothing);
      expect(storage.saveCalls, 2);
      final button = find.widgetWithText(TextButton, 'Pular');
      expect(tester.widget<TextButton>(button).onPressed, isNull);

      storage.retry!.completeError(
        StateError('falha simulada na nova tentativa'),
      );
      await tester.runAsync(() async {
        expect(await VetRepository.flush(), isFalse);
      });
      await tester.pumpAndSettle();
      expect(find.text('Cadastro concluído'), findsOneWidget);
      expect(VetRepository.clientName, 'Tutor Teste');
      expect(
        find.text(
          'Dados atualizados nesta sessão. Não foi possível salvar localmente.',
        ),
        findsOneWidget,
      );
    },
  );

}
