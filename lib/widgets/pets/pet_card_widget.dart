// lib/widgets/pets/pet_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

import '../../models/pet_model.dart';
import '../../theme.dart';
import '../../theme/vet_colors.dart';
import './pets_theme.dart';
import 'pet_avatar.dart';
import '../vet_choice_pill.dart';

class PetCardWidget extends StatelessWidget {
  final PetModel pet;
  final VoidCallback? onTap;

  const PetCardWidget({super.key, required this.pet, this.onTap});

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    return Container(
      decoration: inset_shadow.BoxDecoration(
        color: VetColors.roseOverlay50,
        borderRadius: BorderRadius.circular(25 * s),
        boxShadow: const [
          inset_shadow.BoxShadow(
            color: VetColors.shadowDark,
            offset: Offset(2, 2),
            blurRadius: 2,
            inset: true,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25 * s),
        child: InkWell(
          borderRadius: BorderRadius.circular(25 * s),
          onTap: onTap,
          overlayColor: WidgetStateProperty.resolveWith(VH.interactionOverlay),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 52 * s),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8 * s,
                horizontal: 18 * s,
              ),
              child: Row(
                children: [
                  PetAvatar(
                    photoBase64: pet.photoBase64,
                    image: pet.imagePath,
                    species: pet.species,
                    size: 34,
                    listSilhouette: true,
                  ),
                  SizedBox(width: 2 * s),
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
                      ),
                    ),
                  ),
                  VetChevron(
                    color: VetColors.brown.withValues(alpha: .5),
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
