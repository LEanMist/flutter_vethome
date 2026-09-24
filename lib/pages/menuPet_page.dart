import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
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
            final alturaBotao = compacto ? 60.0 : 70.0;
            final larguraBotoes = compacto ? 180.0 : 300.0;
            final fonteBotao = compacto ? 20.0 : 40.0;

            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: ClipRect(
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/imagens/foto.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                        
                        Positioned(
                          top: 30,
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
                  )
                ),
                Expanded(
                  flex: 3,
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
                        const SizedBox(height: 36,),
                        Text(
                          'Seja bem Vindo!',
                           textAlign: TextAlign.center,
                           style: GoogleFonts.comfortaa(
                            color: const Color(0xFF68442E),
                            fontSize: compacto ? 30 : 35,
                            fontWeight: FontWeight.w900,
                           ),
                        ),
                        Text(
                          'Escolha seu pet',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                           color: const Color(0xFF68442E),
                           fontSize: compacto ? 30 : 35,
                           fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 30,),
                        _botaoPet(
                          texto: 'CÃO',
                          largura: larguraBotoes,
                          altura: alturaBotao,
                          fonte: fonteBotao, 
                          onPressed: (){}
                        ),
                        const SizedBox(height: 17,),
                        _botaoPet(
                          texto: 'GATO',
                          largura: larguraBotoes,
                          altura: alturaBotao,
                          fonte: fonteBotao,  
                          onPressed: (){}
                        ),
                        const SizedBox(height: 20,),
                        _botaoCadastrar(
                          texto: 'cadastrar seu animal',
                          largura: 280,
                          altura: alturaBotao,
                          fonte: fonteBotao,
                          onPressed: (){}
                        ),
                      ],
                    ),          
                  ),  
                ),
              ],
            );
          }
        ),
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
  
  Widget _botaoPet({
    required String texto,
    required double largura,
    required double altura,
    required double fonte,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: largura,
      height: altura,
      decoration: const inset_shadow.BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(80)),
        boxShadow: [
          inset_shadow.BoxShadow(
            color: Color.fromARGB(150, 105, 66, 67),
            blurRadius: 2,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFAD3D5),
              foregroundColor: const Color(0xFF68442E),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    texto,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserratAlternates(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF68442E),
                      fontSize: fonte,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(
                    Icons.pets,
                    color: Color(0xFF68442E),
                    size: 35,
                  ),
                ),
              ],
            )
          ),
          Positioned(
            top: 0.7,
            left: largura / 10,
            right: largura / 8,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.9,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _botaoCadastrar({
    required String texto,
    required double largura,
    required double altura,
    required double fonte,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: largura,
      height: altura,
      decoration: const inset_shadow.BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(80)),
        boxShadow: [
          inset_shadow.BoxShadow(
            color: Color.fromARGB(150, 105, 66, 67),
            blurRadius: 2,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFAD3D5),
              foregroundColor: const Color(0xFF68442E),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    texto,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserratAlternates(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF68442E),
                      fontSize: fonte,
                    ),
                  ),
                ),
              ],
            )
          ),
          Positioned(
            top: 0.7,
            left: largura / 12,
            right: largura / 10,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.9,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}