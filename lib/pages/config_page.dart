import 'package:flutter/material.dart';

import '../data/theme_preferences.dart';
import '../data/vet_repository.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
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
      (label: 'Suporte', action: () => _showSupport(context)),
      (label: 'Historico', action: () => _showHistory(context)),
      (label: 'Sair', action: () => _signOut(context)),
    ];
    return VHPage(
      tab: '/config',
      children: [
        const VHHeader('Configurações', showBack: false, settingsStyle: true),
        const _LocalSaveNotice(),
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
    const colors = ThemePreferences.options;
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
                  for (final palette in colors)
                    Semantics(
                      button: true,
                      selected: selected == palette.color,
                      label: 'Tema ${palette.name}',
                      child: Tooltip(
                        message: palette.name,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () =>
                              setDialogState(() => selected = palette.color),
                          child: CircleAvatar(
                            radius: selected == palette.color ? 19 : 16,
                            backgroundColor: palette.color,
                            child: selected == palette.color
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
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
    if (color != null) {
      VH.themeSeed.value = color;
      final saved = await ThemePreferences.save(color);
      if (!context.mounted || saved) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Tema aplicado nesta sessão, mas não foi possível salvá-lo.',
            ),
          ),
        );
    }
  }

  void _showSupport(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 349, minHeight: 289),
          child: Container(
            key: const ValueKey('support-figma-surface'),
            width: 349,
            decoration: BoxDecoration(
              color: VetColors.pink,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Suporte',
                    style: TextStyle(
                      fontFamily: VH.bodyFontFamily,
                      fontSize: 40,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                      color: VetColors.brown,
                    ),
                  ),
                  const SizedBox(height: 21),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Número',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ':'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 20,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: VetColors.brown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SelectableText(
                    '11 9793-8918',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 25,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: VetColors.brown,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Email:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 20,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: VetColors.brown,
                    ),
                  ),
                  const SizedBox(height: 13),
                  const SelectableText(
                    'Kelvinpro@gmail.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: VetColors.brown,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

class _LocalSaveNotice extends StatefulWidget {
  const _LocalSaveNotice();

  @override
  State<_LocalSaveNotice> createState() => _LocalSaveNoticeState();
}

class _LocalSaveNoticeState extends State<_LocalSaveNotice> {
  bool _saving = false;

  Future<void> _retry() async {
    if (_saving) return;
    setState(() => _saving = true);
    final saved = await VetRepository.retrySave();
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? 'Alterações salvas no dispositivo.'
                : 'A gravação ainda não foi concluída.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: VetRepository.unsavedChanges,
    builder: (context, pending, _) => pending || _saving
        ? Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Há alterações nesta sessão que ainda não foram salvas no dispositivo.',
                  ),
                  TextButton(
                    onPressed: _saving ? null : _retry,
                    child: Text(
                      _saving ? 'Salvando…' : 'Tentar salvar novamente',
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink(),
  );
}
