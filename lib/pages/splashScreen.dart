// ignore_for_file: file_names

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
    final width = MediaQuery.sizeOf(context).width;
    final logoSize = width >= VH.desktopBreakpoint ? 196.0 : 152.0;
    return Scaffold(
      backgroundColor: VH.background,
      body: Center(
        child: Container(
          width: logoSize,
          height: logoSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: VH.secondary.withValues(alpha: 0.45)),
          ),
          child: Image.asset(
            _logo,
            width: logoSize * .82,
            height: logoSize * .82,
            semanticLabel: 'VetHome',
          ),
        ),
      ),
    );
  }
}
