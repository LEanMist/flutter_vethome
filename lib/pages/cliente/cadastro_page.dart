import 'package:flutter/material.dart';

import '../../widgets.dart';
import '../../widgets/auth/vh_form.dart';

enum CadastroEntry { fromAddress, fromPet }

class CadastroScreen extends StatelessWidget {
  const CadastroScreen({super.key, this.entry});

  final CadastroEntry? entry;

  @override
  Widget build(BuildContext context) => MediaQuery.removePadding(
    context: context,
    removeTop: true,
    child: VHForm(
      title: 'Cadastro',
      dataPrefix: 'client.',
      next: '/endereco',
      guidance: switch (entry) {
        CadastroEntry.fromAddress =>
          'Preencha os dados do tutor. Depois, você pode pular o endereço.',
        CadastroEntry.fromPet =>
          'Preencha os dados do tutor. Depois, você pode cadastrar ou pular o pet.',
        null => null,
      },
      fields: const [
        VHField('Nome Completo', Icons.person, value: 'Matheus Santana Lima'),
        VHField('Data de Nascimento', Icons.cake, value: '05 / 02 / 2007'),
        VHField(
          'CPF',
          Icons.account_balance_wallet_outlined,
          value: '534.356.874 - 94',
        ),
        VHField('Telefone/Celular', Icons.phone, value: '11 94345-3266'),
        VHField('E-mail', Icons.mail, value: 'Kelvin231@gmail.com'),
        VHField('Senha', Icons.lock_open_outlined, password: true),
        VHField('Confirmar Senha', Icons.lock, password: true),
      ],
    ),
  );
}
