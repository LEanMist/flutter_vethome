import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';

class _InvalidStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async =>
      LocalLoadResult.invalid(StateError('falha simulada de leitura'));

  @override
  Future<void> save(LocalState state) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'perfil mantém nome original quando a persistência está bloqueada',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await VetRepository.initialize(storage: _InvalidStorage());
      final originalName = VetRepository.clientName;

      await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('profile-change-name-action')),
      );
      await tester.pumpAndSettle();

      final input = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(input, 'Nome não salvo');
      await tester.tap(find.widgetWithText(TextButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(VetRepository.clientName, originalName);
      expect(find.text(originalName), findsOneWidget);
      expect(
        find.text(
          'O armazenamento local está protegido. Nenhuma alteração foi feita.',
        ),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
