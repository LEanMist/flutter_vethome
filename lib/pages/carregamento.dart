import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'menuPet_page.dart';

class Carregamento extends StatefulWidget {
  const Carregamento({super.key});

  @override
  State<Carregamento> createState() => _Carregamento();
}

class _Carregamento extends State<Carregamento>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<double> _movimentoLogo;
  late Animation<double> _rotacaoLogo;

  @override
  void initState() {
    super.initState();

    // CONTROLADOR DA ANIMAÇÃO
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _movimentoLogo = TweenSequence<double>([
      // Logo entrando de baixo
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 0.0,
        ).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 30,
      ),

      // Logo parada no centro
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 35,
      ),

      // Logo caindo para baixo
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.5,
        ).chain(
          CurveTween(curve: Curves.easeInCubic),
        ),
        weight: 35,
      ),
    ]).animate(_controller);

    // ROTAÇÃO DA LOGO
    //
    // A logo gira uma volta completa
    // enquanto está no centro.

    _rotacaoLogo = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.30,
          0.65,
          curve: Curves.easeInOut,
        ),
      ),
    );

    // QUANDO A ANIMAÇÃO TERMINAR,
    // ABRE A PRÓXIMA TELA.

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MenuPetPage(),
          ),
        );
      }
    });

    // INICIA A ANIMAÇÃO AUTOMATICAMENTE
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAD3D5),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {

            final bool compacto =
                constraints.maxWidth < 500 ||
                constraints.maxHeight < 700;

            final double tamanhoLogo =
                compacto ? 200.0 : 260.0;

            return SizedBox(
              width: double.infinity,
              height: double.infinity,

              child: Stack(
                alignment: Alignment.center,

                children: [
                  Positioned(
                    top: constraints.maxHeight * 0.18,
                    child: Column(
                      children: [
                        Text(
                          'Usuário Cadastrado!',
                          textAlign: TextAlign.center,

                          style: GoogleFonts.comfortaa(
                            color: Color(0xFF68442E),
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 30,),
                        Text(
                          'É um prazer te-lo(a)! \n conosco senhor(a)',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                            color: Color(0xFF68442E),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      ],
                    )
                  ),
                    
                  // LOGO ANIMADA
                  AnimatedBuilder(
                    animation: _controller,

                    builder: (context, child) {

                      return Transform.translate(
                        offset: Offset(
                          0,
                          _movimentoLogo.value *
                              constraints.maxHeight,
                        ),

                        child: Transform.rotate(
                          angle: _rotacaoLogo.value,

                          child: child,
                        ),
                      );
                    },
                    child: _logoAnimada(tamanhoLogo),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _logoAnimada(double tamanhoLogo) {
    return Container(
      width: tamanhoLogo,
      height: tamanhoLogo,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),

      child: Stack(
        children: [

          // IMAGEM DA LOGO
          ClipOval(
            child: Image.asset(
              'assets/imagens/VetHome_logo_1.jpg',
              width: tamanhoLogo,
              height: tamanhoLogo,
              fit: BoxFit.cover,

              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: tamanhoLogo,
                  height: tamanhoLogo,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAD3D5),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const inset_shadow.BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  inset_shadow.BoxShadow(
                    color: Color.fromARGB(184, 142, 135, 135),
                    blurRadius: 1,
                    offset: Offset(2, 2),
                    inset: true,
                  ),
                ],
              ),
            ),
          ),

          Positioned.fill(
            child: CustomPaint(
              painter: ContornoLogoPainter(),
            ),
          ),
        ],
      ),
    );
  }
}
class ContornoLogoPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {

    final Paint contorno = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Desenha a linha branca na parte inferior
    // do círculo, começando pelo lado direito.

    canvas.drawArc(
      Rect.fromLTWH(
        1.5,
        1.5,
        size.width - 2,
        size.height - 2,
      ),

      pi / -13, // Ponto inicial
      pi / 1.6, // Extensão da linha

      false,
      contorno,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}