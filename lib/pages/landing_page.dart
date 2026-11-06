import 'package:flutter/material.dart';

import '../theme.dart';
import '../theme/vet_colors.dart';

/// Landing desktop do Figma (Telas para Entregar / EXTRA / LANDING PAGE).
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const Size designSize = Size(1543, 900);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              key: const ValueKey('landing-figma-frame'),
              width: designSize.width,
              height: designSize.height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned(
                      left: 671,
                      top: 2,
                      width: 872,
                      height: 900,
                      child: Image.asset(
                        'assets/imagens/figma/landing-hero.jpg',
                        fit: BoxFit.cover,
                        semanticLabel:
                            'Veterinários passeando com cães em um parque',
                      ),
                    ),
                    Positioned.fill(
                      child: ClipPath(
                        clipper: _LandingPanelClipper(),
                        child: const ColoredBox(color: VetColors.pink),
                      ),
                    ),
                    const Positioned(
                      left: 60,
                      top: 231,
                      width: 438,
                      height: 114,
                      child: Text(
                        'Escolha o melhor\npara o seu Pet',
                        style: TextStyle(
                          fontFamily: VH.bodyFontFamily,
                          fontSize: 47,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: VetColors.brown,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 60,
                      top: 395,
                      child: Text(
                        'NOSSOS SERVIÇOS',
                        style: TextStyle(
                          fontFamily: VH.bodyFontFamily,
                          fontSize: 24,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: VetColors.brown,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 639,
                      top: 395,
                      width: 32,
                      height: 32,
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(
                          side: BorderSide(color: VetColors.brown, width: 2),
                        ),
                        child: Semantics(
                          button: true,
                          label: 'Explorar serviços',
                          child: InkWell(
                            key: const ValueKey('landing-services-link'),
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.pushNamed(context, '/login'),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 19,
                                color: VetColors.brown,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 60,
                      top: 441,
                      child: Row(
                        children: [
                          _LandingServiceCard(
                            image:
                                'assets/imagens/figma/landing-service-home.jpg',
                            label: 'Atendimento a\ndomicílio',
                            imageLabel: 'Logotipo VetHome',
                          ),
                          SizedBox(width: 40),
                          _LandingServiceCard(
                            image:
                                'assets/imagens/figma/landing-service-exams.jpg',
                            label: 'Exames',
                            imageLabel: 'Ícone de exames veterinários',
                          ),
                          SizedBox(width: 40),
                          _LandingServiceCard(
                            image:
                                'assets/imagens/figma/landing-service-vaccines.jpg',
                            label: 'Vacinas',
                            imageLabel: 'Ícone de vacinação de um cão',
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 943,
                      top: 44,
                      width: 540,
                      height: 59,
                      child: _LandingNavigation(
                        onHome: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (_) => false,
                        ),
                        onAbout: () => Navigator.pushNamed(context, '/sobre'),
                        onExplore: () => Navigator.pushNamed(context, '/login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LandingServiceCard extends StatelessWidget {
  const _LandingServiceCard({
    required this.image,
    required this.label,
    required this.imageLabel,
  });

  final String image;
  final String label;
  final String imageLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      height: 230,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: VetColors.rose.withValues(alpha: .8),
        border: Border.all(color: VetColors.rose, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, .12),
            offset: Offset(2, 3),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, .1),
            offset: Offset(8, 15),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 156,
            height: 156,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              semanticLabel: imageLabel,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: VH.bodyFontFamily,
              fontSize: 16,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: VetColors.brown,
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingNavigation extends StatelessWidget {
  const _LandingNavigation({
    required this.onHome,
    required this.onAbout,
    required this.onExplore,
  });

  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LandingNavLabel(label: 'Home', width: 65, onPressed: onHome),
        const SizedBox(width: 55),
        _LandingNavLabel(label: 'Sobre nos', width: 99, onPressed: onAbout),
        const SizedBox(width: 55),
        const _LandingNavLabel(label: 'Review', width: 79),
        const SizedBox(width: 55),
        SizedBox(
          width: 132,
          height: 59,
          child: OutlinedButton(
            onPressed: onExplore,
            style: OutlinedButton.styleFrom(
              foregroundColor: VetColors.brown,
              side: const BorderSide(color: VetColors.brown, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: VH.bodyFontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('Explore'),
          ),
        ),
      ],
    );
  }
}

class _LandingNavLabel extends StatelessWidget {
  const _LandingNavLabel({
    required this.label,
    required this.width,
    this.onPressed,
  });

  final String label;
  final double width;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: VH.bodyFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: VetColors.brown,
      ),
    );
    if (onPressed == null) return SizedBox(width: width, child: text);
    return SizedBox(
      width: width,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: VetColors.brown,
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(
            fontFamily: VH.bodyFontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: text,
      ),
    );
  }
}

class _LandingPanelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(671, 0)
      ..cubicTo(694, 67, 740, 128, 758, 193)
      ..cubicTo(775, 253, 768, 302, 749, 366)
      ..cubicTo(732, 427, 715, 476, 715, 530)
      ..cubicTo(715, 608, 752, 687, 775, 754)
      ..cubicTo(788, 794, 788, 851, 788, 900)
      ..lineTo(0, 900)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
