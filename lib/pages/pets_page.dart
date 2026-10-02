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
import 'teste_page.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
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
              onSelected: (i) =>
                  vetNavigate(context, i, selected: 0, isTabRoot: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double s, double topInset) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12 * s, topInset + 8 * s, 12 * s, 12 * s),
      decoration: BoxDecoration(
        color: VetColors.rose,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28 * s)),
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
              SizedBox(width: 42 * s),
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
              const Spacer(),
              IconButton(
                tooltip: 'Telas de teste',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TestePage()),
                  );
                },
                icon: Icon(
                  Icons.dashboard_outlined,
                  color: Colors.white,
                  size: 23 * s,
                ),
              ),
            ],
          ),
          Container(
            width: 202 * s,
            height: 52 * s,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18 * s),
                bottom: Radius.circular(7 * s),
              ),
              boxShadow: const [
                BoxShadow(
                  color: VetColors.shadowDark,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  spreadRadius: -1,
                ),
              ],
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
            if (i > 0) SizedBox(height: 10 * s),
            PetCardWidget(
              pet: pets[i],
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalhesPetPage(pet: pets[i]),
                  ),
                );
                if (mounted) setState(() {});
              },
            ),
          ],
          SizedBox(height: 18 * s),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/cadastroPet'),
            child: Image.asset(
              'assets/imagens/figma/frame-48.png',
              width: 110 * s,
              height: 51 * s,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
