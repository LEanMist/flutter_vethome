import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/pages/saude_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/pet_avatar.dart';
import 'package:flutter_vethome/widgets/pet_summary.dart';
import 'package:flutter_vethome/widgets/pets/pet_card_widget.dart';
import 'package:flutter_vethome/widgets/vet_header.dart';

void main() {
  void mobile(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('VetHeader sem bottom não reserva a caixa inferior', (
    tester,
  ) async {
    mobile(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: VetHeader(title: 'Detalhes')),
      ),
    );
    expect(tester.getSize(find.byType(VetHeader)).height, 84);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.minWidth == 202,
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('VetHeader acomoda conteúdo maior sem limitar sua altura', (
    tester,
  ) async {
    mobile(tester);
    const contentKey = Key('conteudo');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VetHeader(
            title: 'Saúde',
            bottom: SizedBox(key: contentKey, height: 120),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(contentKey)).height, 120);
    expect(tester.getSize(find.byType(VetHeader)).height, 204);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Saúde mantém avatar e nome completo no bloco do pet', (
    tester,
  ) async {
    mobile(tester);
    for (final name in ['Fernando', 'Fernando de Nome Comprido']) {
      final pet = PetModel(
        name: name,
        description: '',
        imagePath: VetRepository.pets.first.imagePath,
      );
      await tester.pumpWidget(MaterialApp(home: SaudePage(pet: pet)));
      await tester.pumpAndSettle();
      final header = tester.getRect(find.byType(PetSummary));
      final avatar = tester.getRect(find.byType(PetAvatar));
      final label = tester.getRect(find.text(name));
      expect(header.contains(avatar.topLeft), isTrue);
      expect(avatar.bottom, lessThanOrEqualTo(header.bottom));
      expect(label.bottom, lessThanOrEqualTo(header.bottom));
      expect(label.left, greaterThan(avatar.right));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Pets mostra cachorro e gato nos assets corretos', (
    tester,
  ) async {
    for (final entry in [('Cachorro', '2'), ('Gato', '3')]) {
      final pet = PetModel(
        name: entry.$1,
        imagePath: '',
        species: entry.$1,
        description: '',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PetCardWidget(pet: pet)),
        ),
      );
      final image = tester.widget<Image>(find.byType(Image));
      expect(
        ((image.image as ResizeImage).imageProvider as AssetImage).assetName,
        'assets/imagens/figma/cachorroegatopng-${entry.$2}.png',
      );
      expect(pet.species, entry.$1);
      expect(pet.imagePath, '');
    }
  });

  testWidgets(
    'Avatar corrige os caminhos legados e dá contraste sem alterar dados',
    (tester) async {
      for (final entry in [('3', '2', 'Cachorro'), ('2', '3', 'Gato')]) {
        final storedPath =
            'assets/imagens/figma/cachorroegatopng-${entry.$1}.png';
        final pet = PetModel(
          name: 'Pet',
          imagePath: storedPath,
          description: '',
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PetAvatar(image: pet.imagePath, species: entry.$3),
            ),
          ),
        );
        final image = tester.widget<Image>(find.byType(Image));
        final resized = image.image as ResizeImage;
        expect(
          (resized.imageProvider as AssetImage).assetName,
          'assets/imagens/figma/cachorroegatopng-${entry.$2}.png',
        );
        final box = tester.widget<ColoredBox>(
          find.descendant(
            of: find.byType(PetAvatar),
            matching: find.byType(ColoredBox),
          ),
        );
        expect(box.color, VetColors.rose);
        expect(pet.imagePath, storedPath);
      }
    },
  );
}
