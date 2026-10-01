// lib/pages/pets_page.dart
import 'package:flutter/material.dart';

import '../core/utils/vet_nav.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../theme/vet_colors.dart';
import '../widgets/pets/pet_card_widget.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_bottom_nav.dart';
import 'detalhes_pet_page.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final double top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: VetColors.pink,
      body: Column(
        children: [
          _buildHeader(s, top),
          Expanded(
            child: SingleChildScrollView(
              child: _buildPetListSection(context, s),
            ),
          ),
          SafeArea(
            top: false,
            child: VetBottomNav(
              selectedIndex: 0,
              onSelected: (i) => vetNavigate(
                context,
                i,
                selected: 0,
                isTabRoot: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                cacheWidth: 252,
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
          Container(
            width: 220 * s,
            padding: EdgeInsets.symmetric(vertical: 8 * s),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: VetColors.roseDark.withValues(alpha: 0.6),
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

  Widget _buildPetListSection(BuildContext context, double s) {
    final List<PetModel> pets = VetRepository.pets;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(12 * s, 18 * s, 12 * s, 18 * s),
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 14 * s),
      decoration: BoxDecoration(
        color: VetColors.rose.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24 * s),
      ),
      child: Column(
        children: [
          for (int i = 0; i < pets.length; i++) ...[
            if (i > 0) SizedBox(height: 18 * s),
            PetCardWidget(
              pet: pets[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalhesPetPage(pet: pets[i]),
                ),
              ),
            ),
          ],
          SizedBox(height: 40 * s),
          _NeuButton(
            width: 106 * s,
            height: 46 * s,
            radius: 23 * s,
            color: VetColors.pink,
            onTap: () => vetSoon(context),
            child: Icon(Icons.add, size: 30 * s, color: VetColors.brown),
          ),
        ],
      ),
    );
  }
}

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
