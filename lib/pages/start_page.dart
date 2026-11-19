import 'package:flutter/material.dart';

import '../theme.dart';
import 'landing_page.dart';
import 'splashScreen.dart';

/// Mostra a landing do Figma em telas largas e conserva o início móvel atual.
class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth >= VH.desktopBreakpoint
          ? const LandingPage()
          : const SplashScreen(),
    );
  }
}
