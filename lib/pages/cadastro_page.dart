import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:google_fonts/google_fonts.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAD3D5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAD3D5),
        foregroundColor: const Color(0xFF68442E),
        title: Text(
          'Cadastro',
          style: GoogleFonts.comfortaa(
            color: const Color(0xFF68442E),
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto =
                constraints.maxWidth < 500 || constraints.maxHeight < 700;
            final tamanhoLogo = compacto ? 155.0 : 180.0;
            final alturaBotao = compacto ? 56.0 : 70.0;
            final larguraBotoes = compacto ? 270.0 : 300.0;
            final fonteBotao = compacto ? 14.0 : 18.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: compacto ? 16 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      SizedBox(height: compacto ? 50 : 40),
                      _logo(tamanhoLogo),
                      SizedBox(height: compacto ? 30 : 56),
                      _botao(
                        'Cadastrar Manualmente',
                        larguraBotoes,
                        alturaBotao,
                        fonteBotao,
                        0.75,
                      ),
                      const SizedBox(height: 30),
                      _botao(
                        'Continuar com Google',
                        larguraBotoes,
                        alturaBotao,
                        fonteBotao,
                        0.9,
                      ),
                      const SizedBox(height: 30),
                      _botao(
                        'Continuar com Facebook',
                        larguraBotoes,
                        alturaBotao,
                        fonteBotao,
                        0.75,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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

  Widget _botao(
    String texto,
    double largura,
    double altura,
    double fonte,
    double opacidadeLinhaSuperior,
  ) {
    return Container(
      width: largura,
      height: altura,
      decoration: const inset_shadow.BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(80)),
        boxShadow: [
          inset_shadow.BoxShadow(
            color: Color.fromARGB(150, 105, 66, 67),
            blurRadius: 8,
            offset: Offset(4, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          TextButton(
            onPressed: () {},
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
                    Icons.login,
                    color: Color(0xFF68442E),
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0.7,
            left: largura / 15,
            right: largura / 10,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: opacidadeLinhaSuperior,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            bottom: 1,
            left: largura / 10,
            right: largura / 10,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
