import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/config_page.dart';

class _RetryStorage extends LocalStorage {
  int writes = 0;
  Completer<void>? retry;
  LocalState? saved;

  @override
  Future<LocalLoadResult> load() async => saved == null
      ? const LocalLoadResult.empty()
      : LocalLoadResult.valid(saved!);

  @override
  Future<void> save(LocalState state) async {
    if (++writes == 1) throw StateError('falha simulada');
    await (retry = Completer<void>()).future;
    saved = state;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = _RetryStorage();
  setUp(() => VetRepository.initialize(storage: storage));

  testWidgets('Configurações permite salvar a sessão após falha de gravação', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));
    final retry = find.widgetWithText(TextButton, 'Tentar salvar novamente');
    expect(retry, findsNothing);

    final petCount = VetRepository.pets.length;
    final pet = (await tester.runAsync(() async {
      final created = VetRepository.addPet(
        name: 'Pet da sessão',
        species: 'Cachorro',
        sex: 'Macho',
        weightKg: 10,
        birthDate: DateTime(2020),
        breed: 'SRD',
      );
      expect(await VetRepository.flush(), isFalse);
      return created;
    }))!;
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    final pending = find.widgetWithText(TextButton, 'Salvando…');
    expect(tester.widget<TextButton>(pending).onPressed, isNull);
    expect(
      identical(VetRepository.retrySave(), VetRepository.retrySave()),
      isTrue,
    );
    expect(storage.writes, 2);

    storage.retry!.completeError(StateError('segunda falha simulada'));
    await tester.pumpAndSettle();
    expect(retry, findsOneWidget);
    expect(find.text('A gravação ainda não foi concluída.'), findsOneWidget);

    await tester.tap(retry);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(storage.writes, 3);
    storage.retry!.complete();
    await tester.pumpAndSettle();
    expect(retry, findsNothing);
    expect(find.text('Alterações salvas no dispositivo.'), findsOneWidget);
    expect(storage.saved!.pets, hasLength(petCount + 1));
    expect(
      storage.saved!.pets.where((item) => item.id == pet.id),
      hasLength(1),
    );
    expect(await VetRepository.flush(), isTrue);
  });
}
