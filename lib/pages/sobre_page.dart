import 'package:flutter/material.dart';

import '../widgets.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) => VHPage(
    tab: '/sobre',
    showBottomNav: false,
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
          key: const ValueKey('about-vethome-logo'),
          semanticLabel: 'Logotipo VetHome, Serviços Veterinários',
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
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Sobre mim',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Sou veterinária há mais de 8 anos, apaixonada por cães e gatos. Atendo em domicílio para que seu pet fique tranquilo no lar.',
        ),
        const SizedBox(height: 18),
        ListTile(
          leading: const Icon(Icons.phone_outlined),
          title: SelectableText(
            '11 9793-8918',
            semanticsLabel: 'Telefone fictício para demonstração: 11 9793-8918',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: SelectableText(
            'Kelvinpro@gmail.com',
            semanticsLabel:
                'E-mail fictício para demonstração: Kelvinpro@gmail.com',
          ),
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
