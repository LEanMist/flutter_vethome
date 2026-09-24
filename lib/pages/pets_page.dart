// lib/pages/pets_page.dart
// Tela de Pets do VetHome, com a paleta D9D9D9 / F9D2D3 / C08081 / 68442E.

import 'package:flutter/material.dart';

import '../models/pet_model.dart';
import '../theme/vet_colors.dart';
import '../widgets/pets/pet_card_widget.dart';
import '../widgets/pets/pets_image_view.dart';
import '../widgets/pets/pets_theme.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({Key? key}) : super(key: key);

  static const List<PetModel> _pets = [
    PetModel(
      name: 'Fernando',
      imagePath: PetsTheme.imgCachorroegatoPng,
      // TODO: trocar este texto de exemplo pela descrição real do pet.
      description:
          'Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido.',
    ),
    PetModel(
      name: 'Kelly',
      imagePath: PetsTheme.imgCachorroegatoPng36x32,
      description:
          'Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final EdgeInsets safe = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: VetColors.pink,
      body: Column(
        children: [
          _buildHeader(s, safe.top),
          Expanded(
            child: SingleChildScrollView(
              child: _buildPetListSection(context, s),
            ),
          ),
          _buildBottomNav(s, safe.bottom),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(double s, double topInset) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12 * s, topInset + 10 * s, 12 * s, 0),
      decoration: BoxDecoration(
        color: VetColors.rose,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30 * s)),
        boxShadow: const [
          BoxShadow(
            color: VetColors.shadowDark,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/imagens/pets/vethome_logo.png',
                width: 84 * s,
                height: 92 * s,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              Text(
                'Pets',
                style: TextStyle(
                  fontSize: 30 * s,
                  fontWeight: FontWeight.w700,
                  fontFamily: PetsTheme.fontComfortaa,
                  color: Colors.white,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
          SizedBox(height: 4 * s),
          // Aba central "° ω °"
          Container(
            width: 220 * s,
            padding: EdgeInsets.symmetric(vertical: 8 * s),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: VetColors.roseDark.withOpacity(0.6),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28 * s),
                bottom: Radius.circular(10 * s),
              ),
            ),
            child: Text(
              '°  ω  °',
              style: TextStyle(
                fontSize: 30 * s,
                fontWeight: FontWeight.w700,
                fontFamily: PetsTheme.fontMontserratAlternates,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Lista de pets + botão "+" ─────────────────────────────────────────────

  Widget _buildPetListSection(BuildContext context, double s) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(12 * s, 18 * s, 12 * s, 18 * s),
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 14 * s),
      decoration: BoxDecoration(
        color: VetColors.rose.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24 * s),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _pets.length; i++) ...[
            if (i > 0) SizedBox(height: 18 * s),
            PetCardWidget(
              pet: _pets[i],
              onTap: () => _onPetCardTapped(context, _pets[i]),
            ),
          ],
          SizedBox(height: 60 * s),
          _NeuButton(
            width: 106 * s,
            height: 46 * s,
            radius: 23 * s,
            color: VetColors.pink,
            onTap: () => _onAddPetTapped(context),
            child: Icon(Icons.add, size: 30 * s, color: VetColors.brown),
          ),
        ],
      ),
    );
  }

  // ── Barra de navegação inferior (4 botões) ────────────────────────────────

  Widget _buildBottomNav(double s, double bottomInset) {
    return Container(
      margin: EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, 12 * s + bottomInset),
      padding: EdgeInsets.symmetric(vertical: 12 * s, horizontal: 10 * s),
      decoration: BoxDecoration(
        color: VetColors.rose.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24 * s),
        boxShadow: const [
          BoxShadow(
            color: VetColors.shadowDark,
            offset: Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navButton(s, Icons.pets, selected: true, onTap: () {}),
          _navButton(s, Icons.person, onTap: () {}),
          _navButton(s, Icons.calendar_month, onTap: () {}),
          _navButton(s, Icons.settings, onTap: () {}),
        ],
      ),
    );
  }

  Widget _navButton(double s, IconData icon,
      {bool selected = false, required VoidCallback onTap}) {
    return _NeuButton(
      width: 62 * s,
      height: 62 * s,
      radius: 31 * s,
      color: selected ? VetColors.rose : VetColors.pink,
      onTap: onTap,
      child: Icon(
        icon,
        size: 32 * s,
        color: selected ? Colors.white : VetColors.brown,
      ),
    );
  }

  // ── Callbacks (ligue ao seu roteador) ─────────────────────────────────────

  void _onPetCardTapped(BuildContext context, PetModel pet) {
    // TODO: detalhes do pet
  }

  void _onAddPetTapped(BuildContext context) {
    // TODO: tela de adicionar pet
  }
}

/// Botão com sombra neumórfica (escura embaixo/direita, clara em cima/esquerda).
class _NeuButton extends StatelessWidget {
  const _NeuButton({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
    required this.child,
    this.onTap,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
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
        child: child,
      ),
    );
  }
}
