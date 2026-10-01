import 'package:flutter/material.dart';

import '../theme/vet_colors.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_bottom_nav.dart';
import 'saude_page.dart';
import 'vacinacao_page.dart';

class AgendamentosPage extends StatelessWidget {
  final String petName;
  final String petImage;

  const AgendamentosPage({
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

    final List<Map<String, String>> agendamentos = [
      {
        'data': '22/10/2024',
        'hora': '14:30',
        'tipo': 'Consulta Geral',
        'veterinario': 'Dra. Ana Silva',
        'local': 'Clínica VetHome',
        'status': 'Confirmado',
      },
      {
        'data': '11/11/2024',
        'hora': '10:00',
        'tipo': 'Vacinação',
        'veterinario': 'Dr. João Mendes',
        'local': 'Unidade Central',
        'status': 'Pendente',
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
                    'Agendamentos',
                    style: TextStyle(
                      fontSize: 24 * s,
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
                      padding: EdgeInsets.all(16 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEC),
                        borderRadius: BorderRadius.circular(24 * s),
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
                          SizedBox(width: 12 * s),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Próximo agendamento',
                                  style: TextStyle(
                                    fontSize: 12 * s,
                                    color: VetColors.brown.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  '22/10 · 14:30',
                                  style: TextStyle(
                                    fontSize: 18 * s,
                                    fontWeight: FontWeight.w700,
                                    color: VetColors.brown,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Confirmado',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18 * s),
                    for (final agendamento in agendamentos) ...[
                      _eventoCard(agendamento, s),
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

  Widget _eventoCard(Map<String, String> agendamento, double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  agendamento['tipo'] ?? '',
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: VetColors.brown,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: VetColors.rose.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  agendamento['status'] ?? '',
                  style: TextStyle(
                    color: VetColors.brown,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            '${agendamento['data']} · ${agendamento['hora']}',
            style: TextStyle(
              color: VetColors.brown.withOpacity(0.8),
              fontSize: 13 * s,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            'Veterinário: ${agendamento['veterinario']}',
            style: TextStyle(
              color: VetColors.brown.withOpacity(0.8),
              fontSize: 12 * s,
            ),
          ),
          Text(
            'Local: ${agendamento['local']}',
            style: TextStyle(
              color: VetColors.brown.withOpacity(0.8),
              fontSize: 12 * s,
            ),
          ),
        ],
      ),
    );
  }
}
