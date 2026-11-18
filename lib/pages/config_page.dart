import 'package:flutter/material.dart';


import '../theme.dart';
import '../widgets.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VHPage(
      tab: '/config',
      children: [
        const VHHeader('Configurações', showBack: false),
        VHMenu(
          const [
             'Meus Endereços',
             'Sobre a veterinária',
             'Suporte',
             'Sair',
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/enderecos');
                break;
                case 1:
                Navigator.pushNamed(context, '/sobre');
                break;
              case 2:
                _showSupport(context);
                break;
              case 3:
                _signOut(context);
                break;
           
              
            }
          },
        ),
      ],
    );
  }


  void _showSupport(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VH.background,
        title: const Text('Suporte VetHome'),
        content: const Text(
          'Estamos aqui para ajudar!\n'
          'Telefone: 11 93244-4392\n'
          'E-mail: Gabriela@gmail.com\n'
          'E-mail de suporte do aplicativo: service.vethome@gmail.com'
          ,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
    
  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VH.background,
        title: const Text('Sair do VetHome?'),
        content: const Text('Você poderá entrar novamente quando quiser.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }
}