import 'package:flutter/material.dart';

import '../widgets.dart';
import '../widgets/auth/vh_form.dart';

class CadastroScreen extends StatelessWidget {
  const CadastroScreen({super.key});

  @override
  Widget build(BuildContext context) => const VHForm(
    title: 'Cadastro',
    dataPrefix: 'client.',
    next: '/endereco',
    fields: [
      VHField('Nome Completo', Icons.person, value: 'Matheus Santana Lima'),
      VHField('Data de Nascimento', Icons.cake, value: '05/02/2007'),
      VHField(
        'Gênero/Sexo',
        Icons.wc,
        choices: ['Masculino', 'Feminino', 'Outro', 'Prefiro não informar'],
      ),
      VHField('CPF', Icons.badge, value: '534.356.874-94'),
      VHField('Telefone/Celular', Icons.phone, value: '11 94345-3266'),
      VHField('E-mail', Icons.mail, value: 'Kelvin231@gmail.com'),
      VHField('Senha', Icons.lock, password: true),
      VHField('Confirmar Senha', Icons.lock, password: true),
    ],
  );
}
