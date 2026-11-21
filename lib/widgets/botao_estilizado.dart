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
  }) : assert(largura > 0),
       assert(altura > 0),
       assert(tamanhoFonte > 0);

  final String texto;
  final VoidCallback? onPressed;
  final double largura;
  final double altura;
  final double tamanhoFonte;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      height: altura,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: VetCores.rosaFundo,
          borderRadius: BorderRadius.circular(1000),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(90, 0, 0, 0),
              blurRadius: 5,
              offset: Offset(2, 4),
            ),
          ],
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
                    style: GoogleFonts.montserratAlternates(
                      color: onPressed == null
                          ? VetCores.marrom50
                          : VetCores.marrom,
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
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final superiorEsquerdo = Path()
      ..moveTo(size.width - raio, 0.75)
      ..lineTo(raio, 0.75)
      ..quadraticBezierTo(0.75, 0.75, 0.75, size.height / 2)
      ..quadraticBezierTo(
        0.75,
        size.height * 0.65,
        raio * 0.2,
        size.height * 0.75,
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
        size.width - raio * 0.2,
        size.height * 0.25,
      );

    canvas.drawPath(superiorEsquerdo, paint);
    canvas.drawPath(inferiorDireito, paint);
  }

  @override
  bool shouldRepaint(covariant _ContornoBotaoPainter oldDelegate) => false;
}
