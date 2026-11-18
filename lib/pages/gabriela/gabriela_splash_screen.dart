import 'package:flutter/material.dart';

import '../../theme/vet_colors.dart';

class GabrielaSplashScreen extends StatefulWidget {
  const GabrielaSplashScreen({super.key});

  @override
  State<GabrielaSplashScreen> createState() => _GabrielaSplashScreenState();
}

class _GabrielaSplashScreenState extends State<GabrielaSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/gabriela/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VetColors.pink,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: LayoutBuilder(
            builder: (context, bounds) {
              final s = (bounds.maxWidth / 390).clamp(.8, 1.0);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/imagens/figma/ellipse-3.png',
                    width: 390 * s,
                    height: 390 * s,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                  Image.asset(
                    'assets/imagens/figma/vethomepng-1.png',
                    width: 350 * s,
                    height: 350 * s,
                    fit: BoxFit.contain,
                    semanticLabel: 'VetHome',
                  ),
                  Positioned(
                    bottom: 62 * s,
                    child: Text(
                      'Área veterinária',
                      style: TextStyle(
                        color: VetColors.brown,
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
