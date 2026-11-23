// ignore_for_file: file_names

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

const _logo = 'assets/imagens/figma/splash-start-logo.png';
const _ring = 'assets/imagens/figma/splash-start-ring.png';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _loginTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.isCurrentOf(context) != true) {
      _loginTimer?.cancel();
      _loginTimer = null;
      return;
    }
    _loginTimer ??= Timer(const Duration(milliseconds: 1500), () {
      if (mounted && ModalRoute.isCurrentOf(context) == true) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _loginTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math.min(
            1.0,
            math.min(constraints.maxWidth / 390, constraints.maxHeight / 844),
          );
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
                                _ring,
                                key: const ValueKey('splash-logo-ring'),
                                fit: BoxFit.fill,
                                excludeFromSemantics: true,
                              ),
                            ),
                            ClipRRect(
                              key: const ValueKey('splash-logo-clip'),
                              borderRadius: BorderRadius.circular(200 * scale),
                              child: Image.asset(
                                _logo,
                                key: const ValueKey('splash-logo'),
                                fit: BoxFit.cover,
                                semanticLabel: 'VetHome',
                              ),
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
