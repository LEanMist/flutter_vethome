import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/vacinacao_page.dart';
import 'package:flutter_vethome/widgets.dart';

const _clearingMessage =
    'A alteração na carteira foi bloqueada enquanto os dados locais estavam '
    'sendo limpos. Nenhuma alteração foi realizada.';

class _BlockingClearVaccineStorage extends LocalStorage {
  final clearStarted = Completer<void>();
  final finishClear = Completer<void>();

  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) async {}

  @override
  Future<void> clear() async {
    clearStarted.complete();
    await finishClear.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Finder vaccineInput(String label) => find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == label,
    ),
    matching: find.byType(TextFormField),
  );

  testWidgets('salvar vacina durante limpeza preserva editor e campos', (
    tester,
  ) async {
    final storage = _BlockingClearVaccineStorage();
    await VetRepository.initialize(storage: storage);
    final pet = VetRepository.pets.first;
    await tester.pumpWidget(MaterialApp(home: VacinacaoPage(pet: pet)));
    await tester.tap(find.text('Adicionar vacina'));
    await tester.pumpAndSettle();
    await tester.enterText(
      vaccineInput('Nome da vacina'),
      'Dose durante limpeza',
    );
    await tester.enterText(vaccineInput('Data aplicada'), '01012020');

    late Future<bool> clearing;
    await tester.runAsync(() async {
      clearing = VetRepository.clearLocalData();
      await storage.clearStarted.future.timeout(const Duration(seconds: 3));
    });
    addTearDown(() async {
      if (!storage.finishClear.isCompleted) storage.finishClear.complete();
      await clearing;
    });

    await tester.ensureVisible(find.text('Salvar vacina'));
    await tester.tap(find.text('Salvar vacina'));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar vacina'), findsWidgets);
    expect(
      find.byKey(const ValueKey('vaccine-storage-clearing-message')),
      findsOneWidget,
    );
    expect(find.text(_clearingMessage), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(vaccineInput('Nome da vacina'))
          .controller!
          .text,
      'Dose durante limpeza',
    );
    expect(VetRepository.realVaccines(pet.id), isEmpty);
    expect(tester.takeException(), isNull);

    storage.finishClear.complete();
    expect(await clearing, isTrue);
    await tester.pumpAndSettle();
  });
}
