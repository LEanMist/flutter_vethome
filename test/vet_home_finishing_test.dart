import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vethome/core/utils/pet_images.dart';
import 'package:flutter_vethome/core/utils/pet_photo.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/pages/editar_pet_page.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/saude_page.dart';
import 'package:flutter_vethome/pages/vacinacao_page.dart';
import 'package:flutter_vethome/pages/agendamentos_page.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/screens/auth.dart';
import 'package:flutter_vethome/screens/pets.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/pet_avatar.dart';
import 'package:flutter_vethome/widgets/pet_form.dart';
import 'package:flutter_vethome/widgets/pet_summary.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late String photo;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
    final bytes = await rootBundle.load(PetImages.dog);
    photo = base64Encode(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
  });
  tearDown(() async => VetRepository.flush());
  Finder field(String label) => find.descendant(
    of: find.byWidgetPredicate((w) => w is VHField && w.label == label),
    matching: find.byType(TextFormField),
  );
  void viewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  test('foto local serializa/restaura sem mudar schema ou ID', () async {
    final pet = VetRepository.pets.first;
    expect(await VetRepository.updatePetPhoto(pet.id, photo), isTrue);
    final stored = (await SharedPreferences.getInstance()).getString(
      LocalStorage.stateKey,
    )!;
    expect(jsonDecode(stored)['schemaVersion'], 1);
    await VetRepository.initialize();
    expect(VetRepository.petById(pet.id)!.photoBase64, photo);
    expect(VetRepository.petById(pet.id)!.id, pet.id);
  });
  test('foto só muda o pet escolhido; renomear preserva foto e ID', () async {
    final pet = VetRepository.pets.first, other = VetRepository.pets[1];
    await VetRepository.updatePetPhoto(pet.id, photo);
    final updated = VetRepository.petById(pet.id)!;
    VetRepository.updatePet(
      updated,
      updated.copyWith(name: 'Pet com foto renomeado'),
    );
    await VetRepository.initialize();
    expect(VetRepository.petById(pet.id)!.photoBase64, photo);
    expect(VetRepository.petById(other.id)!.photoBase64, isNull);
    VetRepository.removePet(VetRepository.petById(pet.id)!);
    await VetRepository.initialize();
    expect(VetRepository.petById(pet.id), isNull);
  });
  test('snapshot antigo sem foto e foto inválida mantêm dados/fallback', () {
    final old = VetRepository.pets.first.toJson()..remove('photoBase64');
    expect(PetModel.fromJson(old).photoBase64, isNull);
    old['photoBase64'] = 'blob:temporario';
    expect(PetModel.fromJson(old).photoBase64, isNull);
    expect(PetModel.fromJson(old).id, VetRepository.pets.first.id);
  });
  test('foto excessiva é rejeitada sem alterar o pet', () async {
    final pet = VetRepository.pets.first;
    expect(PetPhoto.isValid('x' * (PetPhoto.maxEncodedLength + 1)), isFalse);
    await expectLater(
      VetRepository.updatePetPhoto(pet.id, 'inválida'),
      throwsFormatException,
    );
    expect(VetRepository.petById(pet.id)!.photoBase64, isNull);
  });
  testWidgets('foto usa MemoryImage no avatar e prioriza a silhueta', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetAvatar(
            image: PetImages.cat,
            species: 'Gato',
            photoBase64: photo,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as ResizeImage).imageProvider, isA<MemoryImage>());
    expect(tester.takeException(), isNull);
  });
  for (final size in [const Size(390, 844), const Size(320, 640)]) {
    testWidgets(
      'formulários de pet cabem em $size e sexo/peso ficam lado a lado',
      (tester) async {
        viewport(tester, size);
        for (final editing in [false, true]) {
          await tester.pumpWidget(
            MaterialApp(
              home: editing
                  ? EditarPetPage(pet: VetRepository.pets.first)
                  : const CadastroPetScreen(),
            ),
          );
          await tester.pumpAndSettle();
          final sex = field(editing ? 'Sexo' : 'Gênero/Sexo'),
              weight = field(editing ? 'Peso (kg)' : 'Peso');
          expect(
            tester.getTopLeft(sex).dy,
            closeTo(tester.getTopLeft(weight).dy, 1),
          );
          expect(
            tester.getTopLeft(sex).dx,
            lessThan(tester.getTopLeft(weight).dx),
          );
          expect(
            tester
                .widget<TextField>(
                  find.descendant(of: sex, matching: find.byType(TextField)),
                )
                .decoration!
                .labelText,
            'Sexo',
          );
          expect(
            find.descendant(
              of: find.byType(PetForm),
              matching: find.byType(SingleChildScrollView),
            ),
            findsNothing,
          );
          expect(
            tester
                .getBottomRight(
                  find.text(editing ? 'Excluir pet' : 'Pular por enquanto'),
                )
                .dy,
            lessThan(size.height),
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
    testWidgets(
      'Espécie/Sexo abrem abaixo do campo, uma lista por vez em $size',
      (tester) async {
        viewport(tester, size);
        for (final editing in [false, true]) {
          await tester.pumpWidget(
            MaterialApp(
              key: UniqueKey(),
              home: editing
                  ? EditarPetPage(pet: VetRepository.pets.first)
                  : const CadastroPetScreen(),
            ),
          );
          await tester.pumpAndSettle();
          final species = field(editing ? 'Espécie' : 'Tipo de Animal');
          await tester.tap(species);
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsNothing);
          expect(find.byType(SimpleDialog), findsNothing);
          final cat = find.widgetWithText(ListTile, 'Gato');
          expect(
            tester.getTopLeft(cat).dy,
            greaterThanOrEqualTo(tester.getBottomRight(species).dy),
          );
          await tester.tap(species);
          await tester.pumpAndSettle();
          expect(cat, findsNothing);
          await tester.tap(field(editing ? 'Sexo' : 'Gênero/Sexo'));
          await tester.pumpAndSettle();
          expect(cat, findsNothing);
          await tester.tap(find.widgetWithText(ListTile, 'Fêmea'));
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<TextFormField>(field(editing ? 'Sexo' : 'Gênero/Sexo'))
                .controller!
                .text,
            'Fêmea',
          );
          expect(find.widgetWithText(ListTile, 'Fêmea'), findsNothing);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
  testWidgets('Gênero inline mantém Outro e descrição personalizada', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CadastroScreen()));
    await tester.ensureVisible(field('Gênero/Sexo'));
    await tester.tap(field('Gênero/Sexo'));
    await tester.pumpAndSettle();
    expect(find.byType(SimpleDialog), findsNothing);
    await tester.tap(find.widgetWithText(ListTile, 'Outro'));
    await tester.pumpAndSettle();
    expect(find.text('Como deseja informar? (opcional)'), findsOneWidget);
  });
  testWidgets(
    'picker real compartilhado prepara uma miniatura local no cadastro',
    (tester) async {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/image_picker'),
        (call) async => File(PetImages.dog).absolute.path,
      );
      addTearDown(
        () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/image_picker'),
          null,
        ),
      );
      await tester.pumpWidget(const MaterialApp(home: CadastroPetScreen()));
      await tester.tap(find.byTooltip('Alterar foto do pet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Escolher da galeria'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        // The engine decodes/re-encodes the actual selected PNG asynchronously.
        for (var attempt = 0; attempt < 50; attempt++) {
          if (tester.widget<PetAvatar>(find.byType(PetAvatar)).photoBase64 !=
              null) {
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await tester.pump();
        }
      });
      await tester.pumpAndSettle();
      expect(
        tester.widget<PetAvatar>(find.byType(PetAvatar)).photoBase64,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'foto aparece nas superfícies e telas críticas não têm overflow em 320',
    (tester) async {
      viewport(tester, const Size(320, 640));
      final pet = VetRepository.pets.first;
      await tester.runAsync(() => VetRepository.updatePetPhoto(pet.id, photo));
      VetRepository.selectedPetId = pet.id;
      for (final screen in [
        DetalhesPetPage(pet: pet),
        SaudePage(pet: pet),
        VacinacaoPage(pet: pet),
        AgendamentosPage(pet: pet),
        const ServicosScreen(),
        const ConvenioScreen(),
        NovaConsultaPage(pet: pet, service: 'V10', plan: 'Particular'),
      ]) {
        await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: screen));
        await tester.pumpAndSettle();
        expect(
          tester.widget<PetAvatar>(find.byType(PetAvatar).first).photoBase64,
          photo,
        );
        expect(find.byType(PetSummary), findsOneWidget);
        expect(
          tester.takeException(),
          isNull,
          reason: screen.runtimeType.toString(),
        );
      }
    },
  );
}
