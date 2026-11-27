import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:google_fonts/google_fonts.dart';

class BotaoEstilizado extends StatelessWidget {
  const BotaoEstilizado({
    super.key,
    required this.texto,
    required this.onPressed,
    this.largura = 200,
    this.altura = 64,
    this.tamanhoFonte = 24,
    this.corFundo = VetCores.rosaFundo,
    this.mostrarSombra = true,
  }) : assert(largura > 0),
       assert(altura > 0),
       assert(tamanhoFonte > 0);

  final String texto;
  final VoidCallback? onPressed;
  final double largura;
  final double altura;
  final double tamanhoFonte;
  final Color corFundo;
  final bool mostrarSombra;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      height: altura,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(1000),
          boxShadow: mostrarSombra
          ? const [
              BoxShadow(
                color: VetCores.sombra,
                blurRadius: 2,
                offset: Offset(2, 3),
              ),
            ]
          : null,
        ),
        child: CustomPaint(
          foregroundPainter: const _ContornoBotaoPainter(),
          child: Material(
            color: Colors.transparent,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    texto,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.comfortaa(
                      color: VetCores.marrom,
                      fontSize: tamanhoFonte,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContornoBotaoPainter extends CustomPainter {
  const _ContornoBotaoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final raio = math.min(size.width, size.height) / 2;
    final paint = Paint()
      ..color = VetCores.branco
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    final superiorEsquerdo = Path()
      ..moveTo(size.width - raio, 0.75)
      ..lineTo(raio, 0.65)
      ..quadraticBezierTo(0.75, 0.75, 0.75, size.height / 2)
      ..quadraticBezierTo(
        0.75,
        size.height * 0.65,
        raio * 0.1,
        size.height * 0.65,
      );
    final inferiorDireito = Path()
      ..moveTo(raio, size.height - 0.75)
      ..lineTo(size.width - raio, size.height - 0.75)
      ..quadraticBezierTo(
        size.width - 0.75,
        size.height - 0.75,
        size.width - 0.75,
        size.height / 2,
      )
      ..quadraticBezierTo(
        size.width - 0.75,
        size.height * 0.35,
        size.width - raio * 0.1,
        size.height * 0.45,
      );

    canvas.drawPath(superiorEsquerdo, paint);
    canvas.drawPath(inferiorDireito, paint);
  }

  @override
  bool shouldRepaint(covariant _ContornoBotaoPainter oldDelegate) => false;
}
