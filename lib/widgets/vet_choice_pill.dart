import 'package:flutter/material.dart';

import '../theme.dart';

/// Setas duplas usadas nas listas do protótipo.
class VetChevron extends StatelessWidget {
  const VetChevron({super.key, this.color = VH.foreground});
  final Color color;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(18, 24), painter: _ChevronPainter(color));
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final x in [2.0, 9.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 5)
          ..lineTo(x + 6, 12)
          ..lineTo(x, 19),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.color != color;
}

class VetChoicePill extends StatelessWidget {
  const VetChoicePill({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.expanded = false,
  });
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  final bool expanded;
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 306),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: VH.softGradient,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(100),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 59),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 30, height: 30, child: icon),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontFamily: VH.headingFontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
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
          ),
          SizedBox(
            width: 42,
            height: 48,
            child: IconButton(
              tooltip: label,
              onPressed: onTap,
              icon: AnimatedRotation(
                turns: expanded ? .25 : 0,
                duration: const Duration(milliseconds: 240),
                child: const VetChevron(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Reutiliza exports disponíveis; casa/cruz e cápsulas são desenhos simples.
class VetPictogram extends StatelessWidget {
  const VetPictogram(this.kind, {super.key});
  final String kind;
  @override
  Widget build(BuildContext context) {
    final asset = switch (kind) {
      'Exames' || 'DogLife' => 'coisademedico-1.png',
      'Atestados' => 'atestado-1.png',
      _ => null,
    };
    if (asset != null) {
      return Image.asset(
        'assets/imagens/figma/$asset',
        excludeFromSemantics: true,
      );
    }
    if (kind == 'PetLove' || kind == 'Particular') {
      return CustomPaint(painter: _PlanPainter(kind));
    }
    return Icon(
      kind == 'Vacinas' ? Icons.vaccines_outlined : Icons.memory_outlined,
      color: Colors.white,
      size: 30,
    );
  }
}

class _PlanPainter extends CustomPainter {
  const _PlanPainter(this.kind);
  final String kind;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 30, size.height / 30);
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (kind == 'PetLove') {
      canvas.drawPath(
        Path()
          ..moveTo(2, 13)
          ..lineTo(15, 3)
          ..lineTo(28, 13)
          ..moveTo(6, 11)
          ..lineTo(6, 27)
          ..lineTo(24, 27)
          ..lineTo(24, 11),
        p,
      );
      canvas.drawLine(const Offset(15, 14), const Offset(15, 23), p);
      canvas.drawLine(const Offset(10.5, 18.5), const Offset(19.5, 18.5), p);
    } else {
      for (final center in [const Offset(10, 12), const Offset(21, 19)]) {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(.65);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-4, -10, 8, 20),
            const Radius.circular(4),
          ),
          p,
        );
        canvas.drawLine(const Offset(-4, 0), const Offset(4, 0), p);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_PlanPainter oldDelegate) => oldDelegate.kind != kind;
}
