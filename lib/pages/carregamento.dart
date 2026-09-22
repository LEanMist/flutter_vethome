import 'dart:math';
import 'package:flutter/material.dart';
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

    // MOVIMENTO DA LOGO
    //
    // 0.00 até 0.30 = logo sobe
    // 0.30 até 0.65 = logo fica no centro
    // 0.65 até 1.00 = logo cai

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
                compacto ? 120.0 : 180.0;

            return SizedBox(
              width: double.infinity,
              height: double.infinity,

              child: AnimatedBuilder(
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

                child: Center(
                  child: Image.asset(
                    'assets/imagens/VetHome_logo_1.jpg',

                    width: tamanhoLogo,
                    height: tamanhoLogo,

                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}