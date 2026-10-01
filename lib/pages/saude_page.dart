import 'package:flutter/material.dart';

import '../theme/vet_colors.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_bottom_nav.dart';
import 'despesas_page.dart';
import 'vacinacao_page.dart';

class SaudePage extends StatelessWidget {
  final String petName;
  final String petImage;

  const SaudePage({required this.petName, required this.petImage, super.key});

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final String safeImage = petImage.isNotEmpty
        ? petImage
        : 'assets/imagens/VetHome_logo_1.jpg';

    final List<Map<String, String>> historico = [
      {
        'data': '15/09/2024',
        'tipo': 'Consulta Geral',
        'veterinario': 'Dra. Ana Silva',
        'descricao': 'Checkup completo. Tudo normal.',
        'status': 'Concluído',
      },
      {
        'data': '02/08/2024',
        'tipo': 'Vermifugação',
        'veterinario': 'Dr. João Mendes',
        'descricao': 'Tratamento realizado com sucesso.',
        'status': 'Concluído',
      },
      {
        'data': '12/07/2024',
        'tipo': 'Pesagem e avaliação',
        'veterinario': 'Dra. Clara Lima',
        'descricao': 'Peso está estável e bem hidratado.',
        'status': 'Concluído',
      },
    ];

    return Scaffold(
      backgroundColor: VetColors.pink,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(18 * s, 18 * s, 18 * s, 24 * s),
              decoration: BoxDecoration(
                color: VetColors.rose,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(26 * s),
                ),
              ),
              child: Column(
                children: [
                  Row(
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
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Saúde',
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
                  SizedBox(height: 16 * s),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18 * s),
                        child: Image.asset(
                          safeImage,
                          width: 72 * s,
                          height: 72 * s,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16 * s),
                      Expanded(
                        child: Text(
                          petName,
                          style: TextStyle(
                            fontSize: 22 * s,
                            fontWeight: FontWeight.w700,
                            fontFamily: PetsTheme.fontComfortaa,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16 * s),
                child: Column(
                  children: [
                    _statusRow(s),
                    SizedBox(height: 18 * s),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Histórico',
                        style: TextStyle(
                          fontSize: 20 * s,
                          fontWeight: FontWeight.w700,
                          fontFamily: PetsTheme.fontComfortaa,
                          color: VetColors.brown,
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    for (final item in historico) ...[
                      _consultaCard(item, s),
                      SizedBox(height: 12 * s),
                    ],
                  ],
                ),
              ),
            ),
            VetBottomNav(
              selectedIndex: 2,
              onSelected: (i) {
                if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _PerfilPlaceholder(),
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

  Widget _statusRow(double s) {
    return Row(
      children: [
        Expanded(
          child: _miniStatus(
            icon: Icons.check_circle,
            title: 'Vacinação',
            value: 'Em dia',
            color: Colors.green,
            s: s,
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: _miniStatus(
            icon: Icons.monitor_weight,
            title: 'Peso',
            value: '12,5 kg',
            color: Colors.orange,
            s: s,
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: _miniStatus(
            icon: Icons.medical_services,
            title: 'Vermif',
            value: 'OK',
            color: Colors.blue,
            s: s,
          ),
        ),
      ],
    );
  }

  Widget _miniStatus({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double s,
  }) {
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18 * s),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24 * s),
          SizedBox(height: 6 * s),
          Text(
            title,
            style: TextStyle(fontSize: 11 * s, color: VetColors.brown),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w700,
              color: VetColors.brown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _consultaCard(Map<String, String> item, double s) {
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
              Text(
                item['data'] ?? '',
                style: TextStyle(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w700,
                  color: VetColors.brown,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBF6E5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item['status'] ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            item['tipo'] ?? '',
            style: TextStyle(
              fontSize: 16 * s,
              fontWeight: FontWeight.w700,
              color: VetColors.brown,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            'Veterinário: ${item['veterinario']}',
            style: TextStyle(fontSize: 12 * s, color: VetColors.brown),
          ),
          SizedBox(height: 8 * s),
          Text(
            item['descricao'] ?? '',
            style: TextStyle(
              fontSize: 12 * s,
              color: VetColors.brown.withOpacity(0.8),
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
