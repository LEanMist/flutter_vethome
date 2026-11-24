import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/veterinario/gabriela_profile_repository.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_area_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const _photoKey = 'vethome.gabriela.photo.v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await VetRepository.flush();
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
    await GabrielaProfileRepository.initialize();
  });

  tearDown(() async {
    await VetRepository.flush();
  });

  test('perfil sem dados salvos usa Gabriela e nascimento em branco', () {
    expect(GabrielaProfileRepository.name, 'Gabriela');
    expect(GabrielaProfileRepository.birthDate, isNull);
    expect(GabrielaProfileRepository.photoBytes, isNull);
    expect(GabrielaProfileRepository.readFailed, isFalse);
  });

  test(
    'nome, nascimento e foto da Gabriela sobrevivem à reinicialização',
    () async {
      final birthDate = DateTime(1995, 6, 17);
      final photo = await _photo(const ui.Color(0xFFFF0000));
      await GabrielaProfileRepository.updateName('Dra. Gabriela');
      await GabrielaProfileRepository.updateBirthDate(birthDate);
      await GabrielaProfileRepository.updatePhoto(photo);

      await GabrielaProfileRepository.initialize();

      expect(GabrielaProfileRepository.name, 'Dra. Gabriela');
      expect(GabrielaProfileRepository.birthDate, birthDate);
      expect(GabrielaProfileRepository.photoBytes, base64Decode(photo));
      expect(GabrielaProfileRepository.readFailed, isFalse);
    },
  );

  test('perfis e fotos do Cliente e da Gabriela ficam separados', () async {
    final clientBirthDate = DateTime(1980, 4, 3);
    final clientPhoto = await _photo(const ui.Color(0xFFFF0000));
    final vetBirthDate = DateTime(1995, 6, 17);
    final vetPhoto = await _photo(const ui.Color(0xFF0000FF));
    VetRepository.updateClient(name: 'Cliente', birthDate: clientBirthDate);
    expect(await VetRepository.updateClientPhoto(clientPhoto), isTrue);

    await GabrielaProfileRepository.updateName('Dra. Gabriela');
    await GabrielaProfileRepository.updateBirthDate(vetBirthDate);
    await GabrielaProfileRepository.updatePhoto(vetPhoto);
    expect(VetRepository.clientName, 'Cliente');
    expect(VetRepository.clientBirthDate, clientBirthDate);
    expect(VetRepository.clientPhotoBase64, clientPhoto);

    VetRepository.updateClient(
      name: 'Outro cliente',
      birthDate: DateTime(1988),
    );
    await VetRepository.flush();
    await VetRepository.initialize();
    await GabrielaProfileRepository.initialize();

    expect(VetRepository.clientName, 'Outro cliente');
    expect(VetRepository.clientPhotoBase64, clientPhoto);
    expect(GabrielaProfileRepository.name, 'Dra. Gabriela');
    expect(GabrielaProfileRepository.birthDate, vetBirthDate);
    expect(GabrielaProfileRepository.photoBytes, base64Decode(vetPhoto));
  });

  test('foto inválida armazenada preserva os demais dados do perfil', () async {
    final preferences = await SharedPreferences.getInstance();
    await GabrielaProfileRepository.updateName('Dra. Gabriela');
    await GabrielaProfileRepository.updateBirthDate(DateTime(1995, 6, 17));
    await preferences.setString(_photoKey, 'foto inválida');

    await GabrielaProfileRepository.initialize();

    expect(GabrielaProfileRepository.name, 'Dra. Gabriela');
    expect(GabrielaProfileRepository.birthDate, DateTime(1995, 6, 17));
    expect(GabrielaProfileRepository.photoBytes, isNull);
    expect(GabrielaProfileRepository.readFailed, isTrue);
    expect(preferences.getString(_photoKey), 'foto inválida');
  });

  test('rejeita arquivos inválidos ou acima do limite da miniatura', () async {
    final photo = await _photo(const ui.Color(0xFFFF0000));
    await GabrielaProfileRepository.updatePhoto(photo);

    for (final invalid in [
      'foto inválida',
      await _photo(const ui.Color(0xFF0000FF), width: 257),
    ]) {
      await expectLater(
        GabrielaProfileRepository.updatePhoto(invalid),
        throwsFormatException,
      );
    }

    await GabrielaProfileRepository.initialize();
    expect(GabrielaProfileRepository.photoBytes, base64Decode(photo));
    expect(GabrielaProfileRepository.readFailed, isFalse);
  });

  test(
    'falha na gravação mantém a foto anterior em memória e no disco',
    () async {
      final photo = await _photo(const ui.Color(0xFFFF0000));
      final replacement = await _photo(const ui.Color(0xFF0000FF));
      SharedPreferences.setMockInitialValues({_photoKey: photo});
      SharedPreferencesStorePlatform.instance = _PhotoWriteFailure(photo);
      await GabrielaProfileRepository.initialize();

      await expectLater(
        GabrielaProfileRepository.updatePhoto(replacement),
        throwsStateError,
      );
      expect(GabrielaProfileRepository.photoBytes, base64Decode(photo));

      await GabrielaProfileRepository.initialize();
      expect(GabrielaProfileRepository.photoBytes, base64Decode(photo));
    },
  );
  testWidgets('perfil e ações são acessíveis em quatro tamanhos de tela', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [
      const Size(390, 844),
      const Size(320, 640),
      const Size(390, 500),
      const Size(800, 900),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(size),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(size.width == 320 ? 2 : 1),
            ),
            child: child!,
          ),
          home: const GabrielaAreaPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Perfil').hitTestable(), findsOneWidget);
      expect(find.text('Gabriela'), findsOneWidget);

      final action = find.text('Mudar Data de Nascimento');
      final list = find.descendant(
        of: find.byType(GabrielaProfileTab),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(action, 90, scrollable: list);
      await tester.pumpAndSettle();
      expect(action.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

class _PhotoWriteFailure extends InMemorySharedPreferencesStore {
  _PhotoWriteFailure(String photo)
    : super.withData({'flutter.$_photoKey': photo});

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    return key == 'flutter.$_photoKey'
        ? false
        : super.setValue(valueType, key, value);
  }
}

Future<String> _photo(ui.Color color, {int width = 1}) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(color, ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, 1);
  final data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
  image.dispose();
  picture.dispose();
  return base64Encode(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
}
