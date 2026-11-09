import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/widgets/pet_form.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('editar pet informa quando a limpeza bloqueia salvar e excluir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pet = VetRepository.pets.first;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetForm(
            title: 'Editar pet',
            pet: pet,
            onSaved: (_) async => throw const PersistenceClearingException(),
            onDelete: () async => throw const PersistenceClearingException(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    const feedback =
        'Os dados locais estão sendo limpos. Nenhuma alteração foi feita.';
    final save = find.widgetWithText(ElevatedButton, 'Salvar alterações');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text(feedback), findsOneWidget);
    expect(tester.widget<ElevatedButton>(save).onPressed, isNotNull);
    expect(tester.takeException(), isNull);

    ScaffoldMessenger.of(
      tester.element(find.byType(PetForm)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    final delete = find.widgetWithText(TextButton, 'Excluir pet');
    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();

    expect(find.text(feedback), findsOneWidget);
    expect(tester.widget<TextButton>(delete).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
