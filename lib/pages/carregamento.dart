import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/widgets/logo_tematico.dart';

class Carregamento extends StatefulWidget {
  const Carregamento({
    super.key,
    required this.destinoBuilder,
    this.titulo = 'Usuário Cadastrado!',
    this.mensagem = 'É um prazer te-lo(a)! \n conosco senhor(a)',
  });

  final WidgetBuilder destinoBuilder;
  final String titulo;
  final String? mensagem;

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
            builder: widget.destinoBuilder,
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
                          widget.titulo,
                          textAlign: TextAlign.center,

                          style: GoogleFonts.comfortaa(
                            color: Color(0xFF68442E),
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (widget.mensagem != null) ...[
                          const SizedBox(height: 30),
                          Text(
                            widget.mensagem!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.comfortaa(
                              color: const Color(0xFF68442E),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
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
                    child: LogoTematico(
                      tamanho: tamanhoLogo
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}