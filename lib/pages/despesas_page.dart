import 'package:flutter/material.dart';

import '../theme/vet_colors.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_bottom_nav.dart';
import 'saude_page.dart';
import 'vacinacao_page.dart';

class DespesasPage extends StatelessWidget {
  final String petName;
  final String petImage;

  const DespesasPage({
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

    final List<Map<String, dynamic>> despesas = [
      {
        'data': '15/09/2024',
        'descricao': 'Consulta Veterinária',
        'valor': 150.00,
        'categoria': 'Saúde',
        'icone': Icons.local_hospital,
      },
      {
        'data': '12/09/2024',
        'descricao': 'Ração premium',
        'valor': 95.60,
        'categoria': 'Alimentação',
        'icone': Icons.fastfood,
      },
      {
        'data': '08/09/2024',
        'descricao': 'Antipulgas',
        'valor': 68.90,
        'categoria': 'Saúde',
        'icone': Icons.medical_services,
      },
    ];

    final double total = despesas.fold(
      0.0,
      (sum, item) => sum + (item['valor'] as double),
    );

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
                    'Despesas',
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
                      padding: EdgeInsets.all(18 * s),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24 * s),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14 * s),
                            child: Image.asset(
                              safeImage,
                              width: 58 * s,
                              height: 58 * s,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12 * s),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total do mês',
                                  style: TextStyle(
                                    fontSize: 12 * s,
                                    color: VetColors.brown.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  'R\$ ${total.toStringAsFixed(2).replaceFirst('.', ',')}',
                                  style: TextStyle(
                                    fontSize: 22 * s,
                                    fontWeight: FontWeight.w700,
                                    color: VetColors.brown,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18 * s),
                    for (final gasto in despesas) ...[
                      _gastoCard(gasto, s),
                      SizedBox(height: 12 * s),
                    ],
                  ],
                ),
              ),
            ),
            VetBottomNav(
              selectedIndex: 4,
              onSelected: (i) {
                if (i == 2) {
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
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _gastoCard(Map<String, dynamic> gasto, double s) {
    final double valor = gasto['valor'] as double;
    final IconData icone = gasto['icone'] as IconData;

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
              color: VetColors.rose.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Icon(icone, color: VetColors.brown),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gasto['descricao'],
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    color: VetColors.brown,
                  ),
                ),
                Text(
                  '${gasto['categoria']} · ${gasto['data']}',
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: VetColors.brown.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'R\$ ${valor.toStringAsFixed(2).replaceFirst('.', ',')}',
            style: TextStyle(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: VetColors.brown,
            ),
          ),
        ],
      ),
    );
  }
}
