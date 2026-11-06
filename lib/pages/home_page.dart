import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vet_repository.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = VetRepository.clientName.trim().isEmpty
        ? 'usuário'
        : VetRepository.clientName.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: VetColors.pink,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = math
                .min(constraints.maxWidth / 390, constraints.maxHeight / 844)
                .clamp(.5, 1.0)
                .toDouble();

            return Center(
              child: SizedBox(
                key: const ValueKey('home-figma-frame'),
                width: 390 * scale,
                height: 844 * scale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30 * scale),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: ColoredBox(color: Colors.white),
                      ),
                      Positioned(
                        left: -6 * scale,
                        top: 70 * scale,
                        width: 400 * scale,
                        height: 400 * scale,
                        child: Image.asset(
                          'assets/imagens/figma/home-walk-dog.png',
                          key: const ValueKey('home-walk-illustration'),
                          fit: BoxFit.cover,
                          semanticLabel: 'Pessoa passeando com um cachorro',
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 415 * scale,
                        width: 390 * scale,
                        height: 429 * scale,
                        child: Container(
                          key: const ValueKey('home-welcome-panel'),
                          decoration: BoxDecoration(
                            color: VetColors.pink,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50 * scale),
                              topRight: Radius.circular(50 * scale),
                              bottomLeft: Radius.circular(30 * scale),
                              bottomRight: Radius.circular(30 * scale),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 458 * scale,
                        width: 390 * scale,
                        child: Text(
                          'Seja Bem Vindo!',
                          key: const ValueKey('home-title'),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            color: VetColors.brown,
                            fontFamily: VH.headingFontFamily,
                            fontSize: 30 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 508 * scale,
                        width: 390 * scale,
                        child: Text(
                          'Cuidando de quem\nte faz sorrir',
                          key: const ValueKey('home-subtitle'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: VetColors.brown,
                            fontFamily: VH.headingFontFamily,
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w500,
                            height: 1.15,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 106 * scale,
                        top: 580 * scale,
                        width: 178 * scale,
                        height: 178 * scale,
                        child: ExcludeSemantics(
                          child: CustomPaint(
                            key: const ValueKey('home-dashed-ring'),
                            painter: _DashedRingPainter(scale: scale),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 117 * scale,
                        top: 591 * scale,
                        width: 155 * scale,
                        height: 155 * scale,
                        child: Semantics(
                          button: true,
                          label: 'Abrir área dos pets',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              key: const ValueKey('home-open-pets'),
                              customBorder: const CircleBorder(),
                              onTap: () =>
                                  Navigator.pushNamed(context, '/pets'),
                              child: CustomPaint(
                                painter: _PlayButtonPainter(scale: scale),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 242 * scale,
                        top: 14 * scale,
                        width: 136 * scale,
                        height: 56 * scale,
                        child: Semantics(
                          button: true,
                          label: 'Perfil de $name',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              key: const ValueKey('home-profile-chip'),
                              borderRadius: BorderRadius.circular(100 * scale),
                              onTap: () =>
                                  Navigator.pushNamed(context, '/perfil'),
                              child: Container(
                                key: const ValueKey('home-profile-pill'),
                                decoration: BoxDecoration(
                                  color: VetColors.roseOverlay50,
                                  borderRadius: BorderRadius.circular(
                                    100 * scale,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: VetColors.shadowDark,
                                      offset: Offset(2, 2),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 19 * scale),
                                    CustomPaint(
                                      size: Size.square(20 * scale),
                                      painter: _ProfileIconPainter(
                                        scale: scale,
                                      ),
                                    ),
                                    SizedBox(width: 22 * scale),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: 8 * scale,
                                        ),
                                        child: Text(
                                          name,
                                          key: const ValueKey('home-user-name'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: VetColors.brown,
                                            fontFamily: VH.bodyFontFamily,
                                            fontSize: 14 * scale,
                                            fontWeight: FontWeight.w500,
                                          ),
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
            );
          },
        ),
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 180;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 88.5 * unit;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..color = VetColors.brown.withValues(alpha: .5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * unit
      ..strokeCap = StrokeCap.round;
    final circumference = 2 * math.pi * radius;
    final dashLength = 15 * unit;
    final stride = 30 * unit;

    for (var offset = 0.0; offset < circumference; offset += stride) {
      final length = math.min(dashLength, circumference - offset);
      canvas.drawArc(rect, offset / radius, length / radius, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter oldDelegate) =>
      oldDelegate.scale != scale;
}

class _PlayButtonPainter extends CustomPainter {
  const _PlayButtonPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 155;
    canvas.save();
    canvas.scale(unit);

    final center = const Offset(77.5, 77.5);
    canvas.drawCircle(center, 77.5, Paint()..color = VetColors.roseOverlay50);
    canvas.drawCircle(
      center,
      52,
      Paint()
        ..color = VetColors.pink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.7,
    );
    final triangle = Path()
      ..moveTo(65.72, 103.075)
      ..lineTo(101.06, 77.5)
      ..lineTo(65.72, 51.925)
      ..close();
    canvas.drawPath(triangle, Paint()..color = VetColors.pink);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PlayButtonPainter oldDelegate) =>
      oldDelegate.scale != scale;
}

class _ProfileIconPainter extends CustomPainter {
  const _ProfileIconPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 28.6667;
    canvas.save();
    canvas.scale(unit);
    final paint = Paint()..color = VetColors.brown;
    canvas.drawCircle(const Offset(14.3333, 7.1667), 7.1667, paint);
    final shoulders = Path()
      ..moveTo(14.3333, 17.9167)
      ..cubicTo(22.2525, 17.9167, 28.6667, 21.1237, 28.6667, 25.0833)
      ..lineTo(28.6667, 28.6667)
      ..lineTo(0, 28.6667)
      ..lineTo(0, 25.0833)
      ..cubicTo(0, 21.1237, 6.41417, 17.9167, 14.3333, 17.9167)
      ..close();
    canvas.drawPath(shoulders, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProfileIconPainter oldDelegate) =>
      oldDelegate.scale != scale;
}
