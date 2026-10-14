import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../service/cliente_service.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/auth/vh_form.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreen();
}
class _CadastroScreen extends State<CadastroScreen> {
  bool _carregando = false;

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: Stack(
        children: [
          VHForm(
            title: 'Cadastro',
            next: '/endereco',
            fields: const [
              VHField('Nome Completo', Icons.person, value: 'Matheus Santana Lima'),
              VHField('Data de Nascimento', Icons.cake, value: '05/02/2007'),
              VHField('Gênero/Sexo', Icons.person_outline, value: 'Masculino'),
              VHField('CPF', Icons.badge, value: '534.356.874-94'),
              VHField('Telefone/Celular', Icons.phone, value: '11 94345-3266'),
              VHField('E-mail', Icons.mail, value: 'Kelvin231@gmail.com'),
              VHField('Senha', Icons.lock, password: true),
              VHField('Confirmar Senha', Icons.lock, password: true),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _cadastrar() async {
    setState(() => _carregando = true);

    try {
      await ClienteService.cadastrarCliente({
        'Nome Completo': 'Matheus Santana Lima',
        'Data de Nascimento': '05/02/2007',
        'CPF': '534.356.874-94',
        'Telefone/Celular': '11 94345-3266',
        'E-mail': 'Kelvin231@gmail.com',
        'Senha': '123456',
      
      });

      Navigator.pushNamed(context, '/sucesso');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha: $e')),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }
}
