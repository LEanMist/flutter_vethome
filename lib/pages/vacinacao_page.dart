import 'package:flutter/material.dart';

import '../theme/vet_colors.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_bottom_nav.dart';
import 'despesas_page.dart';
import 'saude_page.dart';

class VacinacaoPage extends StatelessWidget {
  final String petName;
  final String petImage;

  const VacinacaoPage({
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

    final List<Map<String, dynamic>> vacinas = [
      {
        'nome': 'V10',
        'data': '15/09/2024',
        'proxima': '15/09/2025',
        'status': 'Atualizada',
        'icone': Icons.check_circle,
        'cor': Colors.green,
      },
      {
        'nome': 'Antirrábica',
        'data': '08/06/2024',
        'proxima': '08/06/2025',
        'status': 'Atualizada',
        'icone': Icons.check_circle,
        'cor': Colors.green,
      },
      {
        'nome': 'Giardia',
        'data': '12/05/2024',
        'proxima': '12/11/2024',
        'status': 'Pendente',
        'icone': Icons.pending_actions,
        'cor': Colors.orange,
      },
    ];

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
                  bottom: Radius.circular(26 * s),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40 * s,
                      height: 40 * s,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Vacinação',
                    style: TextStyle(
                      fontSize: 26 * s,
                      fontWeight: FontWeight.w700,
                      fontFamily: PetsTheme.fontComfortaa,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 40 * s),
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
                      padding: EdgeInsets.all(14 * s),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20 * s),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16 * s),
                            child: Image.asset(
                              safeImage,
                              width: 60 * s,
                              height: 60 * s,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 14 * s),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  petName,
                                  style: TextStyle(
                                    fontSize: 18 * s,
                                    fontWeight: FontWeight.w700,
                                    color: VetColors.brown,
                                  ),
                                ),
                                Text(
                                  'Todas as vacinas estão em dia',
                                  style: TextStyle(
                                    fontSize: 12 * s,
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
                    for (final vacina in vacinas) ...[
                      _vacinaCard(vacina, s),
                      SizedBox(height: 12 * s),
                    ],
                  ],
                ),
              ),
            ),
            VetBottomNav(
              selectedIndex: 3,
              onSelected: (i) {
                if (i == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SaudePage(petName: petName, petImage: safeImage),
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

  Widget _vacinaCard(Map<String, dynamic> vacina, double s) {
    final statusColor = vacina['cor'] as Color;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * s),
      ),
      child: Row(
        children: [
          Container(
            width: 42 * s,
            height: 42 * s,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Icon(vacina['icone'] as IconData, color: statusColor),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vacina['nome'],
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: VetColors.brown,
                  ),
                ),
                Text(
                  'Aplicada: ${vacina['data']} · Próxima: ${vacina['proxima']}',
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: VetColors.brown.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              vacina['status'],
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
