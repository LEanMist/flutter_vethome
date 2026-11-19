import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/vacinacao_page.dart';
import 'package:flutter_vethome/models/vet_models.dart';
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

class _BlockedVaccineStorage extends LocalStorage {
  int saveCalls = 0;

  @override
  Future<LocalLoadResult> load() async =>
      const LocalLoadResult.invalid(FormatException('snapshot bloqueado'));

  @override
  Future<void> save(LocalState state) async {
    saveCalls++;
  }
}

class _InstantVaccineStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = _VaccineStorage();
  setUp(() => VetRepository.initialize(storage: storage));

  const blockedMessage =
      'Armazenamento local bloqueado. Nenhuma alteração na vacina foi realizada.';

  Finder vaccineInput(String label) => find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == label,
    ),
    matching: find.byType(TextFormField),
  );

  Future<void> seedExistingVaccine() async {
    await VetRepository.initialize(storage: _InstantVaccineStorage());
    final pet = VetRepository.pets.first;
    VetRepository.saveVaccine(
      pet.id,
      Vacina(nome: 'Dose existente', aplicada: DateTime(2020, 1, 1)),
    );
    expect(await VetRepository.flush(), isTrue);
  }

  testWidgets('cadastro bloqueado conserva o editor e não adiciona vacina', (
    tester,
  ) async {
    final blocked = _BlockedVaccineStorage();
    await tester.runAsync(() => VetRepository.initialize(storage: blocked));
    final pet = VetRepository.pets.first;
    await tester.pumpWidget(MaterialApp(home: VacinacaoPage(pet: pet)));
    await tester.tap(find.text('Adicionar vacina'));
    await tester.pumpAndSettle();

    await tester.enterText(vaccineInput('Nome da vacina'), 'Dose impedida');
    await tester.enterText(vaccineInput('Data aplicada'), '01012020');
    await tester.ensureVisible(find.text('Salvar vacina'));
    await tester.tap(find.text('Salvar vacina'));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar vacina'), findsWidgets);
    expect(
      find.byKey(const ValueKey('vaccine-storage-blocked-message')),
      findsOneWidget,
    );
    expect(find.text(blockedMessage), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(vaccineInput('Nome da vacina'))
          .controller!
          .text,
      'Dose impedida',
    );
    expect(VetRepository.realVaccines(pet.id), isEmpty);
    expect(blocked.saveCalls, 0);
    expect(find.text('Salvando…'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edição bloqueada conserva os valores preenchidos no editor', (
    tester,
  ) async {
    await tester.runAsync(seedExistingVaccine);
    final pet = VetRepository.pets.first;
    await tester.pumpWidget(MaterialApp(home: VacinacaoPage(pet: pet)));
    await tester.pumpAndSettle();
    final options = find.byTooltip('Opções da vacina Dose existente');
    await tester.ensureVisible(options);
    await tester.tap(options);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();

    final blocked = _BlockedVaccineStorage();
    await tester.runAsync(() => VetRepository.initialize(storage: blocked));
    await tester.enterText(vaccineInput('Nome da vacina'), 'Dose editada');
    await tester.ensureVisible(find.text('Salvar vacina'));
    await tester.tap(find.text('Salvar vacina'));
    await tester.pumpAndSettle();

    expect(find.text('Editar vacina'), findsOneWidget);
    expect(find.text(blockedMessage), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(vaccineInput('Nome da vacina'))
          .controller!
          .text,
      'Dose editada',
    );
    expect(blocked.saveCalls, 0);
    expect(find.text('Salvar vacina'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exclusão bloqueada mantém cartão e mostra aviso distinto', (
    tester,
  ) async {
    await tester.runAsync(seedExistingVaccine);
    final pet = VetRepository.pets.first;
    await tester.pumpWidget(MaterialApp(home: VacinacaoPage(pet: pet)));
    await tester.pumpAndSettle();
    final options = find.byTooltip('Opções da vacina Dose existente');
    await tester.ensureVisible(options);
    await tester.tap(options);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    final blocked = _BlockedVaccineStorage();
    await tester.runAsync(() => VetRepository.initialize(storage: blocked));
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Dose existente'), findsOneWidget);
    expect(find.text(blockedMessage), findsOneWidget);
    expect(
      find.text(
        'Alteração na carteira feita nesta sessão. Não foi possível salvar localmente.',
      ),
      findsNothing,
    );
    expect(blocked.saveCalls, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('carteira acompanha gravações mesmo após fechar o editor', (
    tester,
  ) async {
    const vaccine = 'Dose de teste';
    final pet = VetRepository.pets.first;
    await tester.pumpWidget(MaterialApp(home: VacinacaoPage(pet: pet)));
    await tester.tap(find.text('Adicionar vacina'));
    await tester.pumpAndSettle();
    Finder input(String label) => find.descendant(
      of: find.byWidgetPredicate((w) => w is VHField && w.label == label),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(input('Nome da vacina'), vaccine);
    await tester.enterText(input('Data aplicada'), '01012020');
    await tester.ensureVisible(find.text('Salvar vacina'));
    await tester.tap(find.text('Salvar vacina'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(storage.writes, hasLength(1));
    expect(find.text('Salvando…'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Salvando…'), findsNothing);
    expect(find.text(vaccine), findsOneWidget);
    final add = find.widgetWithText(TextButton, 'Adicionar vacina');
    expect(tester.widget<TextButton>(add).onPressed, isNull);

    const message =
        'Alteração na carteira feita nesta sessão. Não foi possível salvar localmente.';
    Future<void> failWrite() async {
      storage.writes.last.completeError(StateError('falha simulada'));
      await tester.runAsync(() async {
        expect(await VetRepository.flush(), isFalse);
      });
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
    }

    await failWrite();
    ScaffoldMessenger.of(
      tester.element(find.byType(VacinacaoPage)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    final options = find.byTooltip('Opções da vacina $vaccine');
    await tester.ensureVisible(options);
    await tester.tap(options);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(storage.writes, hasLength(2));
    expect(find.text(vaccine), findsNothing);
    expect(tester.widget<TextButton>(add).onPressed, isNull);
    await failWrite();
    expect(VetRepository.realVaccines(pet.id), isEmpty);
    expect(tester.widget<TextButton>(add).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
