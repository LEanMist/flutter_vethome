import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/vet_colors.dart';

/// Landing desktop do Figma (Telas para Entregar / EXTRA / LANDING PAGE).
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const Size designSize = Size(1543, 900);
  static const double tabletBreakpoint = 700;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VetColors.pink,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktopScale = math.min(
            constraints.maxWidth / designSize.width,
            constraints.maxHeight / designSize.height,
          );
          final scaledTitleLineHeight =
              MediaQuery.textScalerOf(context).scale(47) * 1.2;
          final titleNeedsReflow = scaledTitleLineHeight * 2 > 114;
          if (desktopScale < 1) {
            return constraints.maxWidth >= tabletBreakpoint && !titleNeedsReflow
                ? _buildTablet(context)
                : _buildMobile(context);
          }
          if (titleNeedsReflow) return _buildMobile(context);
          return Center(
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
                        // Alvo de 48 px, mantendo o ícone Figma de 32 px em (639, 395).
                        left: 631,
                        top: 387,
                        width: 48,
                        height: 48,
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: Semantics(
                            button: true,
                            label: 'Explorar serviços',
                            child: InkWell(
                              key: const ValueKey('landing-services-link'),
                              customBorder: const CircleBorder(),
                              onTap: () =>
                                  Navigator.pushNamed(context, '/login'),
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
                              key: ValueKey('landing-service-home'),
                              image:
                                  'assets/imagens/figma/landing-service-home.jpg',
                              label: 'Atendimento a\ndomicílio',
                              imageLabel: 'Logotipo VetHome',
                            ),
                            SizedBox(width: 40),
                            _LandingServiceCard(
                              key: ValueKey('landing-service-exams'),
                              image:
                                  'assets/imagens/figma/landing-service-exams.jpg',
                              label: 'Exames',
                              imageLabel: 'Ícone de exames veterinários',
                            ),
                            SizedBox(width: 40),
                            _LandingServiceCard(
                              key: ValueKey('landing-service-vaccines'),
                              image:
                                  'assets/imagens/figma/landing-service-vaccines.jpg',
                              label: 'Vacinas',
                              imageLabel: 'Ícone de vacinação de um cão',
                              imageSize: 158,
                              imageOffset: Offset(-1, 0),
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
                          onReviews: () => showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Avaliações'),
                              content: const Text(
                                'Ainda não há avaliações disponíveis. Esta seção será exibida quando houver avaliações reais.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            ),
                          ),
                          onEnter: () => Navigator.pushNamed(context, '/login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Tablet/short-window adaptation; no equivalent frame is available in Figma.
  Widget _buildTablet(BuildContext context) {
    void showReviews() {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Avaliações'),
          content: const Text(
            'Ainda não há avaliações disponíveis. Esta seção será exibida quando houver avaliações reais.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LandingMobileNavigation(
                  onHome: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (_) => false,
                  ),
                  onAbout: () => Navigator.pushNamed(context, '/sobre'),
                  onReviews: showReviews,
                  onEnter: () => Navigator.pushNamed(context, '/login'),
                ),
                const SizedBox(height: 28),
                LayoutBuilder(
                  builder: (context, constraints) => Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Escolha o melhor\npara o seu Pet',
                          key: const ValueKey('landing-tablet-title'),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: constraints.maxWidth < 800 ? 36 : 44,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: VetColors.brown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: ClipRRect(
                          key: const ValueKey('landing-tablet-hero'),
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: 872.364 / 900,
                            child: Image.asset(
                              'assets/imagens/figma/landing-hero.jpg',
                              fit: BoxFit.cover,
                              semanticLabel:
                                  'Veterinários passeando com cães em um parque',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
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
                    const SizedBox(width: 8),
                    _LandingMobileServicesLink(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 40,
                  runSpacing: 20,
                  children: const [
                    _LandingServiceCard(
                      key: ValueKey('landing-service-home'),
                      image: 'assets/imagens/figma/landing-service-home.jpg',
                      label: 'Atendimento a\ndomicílio',
                      imageLabel: 'Logotipo VetHome',
                    ),
                    _LandingServiceCard(
                      key: ValueKey('landing-service-exams'),
                      image: 'assets/imagens/figma/landing-service-exams.jpg',
                      label: 'Exames',
                      imageLabel: 'Ícone de exames veterinários',
                    ),
                    _LandingServiceCard(
                      key: ValueKey('landing-service-vaccines'),
                      image:
                          'assets/imagens/figma/landing-service-vaccines.jpg',
                      label: 'Vacinas',
                      imageLabel: 'Ícone de vacinação de um cão',
                      imageSize: 158,
                      imageOffset: Offset(-1, 0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile layout is an inferred adaptation; the Figma file provides only
  /// the 1543 × 900 desktop frame. Keep the same content and local assets.
  Widget _buildMobile(BuildContext context) {
    void showReviews() {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Avaliações'),
          content: const Text(
            'Ainda não há avaliações disponíveis. Esta seção será exibida quando houver avaliações reais.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LandingMobileNavigation(
                  onHome: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (_) => false,
                  ),
                  onAbout: () => Navigator.pushNamed(context, '/sobre'),
                  onReviews: showReviews,
                  onEnter: () => Navigator.pushNamed(context, '/login'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Escolha o melhor\npara o seu Pet',
                  key: ValueKey('landing-mobile-title'),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: VetColors.brown,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  key: const ValueKey('landing-mobile-hero'),
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 872.364 / 900,
                    child: Image.asset(
                      'assets/imagens/figma/landing-hero.jpg',
                      fit: BoxFit.cover,
                      semanticLabel:
                          'Veterinários passeando com cães em um parque',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'NOSSOS SERVIÇOS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: VetColors.brown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _LandingMobileServicesLink(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _LandingMobileServiceCard(
                  key: ValueKey('landing-service-home'),
                  asset: 'assets/imagens/figma/landing-service-home.jpg',
                  label: 'Atendimento a\ndomicílio',
                  imageLabel: 'Logotipo VetHome',
                ),
                const SizedBox(height: 12),
                const _LandingMobileServiceCard(
                  key: ValueKey('landing-service-exams'),
                  asset: 'assets/imagens/figma/landing-service-exams.jpg',
                  label: 'Exames',
                  imageLabel: 'Ícone de exames veterinários',
                ),
                const SizedBox(height: 12),
                const _LandingMobileServiceCard(
                  key: ValueKey('landing-service-vaccines'),
                  asset: 'assets/imagens/figma/landing-service-vaccines.jpg',
                  label: 'Vacinas',
                  imageLabel: 'Ícone de vacinação de um cão',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LandingMobileNavigation extends StatelessWidget {
  const _LandingMobileNavigation({
    required this.onHome,
    required this.onAbout,
    required this.onReviews,
    required this.onEnter,
  });

  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onReviews;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 8,
    runSpacing: 4,
    children: [
      _LandingNavLabel(
        label: 'Home',
        semanticLabel: 'Início',
        width: 65,
        onPressed: onHome,
      ),
      _LandingNavLabel(
        label: 'Sobre nós',
        semanticLabel: 'Sobre nós',
        width: 99,
        onPressed: onAbout,
      ),
      _LandingNavLabel(
        label: 'Review',
        semanticLabel: 'Avaliações',
        width: 79,
        onPressed: onReviews,
      ),
      Semantics(
        button: true,
        label: 'Entrar na demonstração',
        onTap: onEnter,
        child: ExcludeSemantics(
          child: SizedBox(
            width: 132,
            height: 59,
            child: OutlinedButton(
              onPressed: onEnter,
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
        ),
      ),
    ],
  );
}

class _LandingMobileServicesLink extends StatelessWidget {
  const _LandingMobileServicesLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('landing-services-link'),
    width: 48,
    height: 48,
    child: Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: Semantics(
        button: true,
        label: 'Explorar serviços',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
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
  );
}

class _LandingMobileServiceCard extends StatelessWidget {
  const _LandingMobileServiceCard({
    super.key,
    required this.asset,
    required this.label,
    required this.imageLabel,
  });

  final String asset;
  final String label;
  final String imageLabel;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 116,
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
    child: Row(
      children: [
        SizedBox(
          key: ValueKey('landing-service-image-${asset.split('/').last}'),
          width: 96,
          height: 96,
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            semanticLabel: imageLabel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            key: ValueKey('landing-service-label-${asset.split('/').last}'),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 1.245,
              fontWeight: FontWeight.w500,
              color: VetColors.calendarTextOnRose,
            ),
          ),
        ),
      ],
    ),
  );
}

class _LandingServiceCard extends StatelessWidget {
  const _LandingServiceCard({
    super.key,
    required this.image,
    required this.label,
    required this.imageLabel,
    this.imageSize = 156,
    this.imageOffset = Offset.zero,
  });

  final String image;
  final String label;
  final String imageLabel;
  final double imageSize;
  final Offset imageOffset;

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
            height: imageSize,
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: imageSize,
              maxWidth: imageSize,
              minHeight: imageSize,
              maxHeight: imageSize,
              child: Transform.translate(
                offset: imageOffset,
                child: SizedBox(
                  key: ValueKey(
                    'landing-service-image-${image.split('/').last}',
                  ),
                  width: imageSize,
                  height: imageSize,
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    semanticLabel: imageLabel,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 156,
            height: 37,
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: 157,
              maxWidth: 157,
              child: SizedBox(
                key: ValueKey('landing-service-label-${image.split('/').last}'),
                width: 157,
                height: 37,
                child: FittedBox(
                  alignment: Alignment.topLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      height: 1.245,
                      fontWeight: FontWeight.w500,
                      color: VetColors.calendarTextOnRose,
                    ),
                  ),
                ),
              ),
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
    required this.onReviews,
    required this.onEnter,
  });

  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onReviews;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LandingNavLabel(
          label: 'Home',
          semanticLabel: 'Início',
          width: 65,
          onPressed: onHome,
        ),
        const SizedBox(width: 55),
        _LandingNavLabel(
          label: 'Sobre nós',
          semanticLabel: 'Sobre nós',
          width: 99,
          onPressed: onAbout,
        ),
        const SizedBox(width: 55),
        _LandingNavLabel(
          label: 'Review',
          semanticLabel: 'Avaliações',
          width: 79,
          onPressed: onReviews,
        ),
        const SizedBox(width: 55),
        Semantics(
          button: true,
          label: 'Entrar na demonstração',
          onTap: onEnter,
          child: ExcludeSemantics(
            child: SizedBox(
              width: 132,
              height: 59,
              child: OutlinedButton(
                onPressed: onEnter,
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
          ),
        ),
      ],
    );
  }
}

class _LandingNavLabel extends StatelessWidget {
  const _LandingNavLabel({
    required this.label,
    required this.semanticLabel,
    required this.width,
    this.onPressed,
  });

  final String label;
  final String semanticLabel;
  final double width;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontFamily: 'Raleway',
      fontSize: 20,
      height: 1.15,
      fontWeight: FontWeight.w700,
      color: VetColors.brown,
    );
    final textScaler = MediaQuery.textScalerOf(context);
    var layoutWidth = width;
    if (textScaler.scale(textStyle.fontSize!) > textStyle.fontSize!) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: Directionality.of(context),
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      layoutWidth = math.max(width, painter.width + 16);
    }
    final text = Text(
      label,
      textAlign: TextAlign.start,
      maxLines: 1,
      softWrap: false,
      style: textStyle,
    );
    if (onPressed == null) return SizedBox(width: layoutWidth, child: text);
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: SizedBox(
          width: layoutWidth,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: VetColors.brown,
              minimumSize: Size(layoutWidth, 59),
              maximumSize: Size(layoutWidth, 59),
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: text,
          ),
        ),
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
