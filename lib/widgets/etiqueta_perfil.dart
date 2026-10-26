import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/services/perfil_foto_service.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/bordas_circulares.dart';

class EtiquetaPerfil extends StatelessWidget {
  const EtiquetaPerfil({
    super.key,
    required this.nome,
    required this.fotoPerfilPath,
    required this.compacto,
    required this.onSelecionarFoto,
  });

  static const double offsetTop = 85;

  final String nome;
  final String? fotoPerfilPath;
  final bool compacto;
  final VoidCallback onSelecionarFoto;

  @override
  Widget build(BuildContext context) {
    final double altura = compacto ? 290 : 350;
    final double largura = compacto ? 230 : 300;
    final double alturaFoto = compacto ? 200 : 260;
    final double larguraFoto = compacto ? 200 : 260;

    return Container(
      width: largura,
      height: altura,
      decoration: BoxDecoration(
        color: VetCores.rosaFundo.withValues(alpha: 0.4),
        border: Border.all(color: VetCores.rosaEscuro, width: 5),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
          bottom: Radius.circular(200),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.comfortaa(
                color: VetCores.marrom,
                fontSize: compacto ? 20 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: larguraFoto,
              height: alturaFoto,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: onSelecionarFoto,
                      child: DashedCircle(
                        size: 100,
                        color: VetCores.marrom50,
                        strokeWidth: 3.2,
                        child: Padding(
                          padding: const EdgeInsets.all(11),
                          child: ClipOval(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (fotoPerfilPath == null)
                                  ColoredBox(
                                    color: VetCores.rosaFundo,
                                    child: Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 90,
                                      color: VetCores.marrom50,
                                    ),
                                  )
                                else
                                  exibirFotoPerfil(fotoPerfilPath!),
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: DecoratedBox(
                                      decoration:
                                          const inset_shadow.BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              inset_shadow.BoxShadow(
                                                color: Color.fromARGB(
                                                  184,
                                                  142,
                                                  135,
                                                  135,
                                                ),
                                                blurRadius: 1,
                                                offset: Offset(2, 2),
                                                inset: true,
                                              ),
                                            ],
                                          ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter:
                                          const _ContornoFotoPerfilPainter(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContornoFotoPerfilPainter extends CustomPainter {
  const _ContornoFotoPerfilPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(1.5, 1.5, size.width - 2, size.height - 2);
    const startAngle = math.pi / -13;
    const sweepAngle = math.pi / 1.6;

    final brilho = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawArc(rect, startAngle, sweepAngle, false, brilho);

    final contorno = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, contorno);
  }

  @override
  bool shouldRepaint(covariant _ContornoFotoPerfilPainter oldDelegate) => false;
}
