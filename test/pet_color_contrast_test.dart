import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/pet_summary.dart';
import 'package:flutter_vethome/widgets/pets/pet_card_widget.dart';
import 'package:flutter_vethome/widgets/vet_choice_pill.dart';

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  final pet = PetModel(
    id: 'pet-color-contrast',
    name: 'Luna',
    imagePath: 'assets/imagens/figma/vethomepng-2.png',
    description: '',
    species: 'Cachorro',
    breed: 'Vira-lata',
  );

  testWidgets('cartão da lista de Pets mantém contraste no rosa sobreposto', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: VetColors.pink,
          body: Center(
            child: Container(
              color: VetColors.roseOverlay25,
              child: PetCardWidget(pet: pet),
            ),
          ),
        ),
      ),
    );

    final name = tester.widget<Text>(find.text('Luna'));
    final chevron = tester.widget<VetChevron>(find.byType(VetChevron));
    final listPanel = Color.alphaBlend(VetColors.roseOverlay25, VetColors.pink);
    final cardSurface = Color.alphaBlend(VetColors.roseOverlay50, listPanel);

    expect(name.style?.color, VetColors.brownOnRose);
    expect(chevron.color, VetColors.brownOnRose);
    expect(
      _contrastRatio(VetColors.brownOnRose, cardSurface),
      greaterThan(4.5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'texto secundário de PetSummary continua legível no cartão rosa',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: VetColors.pink,
            body: PetSummary(pet: pet, size: PetSummarySize.medium),
          ),
        ),
      );

      final subtitle = tester.widget<Text>(find.text('Cachorro · Vira-lata'));
      final summarySurface = Color.alphaBlend(
        VetColors.roseOverlay25,
        VetColors.pink,
      );

      expect(subtitle.style?.color, VetColors.brown);
      expect(_contrastRatio(VetColors.brown, summarySurface), greaterThan(4.5));
      expect(tester.takeException(), isNull);
    },
  );
}
