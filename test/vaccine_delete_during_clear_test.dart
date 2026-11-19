import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/vacinacao_page.dart';

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

  testWidgets('excluir vacina durante limpeza preserva o cartão', (
    tester,
  ) async {
    final storage = _BlockingClearVaccineStorage();
    await VetRepository.initialize(storage: storage);
    final pet = VetRepository.pets.first;
    VetRepository.saveVaccine(
      pet.id,
      Vacina(
        id: 'vaccine-during-clear',
        nome: 'Dose existente',
        aplicada: DateTime(2020, 1, 1),
      ),
    );
    expect(await VetRepository.flush(), isTrue);

    await tester.pumpWidget(MaterialApp(home: VacinacaoPage(pet: pet)));
    await tester.pumpAndSettle();
    final options = find.byTooltip('Opções da vacina Dose existente');
    await tester.ensureVisible(options);
    await tester.tap(options);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();

    late Future<bool> clearing;
    await tester.runAsync(() async {
      clearing = VetRepository.clearLocalData();
      await storage.clearStarted.future.timeout(const Duration(seconds: 3));
    });
    addTearDown(() async {
      if (!storage.finishClear.isCompleted) storage.finishClear.complete();
      await clearing;
    });

    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Dose existente'), findsOneWidget);
    expect(find.text(_clearingMessage), findsOneWidget);
    expect(VetRepository.realVaccines(pet.id), hasLength(1));
    expect(tester.takeException(), isNull);

    storage.finishClear.complete();
    expect(await clearing, isTrue);
    await tester.pumpAndSettle();
  });
}
