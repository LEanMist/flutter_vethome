// ignore_for_file: file_names

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/vet_repository.dart';
import '../../theme.dart';

class SucessoScreen extends StatefulWidget {
  const SucessoScreen({super.key, this.saved = false});
  final bool saved;
  @override
  State<SucessoScreen> createState() => _SucessoScreenState();
}

class _SucessoScreenState extends State<SucessoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _arrived = false;
  @override
  void initState() {
    super.initState();
    _controller.forward().then((_) async {
      if (!mounted) return;
      setState(() => _arrived = true);
      if (MediaQuery.of(context).accessibleNavigation) return;
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (mounted && !MediaQuery.of(context).accessibleNavigation) _goToPets();
    });
  }

  void _goToPets() =>
      Navigator.pushNamedAndRemoveUntil(context, '/pets', (_) => false);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: LayoutBuilder(
      builder: (context, constraints) {
        final scale = math
            .min(constraints.maxWidth / 390, constraints.maxHeight / 844)
            .clamp(0.0, 1.0)
            .toDouble();
        final frameWidth = 390 * scale;
        final frameHeight = 844 * scale;
        final accessibleNavigation = MediaQuery.of(
          context,
        ).accessibleNavigation;
        final name = VetRepository.clientName.trim().isEmpty
            ? 'usuário'
            : VetRepository.clientName.trim();
        final enlargedText = MediaQuery.textScalerOf(context).scale(40) > 44;
        final compact =
            enlargedText || scale < .7 || constraints.maxHeight < 680;
        return Center(
          child: ClipRRect(
            key: const ValueKey('registration-success-frame-clip'),
            borderRadius: BorderRadius.circular(30 * scale),
            child: SizedBox(
              key: const ValueKey('registration-success-figma-frame'),
              width: frameWidth,
              height: frameHeight,
              child: ColoredBox(
                color: VH.background,
                child: compact
                    ? _buildCompactLayout(
                        name: name,
                        scale: scale,
                        frameWidth: frameWidth,
                        frameHeight: frameHeight,
                        accessibleNavigation: accessibleNavigation,
                        enlargedText: enlargedText,
                      )
                    : _buildStandardLayout(
                        name: name,
                        scale: scale,
                        accessibleNavigation: accessibleNavigation,
                      ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildStandardLayout({
    required String name,
    required double scale,
    required bool accessibleNavigation,
  }) {
    final buttonTop = math.max(721 * scale, 717 * scale + 12).toDouble();
    final buttonHeight = math.max(48 * scale, 48.0).toDouble();
    final noticeTop = accessibleNavigation
        ? math.max(782 * scale, buttonTop + buttonHeight + 8)
        : 735 * scale;
    final noticeFontSize = accessibleNavigation
        ? (12 * scale).clamp(10.0, 12.0).toDouble()
        : 12.0;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: 133 * scale,
          width: 332 * scale,
          child: Text(
            'É um prazer tê-lo(a) conosco,\n$name.',
            textAlign: TextAlign.center,
            maxLines: 3,
            style: TextStyle(
              fontFamily: VH.headingFontFamily,
              fontSize: 25 * scale,
              fontWeight: FontWeight.bold,
              color: VH.foreground,
            ),
          ),
        ),
        Positioned(
          top: 250 * scale,
          width: 350 * scale,
          height: 350 * scale,
          child: _buildLogo(350 * scale),
        ),
        Positioned(
          top: 627 * scale,
          width: 300 * scale,
          child: _buildAnnouncement(40 * scale),
        ),
        Positioned(
          top: noticeTop,
          width: 326 * scale,
          child: ExcludeSemantics(
            child: Text(
              _noticeText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: VH.bodyFontFamily,
                fontSize: noticeFontSize,
                height: 1.2,
                color: VH.foreground,
              ),
            ),
          ),
        ),
        if (accessibleNavigation && _arrived)
          Positioned(
            top: buttonTop,
            child: _buildContinueButton(
              width: 181 * scale,
              height: buttonHeight,
              fontSize: math.max(15 * scale, 14).toDouble(),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactLayout({
    required String name,
    required double scale,
    required double frameWidth,
    required double frameHeight,
    required bool accessibleNavigation,
    required bool enlargedText,
  }) {
    final logoHeightFraction = enlargedText ? .18 : .24;
    final logoSize = math
        .min(
          350 * scale,
          math.min(frameWidth * .58, frameHeight * logoHeightFraction),
        )
        .toDouble();
    final buttonWidth = math
        .min(frameWidth - 16, math.max(181 * scale, 120))
        .toDouble();
    final titleFontSize = (25 * scale).clamp(14.0, 25.0).toDouble();
    final successFontSize = (40 * scale).clamp(18.0, 40.0).toDouble();
    final noticeFontSize = (12 * scale).clamp(9.0, 12.0).toDouble();

    final content = Column(
      mainAxisSize: enlargedText ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: enlargedText ? 8 : 0,
      children: [
        Text(
          'É um prazer tê-lo(a) conosco,\n$name.',
          textAlign: TextAlign.center,
          maxLines: enlargedText ? null : 3,
          overflow: enlargedText ? null : TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: VH.headingFontFamily,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: VH.foreground,
          ),
        ),
        _buildLogo(logoSize),
        _buildAnnouncement(successFontSize),
        if (accessibleNavigation)
          Visibility(
            visible: _arrived,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: _buildContinueButton(
              width: buttonWidth,
              height: 48,
              fontSize: math.max(15 * scale, 14).toDouble(),
            ),
          ),
        ExcludeSemantics(
          child: Text(
            _noticeText,
            textAlign: TextAlign.center,
            maxLines: enlargedText ? null : 4,
            overflow: enlargedText ? null : TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: VH.bodyFontFamily,
              fontSize: noticeFontSize,
              height: 1.15,
              color: VH.foreground,
            ),
          ),
        ),
      ],
    );
    const padding = EdgeInsets.all(8);
    if (!enlargedText) {
      return Padding(padding: padding, child: content);
    }
    return SingleChildScrollView(
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: math.max(0.0, frameHeight - padding.vertical),
        ),
        child: content,
      ),
    );
  }

  Widget _buildLogo(double size) {
    final scale = size / 350;
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, .5), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          ),
      child: SizedBox(
        key: const ValueKey('registration-success-logo-frame'),
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 24.37 * scale,
              top: 24.37 * scale,
              width: 300.158 * scale,
              height: 300.158 * scale,
              child: Image.asset(
                'assets/imagens/figma/success-logo-ring.png',
                key: const ValueKey('success-logo-ring'),
                fit: BoxFit.fill,
              ),
            ),
            ClipRRect(
              key: const ValueKey('registration-success-logo-clip'),
              borderRadius: BorderRadius.circular(200 * scale),
              child: Image.asset(
                'assets/imagens/figma/vethomepng-2.png',
                key: const ValueKey('registration-success-logo'),
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncement(double fontSize) => AnimatedOpacity(
    opacity: _arrived ? 1 : 0,
    duration: const Duration(milliseconds: 250),
    child: Semantics(
      key: const ValueKey('registration-success-announcement'),
      label: _arrived
          ? widget.saved
                ? 'Cadastro demonstrativo concluído. Os dados foram salvos neste dispositivo; nenhuma conta on-line foi criada.'
                : 'Cadastro demonstrativo concluído nesta sessão. Os dados não foram salvos neste dispositivo; nenhuma conta on-line foi criada.'
          : null,
      liveRegion: _arrived,
      child: ExcludeSemantics(
        child: Text(
          widget.saved ? 'Usuário\nCadastrado!' : 'Cadastro\nconcluído!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: VH.headingFontFamily,
            fontSize: fontSize,
            height: 1.125,
            fontWeight: FontWeight.bold,
            color: VH.foreground,
          ),
        ),
      ),
    ),
  );

  Widget _buildContinueButton({
    required double width,
    required double height,
    required double fontSize,
  }) => SizedBox(
    key: const ValueKey('registration-success-continue'),
    width: width,
    height: height,
    child: ElevatedButton(
      onPressed: _goToPets,
      style: ElevatedButton.styleFrom(
        backgroundColor: VH.primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        textStyle: TextStyle(
          fontFamily: VH.headingFontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text('Ir para Pets', maxLines: 1, softWrap: false),
      ),
    ),
  );

  String get _noticeText => widget.saved
      ? 'Perfil salvo neste dispositivo. Esta demonstração não cria contas on-line.'
      : 'Dados disponíveis somente nesta sessão. Não foi possível salvar no dispositivo.';
}
