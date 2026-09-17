import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;


class MenuPetPage extends StatefulWidget {
  const MenuPetPage({super.key});

  @override
  State<MenuPetPage> createState() => _MenuPetPage();
}

class _MenuPetPage extends State<MenuPetPage> {
  bool modoEscuro = false;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 245, 245),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compacto = 
            constraints.maxWidth < 500 ||
            constraints.maxHeight < 700;
            final tamanhoLogo = compacto ? 120.0 : 180.0;

            return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: compacto ? 10: 65,
                            bottom: 10,
                            left: 15,
                            right: 15,
                          ),
                          child: Image.asset(
                            'assets/imagens/foto.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      
                      Positioned(
                        top: 5,
                        left: 5,
                        child: _botaoEscuro(
                          icone: modoEscuro 
                              ? Icons.wb_sunny_outlined 
                              : Icons.nightlight_outlined,
                          texto: '',
                          onPressed: () {
                            setState(() {
                              modoEscuro = !modoEscuro;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAD3D5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 30,),
                        _logo(tamanhoLogo),
                      ],
                    ),
                  )
                )
              ],
            );
          }
        ),
      ),
    );
  }
  Widget _logo(double tamanho) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: const inset_shadow.BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.asset(
            'assets/imagens/VetHome_logo_1.jpg',
            width: tamanho,
            height: tamanho,
            fit: BoxFit.contain,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const inset_shadow.BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  inset_shadow.BoxShadow(
                    color: Color.fromARGB(150, 255, 255, 255),
                    blurRadius: 2,
                    offset: Offset(-5, -5),
                    inset: true,
                  ),
                  inset_shadow.BoxShadow(
                    color: Color.fromARGB(190, 75, 42, 43),
                    blurRadius: 6,
                    offset: Offset(6, 7),
                    inset: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _botaoEscuro({
    required IconData icone,
    required String texto,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          foregroundColor: const Color(0xFF68442E),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 20,
              color: const Color(0xFF68442E),
            ),

            if (texto.isNotEmpty) ...[
              const SizedBox(width: 6),

              Text(
                texto,
                style: GoogleFonts.montserratAlternates(
                  fontSize: 9,
                  color: const Color(0xFF68442E),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}