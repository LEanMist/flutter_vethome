import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VHPage(
      tab: '/chat',
      children: [
        const VHHeader('Sobre a veterinária'),
        const VHBadge('vet-badge', 'Gabriella'),
        Container(
          margin: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          padding: const EdgeInsets.all(20),
          decoration: insetBox(color: VH.muted),
          child: const Column(
            children: [
              Text(
                'Sobre Mim',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Sou veterinária há mais de 8 anos, apaixonada por cães e gatos. Atendo em domicílio para que seu pet fique tranquilo no lar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              // SizedBox(height: 16),
              // Text('CONTATO:', style: TextStyle(fontWeight: FontWeight.bold)),
              // Text(
              //   '11 93244-4392',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(fontSize: 13),
              // ),
              SizedBox(height: 8),
              Text(
                'Gabriela@gmail.com',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}