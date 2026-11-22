import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class _BlockedPhotoStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async =>
      const LocalLoadResult.invalid(FormatException('snapshot bloqueado'));
}

class _GalleryPicker extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async => XFile.fromData(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGPQCKj4DwADhAHwaWoWWwAAAABJRU5ErkJggg==',
    ),
    name: 'pet.png',
    mimeType: 'image/png',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('foto bloqueada informa que não foi alterada', (tester) async {
    await tester.runAsync(
      () => VetRepository.initialize(storage: _BlockedPhotoStorage()),
    );
    final pet = VetRepository.pets.first;
    final originalPhoto = pet.photoBase64;
    final previousPicker = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = _GalleryPicker();
    addTearDown(() => ImagePickerPlatform.instance = previousPicker);

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
