import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/editar_pet_page.dart';

class _DelayedStorage extends LocalStorage {
  Completer<void>? pendingWrite;

  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) {
    return (pendingWrite = Completer<void>()).future;
  }
}

class _BlockedStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async =>
      LocalLoadResult.invalid(StateError('snapshot inválido simulado'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = _DelayedStorage();
  setUp(() => VetRepository.initialize(storage: storage));

  testWidgets('editor avisa quando salvar ou excluir é bloqueado', (
    tester,
  ) async {
    await tester.runAsync(
      () => VetRepository.initialize(storage: _BlockedStorage()),
    );
    final pet = VetRepository.pets.first;
    await tester.pumpWidget(MaterialApp(home: EditarPetPage(pet: pet)));
    await tester.pumpAndSettle();

    const warning =
        'O armazenamento local está protegido. Nenhuma alteração foi feita.';
    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar alterações');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(find.text(warning), findsOneWidget);
    expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNotNull);

    ScaffoldMessenger.of(
      tester.element(find.byType(EditarPetPage)),
    ).removeCurrentSnackBar();
    await tester.pumpAndSettle();
    final deleteButton = find.widgetWithText(TextButton, 'Excluir pet');
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Excluir'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(warning), findsOneWidget);
    expect(find.byType(EditarPetPage), findsOneWidget);
    expect(tester.widget<TextButton>(deleteButton).onPressed, isNotNull);
    expect(VetRepository.petById(pet.id), same(pet));
    expect(tester.takeException(), isNull);
  });

  testWidgets('exclusão de pet aguarda a gravação e avisa se ela falhar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pet = VetRepository.pets.first;
    final otherId = VetRepository.pets[1].id;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => DetalhesPetPage(pet: pet)),
              ),
              child: const Text('Abrir detalhes'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir detalhes'));
    await tester.pumpAndSettle();
    final editButton = find.byTooltip('Editar');
    await tester.ensureVisible(editButton);
    await tester.tap(editButton);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('edit-pet-extra-fields-toggle')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Excluir'));
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('consultas e vacinas salvas'),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Excluir'),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();

    expect(find.byType(EditarPetPage), findsOneWidget);
    final pendingWrite = storage.pendingWrite!;
    expect(VetRepository.petById(pet.id), isNull);
    expect(VetRepository.petById(otherId), isNotNull);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Excluir'))
          .onPressed,
      isNull,
    );
    await Navigator.of(tester.element(find.byType(EditarPetPage))).maybePop();
    await tester.pumpAndSettle();
    expect(find.byType(EditarPetPage), findsOneWidget);

    pendingWrite.completeError(StateError('falha simulada de gravação'));
    await tester.runAsync(() async {
      expect(await VetRepository.flush(), isFalse);
    });
    await tester.pumpAndSettle();

    expect(find.byType(EditarPetPage), findsNothing);
    expect(find.byType(DetalhesPetPage), findsNothing);
    expect(find.text('Abrir detalhes'), findsOneWidget);
    expect(
      find.text(
        'Pet removido nesta sessão. Não foi possível salvar localmente.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
