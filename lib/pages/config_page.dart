import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/local_data_manager.dart';
import '../data/local_storage.dart';
import '../data/theme_preferences.dart';
import '../data/vet_repository.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets.dart';
import '../widgets/appointment_card.dart';

class _ThemeColorWheel extends StatelessWidget {
  const _ThemeColorWheel({required this.selectedColor});

  final Color selectedColor;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('theme-color-wheel-frame'),
    width: 264,
    height: 261,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: VetColors.pink,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Stack(
      children: [
        Positioned(
          left: 12,
          top: 12,
          width: 239,
          height: 237,
          child: Image.asset(
            'assets/imagens/figma/image-8.png',
            key: const ValueKey('theme-color-wheel-image'),
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          left: 15,
          top: 14,
          width: 236,
          height: 236,
          child: Container(
            key: const ValueKey('theme-color-wheel-ring'),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: VetColors.rose, width: 5),
            ),
          ),
        ),
        Positioned(
          left: 119,
          top: 118,
          width: 28,
          height: 28,
          child: Container(
            key: const ValueKey('theme-color-wheel-selection'),
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    ),
  );
}

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key, this.clearLocalUserData});

  final Future<bool> Function()? clearLocalUserData;

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
                  trailing: SizedBox(
                    width: 11,
                    height: 19.6299,
                    child: SvgPicture.asset(
                      'assets/imagens/figma/services-chevron-right.svg',
                      key: ValueKey('settings-chevron-$index'),
                      fit: BoxFit.fill,
                    ),
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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 24,
          ),
          contentPadding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
          title: const Text('Tema do Aplicativo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeColorWheel(selectedColor: selected),
              const SizedBox(height: 18),
              Wrap(
                spacing: 0,
                children: [
                  for (final palette in colors)
                    Semantics(
                      key: ValueKey('theme-swatch-target-${palette.name}'),
                      button: true,
                      selected: selected == palette.color,
                      label: 'Tema ${palette.name}',
                      child: Tooltip(
                        message: palette.name,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () =>
                              setDialogState(() => selected = palette.color),
                          child: SizedBox.square(
                            dimension: 48,
                            child: Center(
                              child: CircleAvatar(
                                key: ValueKey(
                                  'theme-swatch-visual-${palette.name}',
                                ),
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
                          text: 'Numero',
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
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Email',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ':'),
                      ],
                    ),
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
    final action = await showDialog<_ExitAction>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VH.background,
        title: const Text('Sair do VetHome?'),
        content: const Text(
          'Sair volta para a tela de login. Os dados salvos continuam neste dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _ExitAction.cancel),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _ExitAction.clearData),
            child: const Text('Apagar dados locais'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _ExitAction.signOut),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (!context.mounted || action == null || action == _ExitAction.cancel) {
      return;
    }
    if (action == _ExitAction.clearData) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: VH.background,
          title: const Text('Apagar os dados deste dispositivo?'),
          content: const Text(
            'Isso remove o perfil salvo, o e-mail lembrado, pets cadastrados, fotos, endereços, consultas e vacinas. Os dados demonstrativos iniciais continuarão disponíveis; a preferência de tema será mantida.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Apagar dados'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      final cleared =
          await (clearLocalUserData?.call() ??
              LocalDataManager.clearUserData());
      if (!context.mounted) return;
      if (!cleared) {
        if (VetRepository.lastPersistenceError
            is LocalStorageConflictException) {
          final hasUnsavedChanges = VetRepository.unsavedChanges.value;
          final reload = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: VH.background,
              title: const Text('Dados atualizados em outra janela'),
              content: Text(
                hasUnsavedChanges
                    ? 'Nenhum dado foi apagado. Para continuar, carregue a versão mais recente. As alterações ainda não salvas nesta janela serão descartadas.'
                    : 'Nenhum dado foi apagado. Carregue a versão mais recente e confirme a exclusão novamente.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Agora não'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Carregar dados atuais'),
                ),
              ],
            ),
          );
          if (!context.mounted || reload != true) return;

          final loaded = await VetRepository.reloadLatestAfterConflict();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  loaded
                      ? 'Dados atuais carregados. Revise e confirme a exclusão novamente.'
                      : 'Não foi possível carregar os dados atuais. Nenhum dado foi apagado.',
                ),
              ),
            );
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Não foi possível confirmar a remoção dos dados. Tente novamente.',
                ),
              ),
            );
        }
        return;
      }
    }

    if (action == _ExitAction.signOut &&
        (VetRepository.unsavedChanges.value ||
            VetRepository.savingChanges.value)) {
      // Espere a gravação pendente antes de concluir a saída.
      await VetRepository.flush();
      if (!context.mounted) return;
      if (VetRepository.unsavedChanges.value) {
        final leaveAnyway = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: VH.background,
            title: const Text('Sair com alterações não salvas?'),
            content: const Text(
              'Há alterações que ainda não foram salvas neste dispositivo. '
              'Elas podem ser perdidas ao sair. Volte para tentar salvar novamente.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Continuar editando'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Sair mesmo assim'),
              ),
            ],
          ),
        );
        if (!context.mounted || leaveAnyway != true) return;
      }
    }

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }
}

enum _ExitAction { cancel, signOut, clearData }

class _LocalSaveNotice extends StatefulWidget {
  const _LocalSaveNotice();

  @override
  State<_LocalSaveNotice> createState() => _LocalSaveNoticeState();
}

class _LocalSaveNoticeState extends State<_LocalSaveNotice> {
  bool _saving = false;
  bool _reloading = false;

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
                : VetRepository.lastPersistenceError
                      is LocalStorageConflictException
                ? 'Outra janela alterou os dados. Carregue a versão atual para continuar.'
                : 'A gravação ainda não foi concluída.',
          ),
        ),
      );
  }

  Future<void> _reloadLatest() async {
    if (_saving) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VH.background,
        title: const Text('Carregar dados atualizados?'),
        content: const Text(
          'As alterações ainda não salvas nesta janela serão descartadas. O VetHome vai carregar os dados salvos pela outra janela.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Carregar dados'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    setState(() {
      _saving = true;
      _reloading = true;
    });
    final loaded = await VetRepository.reloadLatestAfterConflict();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _reloading = false;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            loaded
                ? 'Dados atualizados carregados. As alterações não salvas foram descartadas.'
                : 'Não foi possível carregar os dados atualizados. As alterações desta janela foram mantidas.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: VetRepository.unsavedChanges,
    builder: (context, pending, _) {
      return ValueListenableBuilder<bool>(
        valueListenable: VetRepository.savingChanges,
        builder: (context, saving, _) {
          final isSaving = _saving || saving;
          final conflict =
              VetRepository.lastPersistenceError
                  is LocalStorageConflictException;
          if (!pending && !isSaving) return const SizedBox.shrink();

          return Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSaving
                        ? 'Salvando alterações no dispositivo…'
                        : conflict
                        ? 'Outra janela alterou os dados salvos. Esta sessão não vai sobrescrevê-los; as alterações daqui continuam sem salvar.'
                        : 'Há alterações nesta sessão que ainda não foram salvas no dispositivo.',
                  ),
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : conflict
                        ? _reloadLatest
                        : _retry,
                    child: Text(
                      isSaving
                          ? _reloading
                                ? 'Carregando dados…'
                                : 'Salvando…'
                          : conflict
                          ? 'Carregar dados atualizados'
                          : 'Tentar salvar novamente',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
