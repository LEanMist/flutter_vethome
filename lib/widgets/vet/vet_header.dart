import 'package:flutter/material.dart';

import '../../theme/vet_colors.dart';
import '../pets/pets_theme.dart';

/// Cabeçalho padrão: botão voltar + título centralizado + curva inferior.
/// Mantém a geometria do Figma com insets de status bar. `bottom` permite
/// pendurar conteúdo extra.
class VetHeader extends StatelessWidget {
  const VetHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.bottom,
    this.titleSize = 30,
  });

  final String title;
  final bool showBack;
  final Widget? bottom;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final double top = MediaQuery.paddingOf(context).top;
    final double topPadding = top > 14 * s ? top : 14 * s;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 125),
      padding: EdgeInsets.fromLTRB(18 * s, topPadding, 18 * s, 22 * s),
      decoration: BoxDecoration(
        color: VetColors.rose,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(
                width: 48 * s,
                height: 48 * s,
                child: showBack
                    ? Material(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: const CircleBorder(),
                        child: Tooltip(
                          message: 'Voltar',
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.maybePop(context),
                            child: Icon(
                              Icons.arrow_back,
                              color: VetColors.brown,
                              size: 22 * s,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: titleSize * s,
                      fontWeight: FontWeight.w700,
                      fontFamily: PetsTheme.fontComfortaa,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 48 * s),
            ],
          ),
          if (bottom != null)
            Container(
              width: 202 * s,
              constraints: BoxConstraints(minHeight: 52 * s),
              decoration: BoxDecoration(
                color: VetColors.pink.withValues(alpha: 0.16),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30 * s),
                  bottom: Radius.circular(10 * s),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: VetColors.shadowDark,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: bottom,
            ),
        ],
      ),
    );
  }
}
