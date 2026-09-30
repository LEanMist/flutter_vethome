import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

class LogoTematico extends StatelessWidget {
  const LogoTematico({
    super.key,
    required this.tamanho,
  });
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),

      child: Stack(
        children: [

          // IMAGEM DA LOGO
          ClipOval(
            child: Image.asset(
              'assets/imagens/VetHome_logo_1.jpg',
              width: tamanho,
              height: tamanho,
              fit: BoxFit.cover,

              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: tamanho,
                  height: tamanho,
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