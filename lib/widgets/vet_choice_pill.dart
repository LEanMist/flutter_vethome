import 'package:flutter/material.dart';

import '../theme.dart';

/// Setas duplas usadas nas listas do protótipo.
class VetChevron extends StatelessWidget {
  const VetChevron({
    super.key,
    this.color = VH.foreground,
    this.strokeWidth = 2,
  });
  final Color color;
  final double strokeWidth;
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(18, 24),
    painter: _ChevronPainter(color, strokeWidth),
  );
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color, this.strokeWidth);
  final Color color;
  final double strokeWidth;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
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
  bool shouldRepaint(_ChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
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
                  boxShadow: VH.controlShadow,
                ),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(100),
                  mouseCursor: SystemMouseCursors.click,
                  overlayColor: WidgetStateProperty.resolveWith(
                    VH.interactionOverlay,
                  ),
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

/// Ícones dos planos usam os assets visuais do Figma.
class VetPictogram extends StatelessWidget {
  const VetPictogram(this.kind, {super.key});
  final String kind;
  @override
  Widget build(BuildContext context) {
    final asset = switch (kind) {
      'Exames' || 'DogLife' => 'coisademedico-1.png',
      'Atestados' => 'atestado-1.png',
      'PetLove' => 'convenio-petlove.png',
      'Particular' => 'convenio-particular.png',
      _ => null,
    };
    if (asset != null) {
      return Image.asset(
        'assets/imagens/figma/$asset',
        excludeFromSemantics: true,
      );
    }
    return Icon(
      kind == 'Vacinas' ? Icons.vaccines_outlined : Icons.memory_outlined,
      color: Colors.white,
      size: 30,
    );
  }
}
