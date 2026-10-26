import 'package:flutter/material.dart';

import '../service/utils/formatters.dart';
import '../data/vet_repository.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/dialog/address_dialog.dart';

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
            'Tema do Aplicativo',
            'Meus Endereços',
            'Suporte',
            'Histórico',
            'Sair',
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                _chooseTheme(context);
                break;
              case 1:
                _editAddress(context);
                break;
              case 2:
                _showSupport(context);
                break;
              case 3:
                _showHistory(context);
                break;
              case 4:
                _signOut(context);
                break;
            }
          },
        ),
      ],
    );
  }

  Future<void> _chooseTheme(BuildContext context) async {
    const colors = [
      Color(0xFF68442E),
      Color(0xFFC08081),
      Color(0xFF718B70),
      Color(0xFF6B8FA3),
      Color(0xFF9477A8),
    ];
    var selected = VH.themeSeed.value;
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VH.background,
          title: const Text('Tema do Aplicativo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 132,
                height: 132,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/imagens/figma/image-8.png',
                      width: 132,
                      height: 132,
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: selected,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                children: [
                  for (final color in colors)
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => setDialogState(() => selected = color),
                      child: CircleAvatar(
                        radius: selected == color ? 19 : 16,
                        backgroundColor: color,
                        child: selected == color
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selected),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
    if (color != null) VH.themeSeed.value = color;
  }

  Future<void> _editAddress(BuildContext context) async {
    final address = await showDialog<String>(
      context: context,
      builder: (_) =>
          AddressDialog(initialAddress: VetRepository.clientAddress),
    );
    if (address != null) {
      VetRepository.updateClient(address: address);
    }
  }

  void _showSupport(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VH.background,
        title: const Text('Suporte VetHome'),
        content: const Text(
          'Estamos aqui para ajudar.\n'
          'Telefone: 11 93244-4392\n'
          'E-mail: Gabriela@gmail.com',
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

  void _showHistory(BuildContext context) {
    final appointments = [
      for (final pet in VetRepository.pets)
        for (final appointment in VetRepository.agendamentos(pet.name))
          (pet: pet, appointment: appointment),
    ]..sort((a, b) => b.appointment.data.compareTo(a.appointment.data));

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VH.background,
        title: const Text('Histórico'),
        content: SizedBox(
          width: 320,
          child: appointments.isEmpty
              ? const Text('Nenhuma consulta registrada.')
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final item in appointments)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.appointment.tipo),
                        subtitle: Text(
                          '${item.pet.name} · ${fmtData(item.appointment.data)}',
                        ),
                        trailing: Text(fmtHora(item.appointment.data)),
                      ),
                  ],
                ),
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