import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/core/utils/pet_images.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';

class _BlockedPhotoStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async =>
      const LocalLoadResult.invalid(FormatException('snapshot bloqueado'));
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('foto bloqueada informa que não foi alterada', (tester) async {
    await tester.runAsync(
      () => VetRepository.initialize(storage: _BlockedPhotoStorage()),
    );
    final pet = VetRepository.pets.first;
    final originalPhoto = pet.photoBase64;
    const pickerChannel = MethodChannel('plugins.flutter.io/image_picker');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pickerChannel,
      (call) async => File(PetImages.dog).absolute.path,
    );
    addTearDown(
      () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pickerChannel,
        null,
      ),
    );

    await tester.pumpWidget(MaterialApp(home: DetalhesPetPage(pet: pet)));
    await tester.tap(find.byTooltip('Alterar foto do pet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher da galeria'));
    await tester.pumpAndSettle();

    const warning = 'Armazenamento local bloqueado. A foto não foi alterada.';
    await tester.runAsync(() async {
      for (var attempt = 0; attempt < 50; attempt++) {
        if (find.text(warning).evaluate().isNotEmpty) break;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();

    expect(find.text(warning), findsOneWidget);
    expect(find.text('Não foi possível abrir a imagem.'), findsNothing);
    expect(VetRepository.petById(pet.id)?.photoBase64, originalPhoto);
    expect(tester.takeException(), isNull);
  });
}
