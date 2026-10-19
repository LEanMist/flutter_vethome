// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../theme.dart';

class SucessoScreen extends StatefulWidget {
  const SucessoScreen({super.key});
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
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/pets', (_) => false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    body: LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.72, 1.0).toDouble();
        final name = VetRepository.clientName.trim().isEmpty
            ? 'usuário'
            : VetRepository.clientName.trim();
        return Center(
          child: SizedBox(
            width: 390 * scale,
            height: (844 * scale).clamp(0, constraints.maxHeight),
            child: Stack(
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
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, .5),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: Container(
                      width: 350 * scale,
                      height: 350 * scale,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, .08),
                            offset: Offset(2, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/imagens/figma/vethomepng-2.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 627 * scale,
                  width: 300 * scale,
                  child: AnimatedOpacity(
                    opacity: _arrived ? 1 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      'Usuário\nCadastrado!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: VH.headingFontFamily,
                        fontSize: 40 * scale,
                        fontWeight: FontWeight.bold,
                        color: VH.foreground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
