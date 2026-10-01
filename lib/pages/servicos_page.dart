import 'package:flutter/material.dart';

class ServicosPage extends StatefulWidget {
  const ServicosPage({super.key});

  @override
  State<ServicosPage> createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
  String? menuAberto;

  void alternarMenu(String menu) {
    setState(() {
      if (menuAberto == menu) {
        menuAberto = null;
      } else {
        menuAberto = menu;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD5D5),

      body: SafeArea(
        child: Column(
          children: [
            // ============================
            // CABEÇALHO
            // ============================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 25, bottom: 25),
              decoration: const BoxDecoration(
                color: Color(0xFFC38282),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),

              child: Column(
                children: [
                  const Text(
                    'Serviços',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BOTÃO CÃO
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF9F6969)),
                    ),

                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CÃO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 20),

                        Icon(Icons.pets, color: Colors.white, size: 25),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 70),

            // ============================
            // MENUS
            // ============================
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  _buildMenu(
                    titulo: 'Exames',
                    icone: Icons.medical_services_outlined,
                    identificador: 'exames',
                    itens: const [
                      'Hemograma',
                      'Exame de urina',
                      'Exame de fezes',
                    ],
                  ),

                  _buildMenu(
                    titulo: 'Vacinas',
                    icone: Icons.vaccines_outlined,
                    identificador: 'vacinas',
                    itens: const ['Antirrábica', 'V8', 'V10', 'Giárdia'],
                  ),

                  _buildMenu(
                    titulo: 'Microchipagem',
                    icone: Icons.memory_outlined,
                    identificador: 'microchipagem',
                    itens: const [
                      'Implantação de microchip',
                      'Consulta de microchip',
                    ],
                  ),

                  _buildMenu(
                    titulo: 'Atestados',
                    icone: Icons.assignment_outlined,
                    identificador: 'atestados',
                    itens: const ['Atestado de saúde', 'Atestado para viagem'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MENU EXPANSÍVEL
  // =========================================================

  Widget _buildMenu({
    required String titulo,
    required IconData icone,
    required String identificador,
    required List<String> itens,
  }) {
    final bool aberto = menuAberto == identificador;

    return Column(
      children: [
        // BOTÃO PRINCIPAL
        GestureDetector(
          onTap: () => alternarMenu(identificador),

          child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: 48,

            margin: EdgeInsets.only(bottom: aberto ? 0 : 12),

            decoration: const BoxDecoration(
              color: Color(0xFFC08081),

              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),

              boxShadow: [
                BoxShadow(
                  color: Color(0x449B6868),
                  offset: Offset(1, 2),
                  blurRadius: 3,
                ),
              ],
            ),

            child: Row(
              children: [
                const SizedBox(width: 12),

                Icon(icone, color: Colors.white, size: 23),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Icon(
                  aberto ? Icons.keyboard_arrow_down : Icons.chevron_right,
                  color: const Color(0xFF674848),
                  size: 28,
                ),

                const SizedBox(width: 10),
              ],
            ),
          ),
        ),

        // SUBMENU
        if (aberto)
          Container(
            width: MediaQuery.of(context).size.width * 0.6,

            margin: const EdgeInsets.only(bottom: 12),

            padding: const EdgeInsets.symmetric(vertical: 8),

            decoration: const BoxDecoration(
              color: Color(0xFFE8B9B9),

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(18),
              ),
            ),

            child: Column(
              children: itens.map((item) {
                return Material(
                  color: Colors.transparent,

                  child: InkWell(
                    onTap: () {
                      // Futuramente vamos abrir
                      // a tela de agendamento.
                      debugPrint('Serviço selecionado: $item');
                    },

                    borderRadius: BorderRadius.circular(10),

                    splashColor: const Color(0x99C08081),
                    highlightColor: const Color(0x66C08081),

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 10,
                      ),

                      child: Text(
                        item,
                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          color: Color(0xFF674848),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
