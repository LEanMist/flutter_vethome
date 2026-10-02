// lib/widgets/pets/pet_card_widget.dart

import 'package:flutter/material.dart';

import '../../models/pet_model.dart';
import '../../theme/vet_colors.dart';
import './pets_theme.dart';

class PetCardWidget extends StatelessWidget {
  final PetModel pet;
  final VoidCallback? onTap;

  const PetCardWidget({super.key, required this.pet, this.onTap});

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final bool isCat = pet.species?.toLowerCase().contains('gato') ?? false;
    final String petIllustration = isCat
        ? 'assets/imagens/figma/cachorroegatopng-2.png'
        : 'assets/imagens/figma/cachorroegatopng-3.png';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8 * s, horizontal: 14 * s),
        decoration: BoxDecoration(
          color: VetColors.rose,
          borderRadius: BorderRadius.circular(18 * s),
          boxShadow: const [
            BoxShadow(
              color: VetColors.shadowDark,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34 * s,
              height: 34 * s,
              decoration: const BoxDecoration(
                color: VetColors.pink,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Image.asset(
                petIllustration,
                width: 22 * s,
                height: 25 * s,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 10 * s),
            Expanded(
              child: Text(
                pet.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                  fontFamily: PetsTheme.fontMontserratAlternates,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 21 * s, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
