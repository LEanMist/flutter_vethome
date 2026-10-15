import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../theme.dart';
import '../widgets.dart';

class SucessoScreen extends StatelessWidget {
  const SucessoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'É um prazer tê-lo(a) conosco, senhor(a) '
                  '${VetRepository.clientName}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'MontserratAlternates',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.asset(
                    'assets/imagens/figma/vethomepng-1.png',
                    width: 226,
                    height: 226,
                    fit: BoxFit.contain,
                  ),
                ),
                const Text(
                  'Usuário e Pets Cadastrados!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Comfortaa',
                  ),
                ),
                const SizedBox(height: 28),
                PillButton(
                  label: 'Continuar',
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/pets',
                    (_) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
