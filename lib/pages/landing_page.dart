import 'package:flutter/material.dart';

import '../theme/vet_colors.dart';

/// Landing desktop do Figma (Telas para Entregar / EXTRA / LANDING PAGE).
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const Size designSize = Size(1543, 900);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VetColors.pink,
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
                      width: 872.364,
                      height: 900,
                      child: ClipPath(
                        clipper: _LandingHeroClipper(),
                        child: Image.asset(
                          'assets/imagens/figma/landing-hero.jpg',
                          fit: BoxFit.cover,
                          semanticLabel:
                              'Veterinários passeando com cães em um parque',
                        ),
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
                          fontFamily: 'Montserrat',
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
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
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
                        shape: const CircleBorder(),
                        child: Semantics(
                          button: true,
                          label: 'Explorar serviços',
                          child: InkWell(
                            key: const ValueKey('landing-services-link'),
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.pushNamed(context, '/login'),
                            child: Center(
                              child: Image.asset(
                                'assets/imagens/figma/landing-services-arrow.png',
                                width: 32,
                                height: 32,
                                excludeFromSemantics: true,
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
                            label: 'Atendimento a\ndomicilio',
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
            color: Color(0x04000000),
            offset: Offset(1.1855, 1.4226),
            blurRadius: 3.1481,
          ),
          BoxShadow(
            color: Color(0x07000000),
            offset: Offset(5.2163, 6.2596),
            blurRadius: 6.5185,
          ),
          BoxShadow(
            color: Color(0x09000000),
            offset: Offset(12.8037, 15.3644),
            blurRadius: 13,
          ),
          BoxShadow(
            color: Color(0x0B000000),
            offset: Offset(24.659, 29.5907),
            blurRadius: 25.4815,
          ),
          BoxShadow(
            color: Color(0x0E000000),
            offset: Offset(41.4934, 49.7921),
            blurRadius: 46.8519,
          ),
          BoxShadow(
            color: Color(0x12000000),
            offset: Offset(64.0184, 76.8221),
            blurRadius: 80,
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
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 1.245,
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
                fontFamily: 'Raleway',
                fontSize: 20,
                fontWeight: FontWeight.w700,
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
        fontFamily: 'Raleway',
        fontSize: 20,
        fontWeight: FontWeight.w700,
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
            fontFamily: 'Raleway',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: text,
      ),
    );
  }
}

class _LandingHeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(26.6241, 76.317)
      ..cubicTo(10.3098, 43.5705, 2.07706, 12.7542, 0, 1.43937)
      ..lineTo(0, 0.441001)
      ..cubicTo(277.759, 0.108211, 837.13, -0.357694, 852.537, 0.441001)
      ..cubicTo(867.945, 1.2397, 872.175, 12.4214, 872.364, 17.9124)
      ..lineTo(872.364, 879.005)
      ..cubicTo(871.797, 893.98, 858.202, 900.47, 843.474, 898.972)
      ..cubicTo(599.892, 899.971, 113.181, 900.869, 114.993, 898.473)
      ..cubicTo(116.806, 896.077, 117.637, 863.53, 117.826, 847.557)
      ..cubicTo(111.595, 788.154, 111.595, 790.65, 73.6411, 690.313)
      ..cubicTo(35.6876, 589.977, 36.8206, 480.157, 58.3464, 420.754)
      ..cubicTo(75.5671, 373.232, 88.5582, 315.426, 92.9011, 292.464)
      ..cubicTo(101.965, 197.619, 47.017, 117.25, 26.6241, 76.317)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
