import 'package:flutter/material.dart';

class EscolhaConvenioPage extends StatelessWidget {
  const EscolhaConvenioPage({super.key});

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
              padding: const EdgeInsets.only(
                top: 25,
                bottom: 25,
              ),

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
                    'Convênio',
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
                      border: Border.all(
                        color: const Color(0xFF9F6969),
                      ),
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

                        Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 25,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 136),

            // ============================
            // OPÇÕES DE CONVÊNIO
            // ============================
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  _buildOpcao(
                    context,
                    titulo: 'PetLove',
                    icone: Icons.home_outlined,
                  ),

                  _buildOpcao(
                    context,
                    titulo: 'Doglife',
                    icone: Icons.medical_services_outlined,
                  ),

                  _buildOpcao(
                    context,
                    titulo: 'Particular',
                    icone: Icons.pets_outlined,
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
  // OPÇÃO
  // =========================================================

  Widget _buildOpcao(
    BuildContext context, {
    required String titulo,
    required IconData icone,
  }) {
    return SizedBox(
      height: 73,

      child: Row(
        children: [
          // BOTÃO
          Material(
            color: Colors.transparent,

            child: InkWell(
              onTap: () {
                debugPrint('Opção selecionada: $titulo');
              },

              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),

              splashColor: const Color(0x99C08081),
              highlightColor: const Color(0x66C08081),

              child: Container(
                width: MediaQuery.of(context).size.width * 0.65,
                height: 45,

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
                    const SizedBox(width: 10),

                    Icon(
                      icone,
                      color: Colors.white,
                      size: 25,
                    ),

                    const SizedBox(width: 15),

                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // SETA
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF674848),
            size: 32,
          ),
        ],
      ),
    );
  }
}