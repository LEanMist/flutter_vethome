import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/vacinacao_page.dart';
import 'package:flutter_vethome/widgets.dart';

class _VaccineStorage extends LocalStorage {
  final writes = <Completer<void>>[];

  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) {
    final write = Completer<void>();
    writes.add(write);
    return write.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = _VaccineStorage();
  setUp(() => VetRepository.initialize(storage: storage));

  Finder vaccineInput(String label) => find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == label,
    ),
    matching: find.byType(TextFormField),
  );

  testWidgets('ações salvas confirmam cadastro, edição e carteira vazia', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    await tester.pumpWidget(MaterialApp(home: VacinacaoPage(pet: pet)));
    var completedWrites = storage.writes.length;

    Future<void> finishPendingSave() async {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      expect(storage.writes, hasLength(completedWrites + 1));
      storage.writes[completedWrites].complete();
      completedWrites++;
      await tester.runAsync(() async {
        expect(await VetRepository.flush(), isTrue);
      });
      await tester.pumpAndSettle();
    }

    void expectLiveMessage(String text) {
      final message = find.text(text);
      expect(message, findsOneWidget);
      expect(
        find.ancestor(
          of: message,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.liveRegion == true,
          ),
        ),
        findsWidgets,
      );
    }

    await tester.tap(find.text('Adicionar vacina'));
    await tester.pumpAndSettle();
    await tester.enterText(vaccineInput('Nome da vacina'), 'Dose real');
    await tester.enterText(vaccineInput('Data aplicada'), '01012020');
    await tester.tap(find.text('Salvar vacina'));
    await finishPendingSave();
    expectLiveMessage('Vacina cadastrada.');
    expect(find.text('Dose real'), findsOneWidget);

    await tester.tap(find.byTooltip('Opções da vacina Dose real'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(vaccineInput('Nome da vacina'), 'Dose atualizada');
    await tester.tap(find.text('Salvar vacina'));
    await finishPendingSave();
    expectLiveMessage('Vacina atualizada.');
    expect(find.text('Dose atualizada'), findsOneWidget);

    await tester.tap(find.byTooltip('Opções da vacina Dose atualizada'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await finishPendingSave();

    expectLiveMessage(
      'Vacina removida. A carteira ficou sem vacinas cadastradas.',
    );
    expect(find.text('Nenhuma vacina cadastrada'), findsOneWidget);
    expect(VetRepository.realVaccines(pet.id), isEmpty);
    expect(VetRepository.usesDemoVaccines(pet.id), isFalse);
    ScaffoldMessenger.of(
      tester.element(find.byType(VacinacaoPage)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
