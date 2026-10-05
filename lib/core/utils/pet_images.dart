/// Identidade visual dos pets; caminhos antigos são placeholders, não fotos.
class PetImages {
  PetImages._();

  static const dog = 'assets/imagens/figma/cachorroegatopng-2.png';
  static const cat = 'assets/imagens/figma/cachorroegatopng-3.png';

  static String? forSpecies(String? species) =>
      switch (species?.trim().toLowerCase()) {
        'cachorro' || 'cão' || 'cao' || 'dog' || 'canino' => dog,
        'gato' || 'cat' || 'felino' => cat,
        _ => null,
      };

  // Inclui exports duplicados antigos que podem existir em snapshots salvos.
  // Esses caminhos nunca são enviados ao loader: só a espécie resolve o asset.
  static bool isPlaceholder(String image) =>
      image.trim().isEmpty ||
      RegExp(
        r'^assets/imagens/figma/cachorroegatopng-[23](?:-[234])?\.png$',
      ).hasMatch(image) ||
      const {
        'assets/imagens/pets/img_cachorroegato_png.png',
        'assets/imagens/pets/img_cachorroegato_png_36x32.png',
        'assets/imagens/pets/dog.png',
        'assets/imagens/pets/cat.png',
        'assets/imagens/pets/image_not_found.png',
        'assets/imagens/VetHome_logo_1.jpg',
      }.contains(image);

  static bool hasImage(String image) => !isPlaceholder(image);
}
