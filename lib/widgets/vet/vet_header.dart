import 'package:flutter/material.dart';

import '../../pages/teste_page.dart';
import '../../theme/vet_colors.dart';
import '../pets/pets_theme.dart';

/// Cabeçalho padrão: botão voltar + título centralizado + curva inferior.
/// Respeita o notch/status bar. `bottom` permite pendurar conteúdo extra.
class VetHeader extends StatelessWidget {
  const VetHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.bottom,
<<<<<<< HEAD
=======
    this.titleSize = 30,
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
  });

  final String title;
  final bool showBack;
  final Widget? bottom;
<<<<<<< HEAD
=======
  final double titleSize;
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185

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
                width: 48 * s,
                height: 48 * s,
                child: showBack
                    ? Material(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: const CircleBorder(),
<<<<<<< HEAD
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.maybePop(context),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 22 * s,
=======
                        child: Tooltip(
                          message: 'Voltar',
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.maybePop(context),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 22 * s,
                            ),
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
                          ),
                        ),
                      )
                    : null,
              ),
              Expanded(
<<<<<<< HEAD
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
=======
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
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
                  ),
                ),
              ),
              SizedBox(
                width: 48 * s,
                child: IconButton(
                  tooltip: 'Telas de teste',
                  constraints: BoxConstraints.tightFor(
                    width: 48 * s,
                    height: 48 * s,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TestePage()),
                    );
                  },
                  icon: Icon(
                    Icons.dashboard_outlined,
                    color: Colors.white,
                    size: 22 * s,
                  ),
                ),
              ),
            ],
          ),
<<<<<<< HEAD
          Container(
            width: 202 * s,
            height: 52 * s,
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
=======
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
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
        ],
      ),
    );
  }
}
