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
      body: Center(
        child: Container(
          width: 136,
          height: 136,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: VH.secondary.withValues(alpha: 0.45)),
          ),
          child: Image.asset(_logo, width: 108, height: 108),
        ),
      ),
    );
  }
}
