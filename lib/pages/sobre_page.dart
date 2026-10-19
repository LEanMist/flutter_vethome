import 'package:flutter/material.dart';

import '../widgets.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) => VHPage(
    tab: '/sobre',
    children: [
      const VHHeader('Sobre a veterinária'),
      Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final identity = _identity();
            final details = _details();
            return constraints.maxWidth >= 900
                ? Row(
                    key: const ValueKey('about-desktop-layout'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: identity),
                      const SizedBox(width: 28),
                      Expanded(child: details),
                    ],
                  )
                : Column(
                    children: [identity, const SizedBox(height: 18), details],
                  );
          },
        ),
      ),
    ],
  );

  Widget _identity() => _card(
    Column(
      children: [
        Image.asset(
          'assets/imagens/figma/vethomepng-2.png',
          width: 140,
          height: 140,
        ),
        const Text(
          'Gabriella',
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _details() => _card(
    const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sobre mim',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 12),
        Text(
          'Sou veterinária há mais de 8 anos, apaixonada por cães e gatos. Atendo em domicílio para que seu pet fique tranquilo no lar.',
        ),
        SizedBox(height: 18),
        ListTile(
          leading: Icon(Icons.phone_outlined),
          title: SelectableText('11 93244-4392'),
        ),
        ListTile(
          leading: Icon(Icons.email_outlined),
          title: SelectableText('Gabriela@gmail.com'),
        ),
      ],
    ),
  );

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0x33C08081),
      borderRadius: BorderRadius.circular(24),
    ),
    child: child,
  );
}
