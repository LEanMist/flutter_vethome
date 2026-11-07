// ignore_for_file: file_names

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

const _logo = 'assets/imagens/figma/vethomepng-2.png';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math
              .min(constraints.maxWidth / 390, constraints.maxHeight / 844)
              .clamp(.5, 1.0)
              .toDouble();
          return Center(
            child: SizedBox(
              key: const ValueKey('splash-figma-frame'),
              width: 390 * scale,
              height: 844 * scale,
              child: ClipRRect(
                key: const ValueKey('splash-figma-clip'),
                borderRadius: BorderRadius.circular(30 * scale),
                child: ColoredBox(
                  key: const ValueKey('splash-figma-surface'),
                  color: VH.background,
                  child: Stack(
                    children: [
                      Positioned(
                        key: const ValueKey('splash-logo-group'),
                        left: 20 * scale,
                        top: 250 * scale,
                        width: 350 * scale,
                        height: 350 * scale,
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
                                key: const ValueKey('splash-logo-ring'),
                                fit: BoxFit.fill,
                              ),
                            ),
                            Image.asset(
                              _logo,
                              key: const ValueKey('splash-logo'),
                              fit: BoxFit.contain,
                              semanticLabel: 'VetHome',
                            ),
                          ],
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
}
