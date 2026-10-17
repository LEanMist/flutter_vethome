import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/appointment_card.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <({String label, VoidCallback action})>[
      (label: 'Tema do Aplicativo', action: () => _chooseTheme(context)),
      (
        label: 'Meus Endereços',
        action: () => Navigator.pushNamed(context, '/enderecos'),
      ),
      (
        label: 'Sobre a veterinária',
        action: () => Navigator.pushNamed(context, '/sobre'),
      ),
      (label: 'Suporte', action: () => _showSupport(context)),
      (label: 'Histórico', action: () => _showHistory(context)),
      (label: 'Sair', action: () => _signOut(context)),
    ];
    return VHPage(
      tab: '/config',
      children: [
        const VHHeader('Configurações', showBack: false, settingsStyle: true),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 26, 12, 24),
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  minTileHeight: index == 0 ? 57 : 58,
                  title: Text(
                    items[index].label,
                    style: const TextStyle(
                      fontFamily: VH.headingFontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: VH.foreground,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: VH.foreground,
                  ),
                  onTap: items[index].action,
                ),
                if (index < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: VH.foreground.withValues(alpha: .25),
                  ),
              ],
            ],
          ),
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
    final events = [
      for (final pet in VetRepository.pets)
        for (final a in VetRepository.realAppointments(pet.id))
          (pet: pet, event: a),
    ]..sort((a, b) => a.event.data.compareTo(b.event.data));
    final future =
        events.where((e) => e.event.data.isAfter(DateTime.now())).toList()
          ..sort((a, b) => a.event.data.compareTo(b.event.data));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: VH.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * .85,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Histórico',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      if (future.isEmpty) ...[
                        const Text(
                          'Próximo agendamento',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Nenhum agendamento futuro'),
                        ),
                      ] else
                        AppointmentCard(
                          pet: future.first.pet,
                          event: future.first.event,
                          next: true,
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.pushNamed(
                              context,
                              '/agenda',
                              arguments: future.first.event.data,
                            );
                          },
                        ),
                      const Divider(height: 24),
                      const Text(
                        'Histórico de agendamentos',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (events.isEmpty)
                        const Text('Nenhuma consulta registrada.'),
                      for (final item in events)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              AppointmentCard(pet: item.pet, event: item.event),
                              const Divider(height: 8, thickness: .5),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        ),
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
