import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vethome/core/utils/pet_images.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/pages/agendamentos_page.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/editar_pet_page.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/pages/saude_page.dart';
import 'package:flutter_vethome/pages/vacinacao_page.dart';
import 'package:flutter_vethome/screens/pets.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/pet_avatar.dart';
import 'package:flutter_vethome/widgets/pet_summary.dart';

String assetOf(Image image) {
  final provider = image.image;
  return (provider is ResizeImage ? provider.imageProvider : provider)
          is AssetImage
      ? ((provider is ResizeImage ? provider.imageProvider : provider)
                as AssetImage)
            .assetName
      : '';
}

Finder avatarImages() =>
    find.descendant(of: find.byType(PetAvatar), matching: find.byType(Image));

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + .05) / (darker + .05);
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });
  tearDown(() async => VetRepository.flush());

  for (final entry in [('Cachorro', PetImages.dog), ('Gato', PetImages.cat)]) {
    testWidgets('${entry.$1} sem foto ou com placeholder usa espécie real', (
      tester,
    ) async {
      for (final path in [
        '',
        PetImages.dog,
        PetImages.cat,
        'assets/imagens/pets/img_cachorroegato_png.png',
        'assets/imagens/pets/img_cachorroegato_png_36x32.png',
        entry.$2.replaceFirst('.png', '-4.png'),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PetAvatar(image: path, species: entry.$1),
            ),
          ),
        );
        expect(assetOf(tester.widget<Image>(avatarImages())), entry.$2);
        expect(find.byType(ClipRRect), findsOneWidget);
        expect(tester.widget<Image>(avatarImages()).fit, BoxFit.contain);
      }
    });

    testWidgets(
      '${entry.$1} mantém identidade em todas as superfícies ativas',
      (tester) async {
        late PetModel pet;
        await tester.runAsync(() async {
          pet = VetRepository.addPet(
            name: 'Teste ${entry.$1}',
            species: entry.$1,
            sex: 'Macho',
            weightKg: 4,
            birthDate: DateTime(2020),
            breed: 'SRD',
          );
          VetRepository.pets
            ..clear()
            ..add(pet);
          VetRepository.selectedPetId = pet.id;
          await VetRepository.flush();
        });
        for (final size in [const Size(390, 844), const Size(320, 640)]) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          for (final screen in [
            const PetsPage(),
            const EscolhaPetScreen(),
            DetalhesPetPage(pet: pet),
            SaudePage(pet: pet),
            VacinacaoPage(pet: pet),
            const ServicosScreen(),
            const ConvenioScreen(),
            NovaConsultaPage(pet: pet, service: 'Urina', plan: 'Particular'),
            AgendamentosPage(pet: pet),
          ]) {
            await tester.pumpWidget(MaterialApp(home: screen));
            await tester.pumpAndSettle();
            expect(avatarImages(), findsWidgets, reason: '$screen');
            for (final image in tester.widgetList<Image>(avatarImages())) {
              expect(assetOf(image), entry.$2, reason: '$screen');
            }
            if (screen is PetsPage || screen is EscolhaPetScreen) {
              expect(
                find.descendant(
                  of: find.byType(PetAvatar),
                  matching: find.byType(ClipRRect),
                ),
                findsNothing,
              );
              expect(
                find.descendant(
                  of: find.byType(PetAvatar),
                  matching: find.byType(ColoredBox),
                ),
                findsNothing,
              );
            }
            expect(tester.takeException(), isNull, reason: '$screen');
          }
        }
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  }

  testWidgets('imagem válida tem prioridade sobre a espécie', (tester) async {
    const image = 'assets/imagens/figma/vethomepng-2.png';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PetAvatar(image: image, species: 'Gato'),
        ),
      ),
    );
    expect(assetOf(tester.widget<Image>(avatarImages())), image);
  });

  testWidgets('imagem inválida de gato cai na silhueta sem círculo na lista', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PetAvatar(
            image: 'assets/imagens/arquivo-inexistente.png',
            species: 'Gato',
            listSilhouette: true,
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await tester.pumpAndSettle();
    });
    await tester.pumpAndSettle();
    expect(
      tester.widgetList<Image>(avatarImages()).map(assetOf),
      contains(PetImages.cat),
    );
    expect(find.byType(ClipRRect), findsNothing);
    expect(
      find.descendant(
        of: find.byType(PetAvatar),
        matching: find.byType(ColoredBox),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('espécie desconhecida recebe representação neutra segura', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PetAvatar(image: '', species: 'Coelho', size: 32),
        ),
      ),
    );
    expect(avatarImages(), findsNothing);
    expect(find.text('?'), findsOneWidget);
    final fallback = tester.widget<Text>(find.text('?'));
    expect(fallback.style?.color, VetColors.calendarTextOnRose);
    expect(
      _contrastRatio(fallback.style!.color!, VetColors.rose),
      greaterThanOrEqualTo(4.5),
    );
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('renomear mantém ID, imagem e fallback no resumo/agendamento', (
    tester,
  ) async {
    late PetModel pet;
    await tester.runAsync(() async {
      pet = VetRepository.addPet(
        name: 'Gato Original',
        species: 'Gato',
        sex: 'Fêmea',
        weightKg: 3,
        birthDate: DateTime(2020),
        breed: 'SRD',
      );
      VetRepository.updatePet(pet, pet.copyWith(name: 'Gato Renomeado'));
      await VetRepository.flush();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: NovaConsultaPage(pet: pet, service: 'Urina', plan: 'Particular'),
      ),
    );
    expect(find.text('Gato Renomeado'), findsOneWidget);
    expect(find.text('Gato Renomeado'), findsOneWidget);
    expect(assetOf(tester.widget<Image>(avatarImages())), PetImages.cat);
    expect(VetRepository.petById(pet.id)!.imagePath, pet.imagePath);
    expect(find.byType(PetSummary), findsNothing);
    expect(find.byType(PetAvatar), findsOneWidget);
  });

  testWidgets('editor preserva imagem válida ao trocar a espécie', (
    tester,
  ) async {
    late PetModel pet;
    const image = 'assets/imagens/figma/vethomepng-2.png';
    await tester.runAsync(() async {
      final base = VetRepository.addPet(
        name: 'Pet com imagem',
        species: 'Cachorro',
        sex: 'Macho',
        weightKg: 4,
        birthDate: DateTime(2020),
        breed: 'SRD',
      );
      pet = base.copyWith(imagePath: image);
      VetRepository.updatePet(base, pet);
      await VetRepository.flush();
    });
    await tester.pumpWidget(MaterialApp(home: EditarPetPage(pet: pet)));
    await tester.tap(find.text('Cachorro').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gato').last);
    await tester.pumpAndSettle();
    final race = find.descendant(
      of: find.byWidgetPredicate((w) => w is VHField && w.label == 'Raça'),
      matching: find.byType(TextFormField),
    );
    await tester.ensureVisible(race);
    await tester.enterText(race, 'SRD');
    await tester.pumpAndSettle();
    await tester.tap(find.text('SRD / Sem raça definida').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar alterações'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Salvar alterações'));
      await VetRepository.flush();
    });
    await tester.pumpAndSettle();
    expect(VetRepository.petById(pet.id)!.species, 'Gato');
    expect(VetRepository.petById(pet.id)!.imagePath, image);
  });

  testWidgets(
    'foto enviada e imagem personalizada prevalecem no detalhe móvel',
    (tester) async {
      const customAsset = 'assets/imagens/figma/vethomepng-2.png';
      final base = PetModel(
        name: 'Pet com imagem própria',
        imagePath: customAsset,
        description: 'Imagem personalizada',
        species: 'Gato',
      );
      final bytes = await rootBundle.load(PetImages.dog);
      final photo = base64Encode(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      final withPhoto = PetModel(
        name: 'Pet com foto enviada',
        imagePath: PetImages.cat,
        photoBase64: photo,
        description: 'Foto enviada',
        species: 'Gato',
      );
      for (final size in const [Size(320, 640), Size(390, 844)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        // Nova rota independente: evita reaproveitar o State do pet anterior.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(MaterialApp(home: DetalhesPetPage(pet: base)));
        await tester.pumpAndSettle();
        expect(find.byType(PetAvatar), findsOneWidget);
        expect(assetOf(tester.widget<Image>(avatarImages())), customAsset);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          MaterialApp(home: DetalhesPetPage(pet: withPhoto)),
        );
        await tester.pumpAndSettle();
        expect(find.byType(PetAvatar), findsOneWidget);
        final image = tester.widget<Image>(avatarImages());
        final provider = image.image;
        expect(
          provider is ResizeImage ? provider.imageProvider : provider,
          isA<MemoryImage>(),
        );
        expect(tester.takeException(), isNull);
      }
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );

  testWidgets('foto no detalhe móvel mantém o botão para alterar a foto', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    var photoTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetSummary(
            pet: VetRepository.pets.first,
            size: PetSummarySize.detailed,
            onPhoto: () => photoTapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('pet-camera-badge')), findsOneWidget);
    expect(find.byTooltip('Alterar foto do pet'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pet-camera-badge')));
    expect(photoTapped, isTrue);
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('resumos compactos, médios e detalhe amplo usam espécie', (
    tester,
  ) async {
    final pet = PetModel(
      name: 'Pet sem foto no resumo',
      imagePath: PetImages.dog,
      description: 'Sem foto',
      species: 'Cachorro',
    );
    for (final size in const [Size(390, 844), Size(600, 844)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      for (final summarySize in [
        PetSummarySize.compact,
        PetSummarySize.medium,
        if (size.width >= 600) PetSummarySize.detailed,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PetSummary(pet: pet, size: summarySize),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(assetOf(tester.widget<Image>(avatarImages())), PetImages.dog);
        expect(tester.takeException(), isNull, reason: '$summarySize em $size');
      }
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
