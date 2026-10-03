import 'package:flutter/material.dart';

import '../theme/vet_colors.dart';
import 'pets/pets_theme.dart';

/// Foto do pet com fallback e `cacheWidth` (evita decodificar imagem
/// gigante na thread principal -> menos "Skipped frames").
class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    required this.image,
    this.size = 60,
    this.radius = 999,
  });

  final String image;
  final double size;
  final double radius;

  static const String fallback = 'assets/imagens/VetHome_logo_1.jpg';

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final double px = size * s;
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    // Corrige apenas a apresentação dos caminhos legados invertidos,
    // sem modificar imagePath ou a espécie armazenados no modelo.
    final visualImage = switch (image) {
      'assets/imagens/figma/cachorroegatopng-3.png' =>
        'assets/imagens/figma/cachorroegatopng-2.png',
      'assets/imagens/figma/cachorroegatopng-2.png' =>
        'assets/imagens/figma/cachorroegatopng-3.png',
      _ => image,
    };
    final isSpeciesIllustration =
        visualImage == 'assets/imagens/figma/cachorroegatopng-2.png' ||
        visualImage == 'assets/imagens/figma/cachorroegatopng-3.png';

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius * s),
      child: ColoredBox(
        color: isSpeciesIllustration ? VetColors.rose : Colors.transparent,
        child: Image.asset(
          visualImage.isNotEmpty ? visualImage : fallback,
          width: px,
          height: px,
          fit: BoxFit.cover,
          cacheWidth: (px * dpr).round(),
          errorBuilder: (_, _, _) => Container(
            width: px,
            height: px,
            color: VetColors.rose.withValues(alpha: 0.3),
            child: Icon(Icons.pets, color: VetColors.brown, size: px * 0.5),
          ),
        ),
      ),
    );
  }
}
