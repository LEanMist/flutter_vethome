// lib/pages/pets_page.dart
// Main PETS_PAGE screen — ready to integrate into flutter_vethome.
//
// Usage:
//   import 'pages/pets_page.dart';
//   Navigator.push(context, MaterialPageRoute(builder: (_) => const PetsPage()));
//
// Required pubspec.yaml dependencies:
//   flutter_svg: ^2.0.12
//   cached_network_image: ^3.4.1
//
// Required fonts in pubspec.yaml:
//   - family: Comfortaa
//     fonts:
//       - asset: assets/fonts/ComfortaaBold.ttf
//         weight: 700
//   - family: Montserrat Alternates
//     fonts:
//       - asset: assets/fonts/MontserratAlternatesBold.ttf
//         weight: 700
//
// Required assets in pubspec.yaml:
//   - assets/imagens/pets/
//
// Copy the following image files to assets/imagens/pets/ in flutter_vethome:
//   img_cachorroegato_png.png
//   img_cachorroegato_png_36x32.png
//   img_frame_48.png
//   img_frame_48_white_a700.svg
//   img_frame_49.svg
//   img_frame_50.svg
//   img_frame_51.svg
//   img_image_2.png
//   img_vethome_png_5.png
//   image_not_found.png

import 'package:flutter/material.dart';

import '../models/pet_model.dart';
import '../widgets/pets/pet_card_widget.dart';
import '../widgets/pets/pets_image_view.dart';
import '../widgets/pets/pets_theme.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({Key? key}) : super(key: key);

  static const List<PetModel> _pets = [
    PetModel(
      name: 'Fernando',
      imagePath: PetsTheme.imgCachorroegatoPng,
      description:
          'Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido. Esta receita oferece uma maneira prática de criar esses deliciosos quadrados de chocolate, com ingredientes básicos como manteiga, ovos, achocolatado, açúcar e farinha de trigo.',
    ),
    PetModel(
      name: 'Kelly',
      imagePath: PetsTheme.imgCachorroegatoPng36x32,
      description:
          'Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido. Esta receita oferece uma maneira prática de criar esses deliciosos quadrados de chocolate, com ingredientes básicos como manteiga, ovos, achocolatado, açúcar e farinha de trigo.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double s = screenWidth / 390.0; // responsive scale factor

    return Scaffold(
      backgroundColor: PetsTheme.red100,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context, s),
                      _buildPetListSection(context, s),
                      _buildBottomNavRow(context, s),
                      PetsImageView(
                        imagePath: PetsTheme.imgImage2,
                        width: double.infinity,
                        height: 50 * s,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 30 * s,
            bottom: 62 * s,
            child: _PetsFab(
              imagePath: PetsTheme.imgFrame49,
              onTap: () => _onAddPetTapped(context),
              backgroundColor: PetsTheme.red100,
              buttonSize: 66 * s,
              borderRadius: 32 * s,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, double s) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: PetsTheme.red300,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30 * s),
          bottomRight: Radius.circular(30 * s),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12 * s),
      child: Column(
        children: [
          SizedBox(height: 10 * s),
          Row(
            children: [
              PetsImageView(
                imagePath: PetsTheme.imgVethomePng5,
                width: 84 * s,
                height: 86 * s,
                radius: BorderRadius.circular(42 * s),
                fit: BoxFit.cover,
              ),
              SizedBox(width: 66 * s),
              Text(
                'Pets',
                style: TextStyle(
                  fontSize: 30 * s,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Comfortaa',
                  color: PetsTheme.whiteA700,
                  height: 34 / 30,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          _PetsWeatherButton(
            width: double.infinity,
            text: '°  w  °',
            onTap: () {},
            textColor: PetsTheme.whiteA700,
            backgroundColor: PetsTheme.color33C080,
            scale: s,
          ),
          SizedBox(height: 12 * s),
        ],
      ),
    );
  }

  // ── Pet list section ─────────────────────────────────────────────────────

  Widget _buildPetListSection(BuildContext context, double s) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 22 * s, left: 12 * s, right: 12 * s),
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: PetsTheme.color3FC080,
        borderRadius: BorderRadius.circular(24 * s),
      ),
      child: Column(
        children: [
          ..._pets.asMap().entries.map((entry) {
            final index = entry.key;
            final pet = entry.value;
            return Column(
              children: [
                if (index > 0) SizedBox(height: 18 * s),
                PetCardWidget(
                  pet: pet,
                  onTap: () => _onPetCardTapped(context, pet.name),
                ),
              ],
            );
          }),
          SizedBox(height: 100 * s),
          Align(
            alignment: Alignment.center,
            child: PetsImageView(
              imagePath: PetsTheme.imgFrame48,
              width: 106 * s,
              height: 46 * s,
              radius: BorderRadius.circular(22 * s),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav row ───────────────────────────────────────────────────────

  Widget _buildBottomNavRow(BuildContext context, double s) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 20 * s, left: 12 * s, right: 12 * s),
      padding: EdgeInsets.symmetric(vertical: 12 * s, horizontal: 16 * s),
      decoration: BoxDecoration(
        color: PetsTheme.color7FC080,
        borderRadius: BorderRadius.circular(24 * s),
        boxShadow: const [
          BoxShadow(
            color: PetsTheme.black900_3f,
            offset: Offset(2, 2),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          _PetsIconButton(
            imagePath: PetsTheme.imgFrame48WhiteA700,
            backgroundColor: PetsTheme.color7FC080,
            padding: EdgeInsets.all(8 * s),
            width: 66 * s,
            height: 66 * s,
            borderRadius: 32 * s,
            onTap: () {},
          ),
          SizedBox(width: 22 * s),
          _PetsIconButton(
            imagePath: PetsTheme.imgFrame51,
            backgroundColor: PetsTheme.red100,
            padding: EdgeInsets.all(18 * s),
            width: 66 * s,
            height: 66 * s,
            borderRadius: 32 * s,
            onTap: () => _onProfileTapped(context),
          ),
          SizedBox(width: 22 * s),
          _PetsIconButton(
            imagePath: PetsTheme.imgFrame50,
            backgroundColor: PetsTheme.red100,
            padding: EdgeInsets.all(14 * s),
            width: 66 * s,
            height: 66 * s,
            borderRadius: 32 * s,
            onTap: () => _onAppointmentsTapped(context),
          ),
        ],
      ),
    );
  }

  // ── Navigation callbacks (wire up to your router) ────────────────────────

  void _onPetCardTapped(BuildContext context, String petName) {
    // TODO: Navigate to pet details screen
  }

  void _onAddPetTapped(BuildContext context) {
    // TODO: Navigate to add pet screen
  }

  void _onProfileTapped(BuildContext context) {
    // TODO: Navigate to profile screen
  }

  void _onAppointmentsTapped(BuildContext context) {
    // TODO: Navigate to appointments screen
  }
}

// ── Private helper widgets (internal to this file) ──────────────────────────

class _PetsFab extends StatelessWidget {
  const _PetsFab({
    Key? key,
    this.imagePath,
    this.onTap,
    this.backgroundColor,
    this.buttonSize,
    this.borderRadius,
  }) : super(key: key);

  final String? imagePath;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? buttonSize;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final double size = buttonSize ?? 66;
    final double radius = borderRadius ?? 32;
    final Color bg = backgroundColor ?? PetsTheme.red100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(
          child: imagePath != null && imagePath!.isNotEmpty
              ? PetsImageView(
                  imagePath: imagePath!,
                  height: size * 0.6,
                  width: size * 0.6,
                  fit: BoxFit.contain,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _PetsIconButton extends StatelessWidget {
  const _PetsIconButton({
    Key? key,
    required this.imagePath,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  final String imagePath;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 66,
        height: height ?? 66,
        decoration: BoxDecoration(
          color: backgroundColor ?? PetsTheme.color7FC080,
          borderRadius: BorderRadius.circular(borderRadius ?? 32),
          boxShadow: const [
            BoxShadow(
              color: PetsTheme.black900_3f,
              offset: Offset(2, 2),
              blurRadius: 2,
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(8),
        child: PetsImageView(imagePath: imagePath, fit: BoxFit.contain),
      ),
    );
  }
}

class _PetsWeatherButton extends StatelessWidget {
  const _PetsWeatherButton({
    Key? key,
    required this.width,
    required this.scale,
    this.text,
    this.onTap,
    this.textColor,
    this.backgroundColor,
  }) : super(key: key);

  final double width;
  final double scale;
  final String? text;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(
          vertical: 10 * scale,
          horizontal: 30 * scale,
        ),
        margin: EdgeInsets.symmetric(horizontal: 82 * scale),
        decoration: BoxDecoration(
          color: backgroundColor ?? PetsTheme.color33C080,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28 * scale),
            topRight: Radius.circular(28 * scale),
            bottomLeft: Radius.circular(10 * scale),
            bottomRight: Radius.circular(10 * scale),
          ),
          boxShadow: const [
            BoxShadow(
              color: PetsTheme.black900_3f,
              offset: Offset(2, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Text(
          text ?? '°  w  °',
          style: TextStyle(
            fontSize: 30 * scale,
            fontWeight: FontWeight.w700,
            fontFamily: 'MontserratAlternates',
            color: textColor ?? PetsTheme.whiteA700,
            height: 37 / 30,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
