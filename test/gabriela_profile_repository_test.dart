import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/gabriela_profile_repository.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test('perfil inicial tem nome e nenhum nascimento atribuído', () {
    expect(GabrielaProfileRepository.name, 'Gabriela');
    expect(GabrielaProfileRepository.birthDate, isNull);
  });

  test('foto é restaurada e uma imagem inválida preserva a foto salva', () async {
    const photo =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aBhoAAAAASUVORK5CYII=';
    await GabrielaProfileRepository.updatePhoto(photo);
    await expectLater(
      GabrielaProfileRepository.updatePhoto('imagem inválida'),
      throwsFormatException,
    );

    await GabrielaProfileRepository.initialize();
    expect(GabrielaProfileRepository.photoBytes, base64Decode(photo));
    expect(VetRepository.clientPhotoBytes, isNull);
  });

  test('nome e nascimento da Gabriela sobrevivem à reinicialização', () async {
    final birthDate = DateTime(1995, 6, 17);
    await GabrielaProfileRepository.updateName('Dra. Gabriela');
    await GabrielaProfileRepository.updateBirthDate(birthDate);

    await GabrielaProfileRepository.initialize();

    expect(GabrielaProfileRepository.name, 'Dra. Gabriela');
    expect(GabrielaProfileRepository.birthDate, birthDate);
  });

  test('alterações da Gabriela não modificam os dados do cliente', () async {
    final clientBirthDate = DateTime(1980, 4, 3);
    final clientPhoto = Uint8List.fromList([1, 2, 3]);
    VetRepository.updateClient(name: 'Cliente', birthDate: clientBirthDate);
    VetRepository.clientPhotoBytes = clientPhoto;
    await VetRepository.flush();

    await GabrielaProfileRepository.updateName('Gabriela');
    await GabrielaProfileRepository.updateBirthDate(DateTime(1995, 6, 17));

    expect(VetRepository.clientName, 'Cliente');
    expect(VetRepository.clientBirthDate, clientBirthDate);
    expect(VetRepository.clientPhotoBytes, same(clientPhoto));
    expect(GabrielaProfileRepository.photoBytes, isNull);

    await VetRepository.initialize();
    await GabrielaProfileRepository.initialize();
    expect(VetRepository.clientName, 'Cliente');
    expect(VetRepository.clientBirthDate, clientBirthDate);
    expect(GabrielaProfileRepository.name, 'Gabriela');
    expect(GabrielaProfileRepository.birthDate, DateTime(1995, 6, 17));
  });

  test('alterações do cliente não modificam o perfil da Gabriela', () async {
    await GabrielaProfileRepository.updateName('Gabriela');
    await GabrielaProfileRepository.updateBirthDate(DateTime(1995, 6, 17));

    VetRepository.updateClient(
      name: 'Outro cliente',
      birthDate: DateTime(1988),
    );
    await VetRepository.flush();
    await GabrielaProfileRepository.initialize();

    expect(GabrielaProfileRepository.name, 'Gabriela');
    expect(GabrielaProfileRepository.birthDate, DateTime(1995, 6, 17));
  });
}
