import 'dart:convert';
import 'package:flutter/material.dart';

import '../core/utils/pet_images.dart';
import '../theme/vet_colors.dart';
import 'pets/pets_theme.dart';

/// Imagem válida tem prioridade; placeholders/falhas usam a espécie real.
class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    required this.image,
    this.size = 60,
    this.radius = 999,
    this.photoBase64,
    this.species,
    this.listSilhouette = false,
  });

  final String image;
  final double size;
  final double radius;
  final String? species;
  final String? photoBase64;
  final bool listSilhouette;

  @override
  Widget build(BuildContext context) {
    final s = PetsTheme.scaleOf(context);
    final px = size * s;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final fallback = PetImages.forSpecies(species);

    Widget silhouette() {
      final width = listSilhouette ? 32 * s : px;
      final height = listSilhouette ? 36 * s : px;
      final body = fallback == null
          ? Center(
              child: Text(
                '?',
                style: TextStyle(fontSize: width * .55, color: Colors.white),
              ),
            )
          : Image.asset(
              fallback,
              width: width,
              height: height,
              fit: BoxFit.contain,
              cacheWidth: (width * dpr).round(),
              excludeFromSemantics: true,
            );
      if (listSilhouette) {
        return SizedBox(width: width, height: height, child: body);
      }
      // Mantém o contêiner do contexto e dá espaço à silhueta inteira.
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius * s),
        child: ColoredBox(
          color: VetColors.rose,
          child: SizedBox(
            width: px,
            height: px,
            child: Padding(padding: EdgeInsets.all(px * .12), child: body),
          ),
        ),
      );
    }

    if (photoBase64 != null) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius * s),
          child: Image.memory(
            base64Decode(photoBase64!),
            width: px,
            height: px,
            fit: BoxFit.cover,
            cacheWidth: (px * dpr).round(),
            errorBuilder: (_, _, _) => silhouette(),
          ),
        );
      } catch (_) {
        return silhouette();
      }
    }
    if (!PetImages.hasImage(image)) return silhouette();
    return Image.asset(
      image,
      width: px,
      height: px,
      fit: BoxFit.cover,
      cacheWidth: (px * dpr).round(),
      frameBuilder: (_, child, _, _) => ClipRRect(
        borderRadius: BorderRadius.circular(radius * s),
        child: child,
      ),
      errorBuilder: (_, _, _) => silhouette(),
    );
  }
}
