import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/config_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailingSaveStorage extends LocalStorage {
  @override
  Future<void> save(LocalState state) async =>
      throw StateError('gravação indisponível');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('sair com alterações não salvas exige confirmação', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await VetRepository.initialize(storage: _FailingSaveStorage());
    VetRepository.addPet(
      name: 'Pet pendente',
      species: 'Cachorro',
      sex: 'Macho',
      weightKg: 10,
      birthDate: DateTime(2020),
      breed: 'SRD',
    );
    expect(await VetRepository.flush(), isFalse);
    expect(VetRepository.unsavedChanges.value, isTrue);
    expect(VetRepository.savingChanges.value, isFalse);

    await tester.pumpWidget(
      MaterialApp(
        home: const ConfigScreen(),
        routes: {'/login': (_) => const Text('Tela de login')},
      ),
    );

    Future<void> pumpUi() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    await pumpUi();
    Future<void> openUnsavedConfirmation() async {
      final signOut = find.widgetWithText(ListTile, 'Sair');
      await tester.ensureVisible(signOut);
      await pumpUi();
      await tester.tap(signOut);
      await pumpUi();
      await tester.tap(find.widgetWithText(TextButton, 'Sair'));
      await pumpUi();
    }

    await openUnsavedConfirmation();
    expect(find.text('Sair com alterações não salvas?'), findsOneWidget);
    expect(find.text('Tela de login'), findsNothing);
    expect(VetRepository.unsavedChanges.value, isTrue);

    await tester.tap(find.text('Continuar editando'));
    await pumpUi();
    expect(find.byType(ConfigScreen), findsOneWidget);

    await openUnsavedConfirmation();
    await tester.tap(find.text('Sair mesmo assim'));
    await pumpUi();
    expect(find.text('Tela de login'), findsOneWidget);
    expect(await VetRepository.clearLocalData(), isTrue);
    expect(tester.takeException(), isNull);
  });
}
