import 'package:flutter/material.dart';

import '../theme/vet_colors.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_bottom_nav.dart';
import 'despesas_page.dart';
import 'saude_page.dart';
import 'vacinacao_page.dart';

class DetalhesPetPage extends StatelessWidget {
  final String petName;
  final String petImage;

  const DetalhesPetPage({
    required this.petName,
    required this.petImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final String safeImage = petImage.isNotEmpty
        ? petImage
        : 'assets/imagens/VetHome_logo_1.jpg';

    return Scaffold(
      backgroundColor: VetColors.pink,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(18 * s, 18 * s, 18 * s, 22 * s),
              decoration: BoxDecoration(
                color: VetColors.rose,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28 * s),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42 * s,
                      height: 42 * s,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Detalhes',
                    style: TextStyle(
                      fontSize: 26 * s,
                      fontWeight: FontWeight.w700,
                      fontFamily: PetsTheme.fontComfortaa,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 42 * s),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16 * s),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18 * s),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26 * s),
                        boxShadow: const [
                          BoxShadow(
                            color: VetColors.shadowDark,
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20 * s),
                            child: Image.asset(
                              safeImage,
                              width: 76 * s,
                              height: 76 * s,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16 * s),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  petName,
                                  style: TextStyle(
                                    fontSize: 22 * s,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: PetsTheme.fontComfortaa,
                                    color: VetColors.brown,
                                  ),
                                ),
                                SizedBox(height: 4 * s),
                                Text(
                                  'Cachorro • 4 anos • Castrado',
                                  style: TextStyle(
                                    fontSize: 13 * s,
                                    color: VetColors.brown.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18 * s),
                    _infoCard(
                      icon: Icons.favorite,
                      title: 'Saúde',
                      value: 'Ótima condição',
                    ),
                    SizedBox(height: 12 * s),
                    _infoCard(
                      icon: Icons.vaccines,
                      title: 'Vacinação',
                      value: 'Em dia',
                    ),
                    SizedBox(height: 12 * s),
                    _infoCard(
                      icon: Icons.calendar_month,
                      title: 'Próximo agendamento',
                      value: '22/10 às 14:30',
                    ),
                    SizedBox(height: 12 * s),
                    _infoCard(
                      icon: Icons.paid,
                      title: 'Despesas do mês',
                      value: 'R\$ 280,00',
                    ),
                  ],
                ),
              ),
            ),
            VetBottomNav(
              selectedIndex: 0,
              onSelected: (i) {
                if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _PerfilPlaceholder(),
                    ),
                  );
                } else if (i == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SaudePage(petName: petName, petImage: safeImage),
                    ),
                  );
                } else if (i == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          VacinacaoPage(petName: petName, petImage: safeImage),
                    ),
                  );
                } else if (i == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DespesasPage(petName: petName, petImage: safeImage),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: VetColors.rose,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: VetColors.brown,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: VetColors.brown.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfilPlaceholder extends StatelessWidget {
  const _PerfilPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const Center(child: Text('Perfil do usuário')),
    );
  }
}
