import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'cadastro_pet_page.dart';
import 'menu_page.dart';
import 'package:flutter_vethome/widgets/logo_tematico.dart';



class EscolhaPetPage extends StatefulWidget {
  const EscolhaPetPage({super.key});

  @override
  State<EscolhaPetPage> createState() => _EscolhaPetPage();
}

class _EscolhaPetPage extends State<EscolhaPetPage> {
  bool modoEscuro = false;

  void cadastropet(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroPetPage(
          destinoBuilder: (context) => const MenuPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAD3D5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compacto =
                constraints.maxWidth < 500 || constraints.maxHeight < 700;
            final tamanhoLogo = compacto ? 120.0 : 180.0;
            final alturaBotao = compacto ? 60.0 : 70.0;
            final larguraBotoes = compacto ? 180.0 : 300.0;
            final fonteBotao = compacto ? 20.0 : 40.0;

            return Stack(
              children: [
                Positioned(
                  top: 22,
                  left: 0,
                  right: 0,
                  height: constraints.maxHeight / 3 + 18,
                  child: Image.asset(
                    'assets/imagens/gato_exame.webp',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRect(
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Positioned(
                              top: 30,
                              left: 5,
                              child: _botaoEscuro(
                                icone: modoEscuro
                                    ? Icons.wb_sunny_outlined
                                    : Icons.nightlight_outlined,
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
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAD3D5),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            LogoTematico(
                              tamanho: tamanhoLogo
                            ),
                            const SizedBox(height: 36),
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
                            const SizedBox(height: 30),
                            _botaoPet(
                              texto: 'CÃO',
                              largura: larguraBotoes,
                              altura: alturaBotao,
                              fonte: fonteBotao,
                              onPressed: () {},
                            ),
                            const SizedBox(height: 17),
                            _botaoPet(
                              texto: 'GATO',
                              largura: larguraBotoes,
                              altura: alturaBotao,
                              fonte: fonteBotao,
                              onPressed: () {},
                            ),
                            const SizedBox(height: 20),
                            _botaoCadastrar(
                              texto: 'cadastrar seu animal',
                              largura: 280,
                              altura: alturaBotao,
                              fonte: fonteBotao,
                              onPressed: cadastropet,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _botaoEscuro({
    required IconData icone,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 20, color: const Color(0xFF68442E)),
          ],
        ),
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
                  child: Icon(Icons.pets, color: Color(0xFF68442E), size: 35),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0.7,
            left: largura / 10,
            right: largura / 8,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
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
            ),
          ),
          Positioned(
            top: 0.7,
            left: largura / 12,
            right: largura / 10,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
