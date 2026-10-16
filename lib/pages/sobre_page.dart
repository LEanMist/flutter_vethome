import 'package:flutter/material.dart';

<<<<<<< HEAD
import '../theme.dart';
import '../widgets.dart';
import '../widgets/demo_badge.dart';
=======
import '../widgets.dart';
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) {
    return VHPage(
      tab: '/chat',
      children: [
        const VHHeader('Sobre a veterinária'),
        const DemoBadge(label: 'Gabriella'),
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
              SizedBox(height: 16),
              Text('CONTATO:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '11 93244-4392',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
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
=======
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
>>>>>>> a658fe7b8454f46a55c393dcb650b45f2aa58185
