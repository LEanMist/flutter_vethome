import 'package:flutter/material.dart';

import '../theme/vet_colors.dart';
import 'pets/pets_theme.dart';

/// Cabeçalho padrão: botão voltar + título centralizado + curva inferior.
/// Respeita o notch/status bar. `bottom` permite pendurar conteúdo extra.
class VetHeader extends StatelessWidget {
  const VetHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.bottom,
  });

  final String title;
  final bool showBack;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final double top = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18 * s, top + 14 * s, 18 * s, 22 * s),
      decoration: BoxDecoration(
        color: VetColors.rose,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28 * s)),
        boxShadow: const [
          BoxShadow(
            color: VetColors.shadowDark,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 42 * s,
                height: 42 * s,
                child: showBack
                    ? Material(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.maybePop(context),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 22 * s,
                          ),
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 26 * s,
                    fontWeight: FontWeight.w700,
                    fontFamily: PetsTheme.fontComfortaa,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 42 * s),
            ],
          ),
          if (bottom != null) ...[SizedBox(height: 16 * s), bottom!],
        ],
      ),
    );
  }
}
