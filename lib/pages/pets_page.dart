// lib/pages/pets_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/utils/vet_nav.dart';
import '../data/vet_repository.dart';
import '../theme/vet_colors.dart';
import '../widgets/pets/pet_card_widget.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet/vet_bottom_nav.dart';
import 'teste_page.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  final _listScroll = ScrollController();
  @override
  void dispose() {
    _listScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final double top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: VetColors.pink,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              _buildHeader(s, top),
              Expanded(child: _buildPetListSection(context, s)),
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
        ),
      ),
    );
  }

  Widget _buildHeader(double s, double topInset) {
    return Container(
      width: double.infinity,
      height: 125 + topInset,
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(12 * s, topInset + 8 * s, 12 * s, 12 * s),
      decoration: BoxDecoration(
        color: VetColors.rose,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              if (kDebugMode)
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
        ],
      ),
    );
  }

  Widget _buildPetListSection(BuildContext context, double s) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = MediaQuery.sizeOf(context).width >= 900;
      final top = 57 * s;
      final gap = 33 * s;
      // A lista rola internamente; o botão permanece fora dela em telas pequenas.
      final height = (constraints.maxHeight - top - gap - 47 - 24)
          .clamp(0.0, 428 * s)
          .toDouble();
      return Column(
        children: [
          SizedBox(height: top),
          SizedBox(
            height: height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: desktop ? 34 : 22 * s),
              child: Container(
                key: const ValueKey('pets-list-panel'),
                padding: EdgeInsets.symmetric(
                  horizontal: desktop ? 20 : 12 * s,
                  vertical: 21 * s,
                ),
                decoration: BoxDecoration(
                  color: VetColors.roseOverlay25,
                  borderRadius: BorderRadius.circular(25 * s),
                ),
                child: VetRepository.pets.isEmpty
                    ? const Center(child: Text('Nenhum pet cadastrado'))
                    : desktop
                    ? GridView.builder(
                        key: const ValueKey('pets-desktop-grid'),
                        controller: _listScroll,
                        padding: EdgeInsets.zero,
                        itemCount: VetRepository.pets.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 22,
                              mainAxisSpacing: 18,
                              childAspectRatio: 5.2,
                            ),
                        itemBuilder: (context, i) => _petCard(context, i),
                      )
                    : ListView.separated(
                        key: const ValueKey('pets-mobile-list'),
                        controller: _listScroll,
                        padding: EdgeInsets.zero,
                        itemCount: VetRepository.pets.length,
                        separatorBuilder: (_, _) => SizedBox(height: 18 * s),
                        itemBuilder: (context, i) => _petCard(context, i),
                      ),
              ),
            ),
          ),
          SizedBox(height: gap),
          SizedBox(
            width: 107,
            height: 47,
            child: IconButton.filled(
              tooltip: 'Adicionar pet',
              onPressed: () async {
                final created = await Navigator.pushNamed(
                  context,
                  '/cadastroPet',
                  arguments: {'flow': 'addPet'},
                );
                if (!mounted) return;
                setState(() {});
                if (created != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _listScroll.hasClients) {
                      _listScroll.animateTo(
                        _listScroll.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Pet cadastrado.')),
                  );
                }
              },
              style: IconButton.styleFrom(
                backgroundColor: VetColors.brown,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.add, size: 30),
            ),
          ),
        ],
      );
    },
  );

  Widget _petCard(BuildContext context, int index) => PetCardWidget(
    pet: VetRepository.pets[index],
    onTap: () async {
      VetRepository.selectedPetId = VetRepository.pets[index].id;
      await Navigator.pushNamed(
        context,
        '/pet',
        arguments: VetRepository.pets[index],
      );
      if (mounted) setState(() {});
    },
  );
}
