import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vet_repository.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets/figma_action_target.dart';

double _measureTextHeight({
  required InlineSpan text,
  required double maxWidth,
  required TextScaler textScaler,
  required TextDirection textDirection,
}) {
  final painter = TextPainter(
    text: text,
    textAlign: TextAlign.center,
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout(maxWidth: maxWidth);
  final height = painter.height;
  painter.dispose();
  return height;
}

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
            final widthScale = (constraints.maxWidth / 390)
                .clamp(0.0, 1.0)
                .toDouble();
            final scale = math.min(
              widthScale,
              math.max(0.8, constraints.maxHeight / 844),
            );
            final profileTargetHeight = math.max(48.0, 56 * scale);
            final textScaler = MediaQuery.textScalerOf(context);
            final textDirection = Directionality.of(context);
            final titleFontSize = 30 * scale;
            final titleTextSpan = TextSpan(
              children: [
                const TextSpan(
                  text: 'Seja ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(
                  text: 'Bem Vindo!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            );
            final titleStyle = TextStyle(
              color: VetColors.brown,
              fontFamily: VH.headingFontFamily,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            );
            final subtitleStyle = TextStyle(
              color: VetColors.brown,
              fontFamily: VH.headingFontFamily,
              fontSize: 15 * scale,
              fontWeight: FontWeight.bold,
            );
            final inheritedTextStyle = DefaultTextStyle.of(context).style;
            final scaledText = textScaler.scale(titleFontSize) > titleFontSize;
            final titleTop = 458 * scale;
            final titleHeight = _measureTextHeight(
              text: TextSpan(
                style: inheritedTextStyle.merge(titleStyle),
                children: titleTextSpan.children,
              ),
              maxWidth: 390 * scale,
              textScaler: textScaler,
              textDirection: textDirection,
            );
            final subtitleHeight = _measureTextHeight(
              text: TextSpan(
                text: 'Cuidando de quem\nte faz sorrir',
                style: inheritedTextStyle.merge(subtitleStyle),
              ),
              maxWidth: 390 * scale,
              textScaler: textScaler,
              textDirection: textDirection,
            );
            final subtitleTop = scaledText
                ? math.max(508 * scale, titleTop + titleHeight + 14 * scale)
                : 508 * scale;
            final ringTop = scaledText
                ? math.max(
                    580 * scale,
                    subtitleTop + subtitleHeight + 36 * scale,
                  )
                : 580 * scale;
            final frameHeight = scaledText
                ? math.max(844 * scale, ringTop + 197 * scale)
                : 844 * scale;

            final frame = Center(
              child: SizedBox(
                key: const ValueKey('home-figma-frame'),
                width: 390 * scale,
                height: frameHeight,
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
                        height: frameHeight - 415 * scale,
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
                        left: -1 * scale,
                        top: titleTop,
                        width: 390 * scale,
                        child: Text.rich(
                          titleTextSpan,
                          key: const ValueKey('home-title'),
                          textAlign: TextAlign.center,
                          maxLines: scaledText ? null : 1,
                          style: titleStyle,
                        ),
                      ),
                      Positioned(
                        left: -1 * scale,
                        top: subtitleTop,
                        width: 390 * scale,
                        child: Text(
                          'Cuidando de quem\nte faz sorrir',
                          key: const ValueKey('home-subtitle'),
                          textAlign: TextAlign.center,
                          style: subtitleStyle,
                        ),
                      ),
                      Positioned(
                        left: 106 * scale,
                        top: ringTop,
                        width: 177 * scale,
                        height: 177 * scale,
                        child: ExcludeSemantics(
                          child: CustomPaint(
                            key: const ValueKey('home-dashed-ring'),
                            painter: _DashedRingPainter(scale: scale),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 117 * scale,
                        top: ringTop + 11 * scale,
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
                        height: profileTargetHeight,
                        child: FigmaActionTarget(
                          key: const ValueKey('home-profile-target'),
                          width: 136 * scale,
                          height: profileTargetHeight,
                          label: 'Perfil de $name',
                          onPressed: () =>
                              Navigator.pushNamed(context, '/perfil'),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              key: const ValueKey('home-profile-chip'),
                              width: 136 * scale,
                              height: 56 * scale,
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
                                      key: const ValueKey('home-profile-icon'),
                                      size: Size.square(28.6667 * scale),
                                      painter: _ProfileIconPainter(
                                        scale: scale,
                                      ),
                                    ),
                                    SizedBox(width: 13.3333 * scale),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: 8 * scale,
                                        ),
                                        child: ExcludeSemantics(
                                          child: Text(
                                            name,
                                            key: const ValueKey(
                                              'home-user-name',
                                            ),
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
            if (frameHeight > constraints.maxHeight) {
              return SingleChildScrollView(
                key: const ValueKey('home-scroll-view'),
                child: frame,
              );
            }
            return frame;
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
        ..color = VetColors.homePetControl
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.7,
    );
    final triangle = Path()
      ..moveTo(65.72, 103.075)
      ..lineTo(101.06, 77.5)
      ..lineTo(65.72, 51.925)
      ..close();
    canvas.drawPath(triangle, Paint()..color = VetColors.homePetControl);
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
