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
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bem-vindo!',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              SlideTransition(
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
                child: Image.asset(
                  'assets/imagens/figma/vethomepng-2.png',
                  width: (MediaQuery.sizeOf(context).width - 40).clamp(
                    240.0,
                    350.0,
                  ),
                  height: (MediaQuery.sizeOf(context).width - 40).clamp(
                    240.0,
                    350.0,
                  ),
                ),
              ),
              const SizedBox(height: 27),
              AnimatedOpacity(
                opacity: _arrived ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Text(
                  VetRepository.pets.isEmpty
                      ? 'Você pode cadastrar seu pet quando quiser.'
                      : 'Você e seu pet já podem usar o VetHome.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: VH.headingFontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: VH.foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
