import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/config_page.dart';

class _ConflictStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) async {
    throw LocalStorageConflictException.modified();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Configurações explica o conflito com outra aba', (tester) async {
    await VetRepository.initialize(storage: _ConflictStorage());
    await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));

    await tester.runAsync(() async {
      VetRepository.addPet(
        name: 'Pet em conflito',
        species: 'Cachorro',
        sex: 'Macho',
        weightKg: 10,
        birthDate: DateTime(2020),
        breed: 'SRD',
      );
      expect(await VetRepository.flush(), isFalse);
    });
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Outra janela alterou os dados salvos.'),
      findsOneWidget,
    );
    final reopen = find.widgetWithText(
      TextButton,
      'Reabra o VetHome para carregar a versão atual',
    );
    expect(reopen, findsOneWidget);
    expect(tester.widget<TextButton>(reopen).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
