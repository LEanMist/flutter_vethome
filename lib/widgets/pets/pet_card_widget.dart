// lib/widgets/pets/pet_card_widget.dart

import 'package:flutter/material.dart';

import '../../models/pet_model.dart';
import '../../theme/vet_colors.dart';
import './pets_image_view.dart';
import './pets_theme.dart';

class PetCardWidget extends StatelessWidget {
  final PetModel pet;
  final VoidCallback? onTap;

  const PetCardWidget({Key? key, required this.pet, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10 * s, horizontal: 18 * s),
        decoration: BoxDecoration(
          color: VetColors.rose.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24 * s),
          boxShadow: const [
            BoxShadow(
              color: VetColors.shadowDark,
              offset: Offset(3, 3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: VetColors.shadowLight,
              offset: Offset(-2, -2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PetsImageView(
                  imagePath: pet.imagePath,
                  width: 32 * s,
                  height: 36 * s,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Text(
                    pet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20 * s,
                      fontWeight: FontWeight.w700,
                      fontFamily: PetsTheme.fontComfortaa,
                      color: Colors.white,
                      height: 23 / 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * s),
            Text(
              pet.description,
              style: TextStyle(
                fontSize: 10 * s,
                fontWeight: FontWeight.w700,
                fontFamily: PetsTheme.fontComfortaa,
                color: Colors.white,
                height: 11 / 10,
              ),
            ),
            SizedBox(height: 8 * s),
          ],
        ),
      ),
    );
  }
}
