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
        child: Column(
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
            const SizedBox(height: 24),
            const Text(
              'Sobre mim',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sou veterinária há mais de 8 anos, apaixonada por cães e gatos. Atendo em domicílio para que seu pet fique tranquilo no lar.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const ListTile(
              leading: Icon(Icons.phone_outlined),
              title: Text('11 93244-4392'),
            ),
            const ListTile(
              leading: Icon(Icons.email_outlined),
              title: Text('Gabriela@gmail.com'),
            ),
          ],
        ),
      ),
    ],
  );
}
