import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

import '../../../data/session.dart';
import '../../../service/endereco_service.dart';
import '../../../models/saved_address.dart';
import '../../../theme/vet_colors.dart';
import '../../../widgets/address_form.dart';
import '../../../widgets/figma_action_target.dart';
import '../../../widgets/pets/pets_theme.dart';
import '../../../widgets/vet/vet_header.dart';
import '../../../widgets/vet/vet_bottom_nav.dart';
import '../../../core/utils/vet_nav.dart';

enum _AddressDeleteFailure { clearing, blocked, unknown }

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  bool _loadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      await EnderecoService.listarEnderecos(cpfCliente: Session.clientCpf);
    } catch (error) {
      if (mounted) _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingAddresses = false);
    }
  }

  static const _saveFailureMessage =
      'Dados atualizados nesta sessão. Não foi possível salvar localmente.';

  static const _labelStyle = TextStyle(
    fontFamily: PetsTheme.fontComfortaa,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: VetColors.brownOnRoseCard,
  );

  static const _valueStyle = TextStyle(
    fontFamily: PetsTheme.fontComfortaa,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    height: 1.67,
    color: VetColors.brownOnRoseCard,
  );

  static const _figmaAddressScrollbarTheme = ScrollbarThemeData(
    thumbColor: WidgetStatePropertyAll<Color?>(VetColors.brown),
    thickness: WidgetStatePropertyAll(3),
    radius: Radius.circular(1.5),
  );

  bool get _usesExpandedText => MediaQuery.textScalerOf(context).scale(15) > 18;

  Future<void> _edit([SavedAddress? address]) async {
    final compactEditor =
        address != null && MediaQuery.sizeOf(context).width < 900;
    final saved = compactEditor
        ? await showDialog<Object?>(
            context: context,
            barrierDismissible: false,
            builder: (_) => AddressEditorPage(address: address, modal: true),
          )
        : await Navigator.pushNamed(
            context,
            '/editar-endereco',
            arguments: address,
          );
    if (!mounted) return;
    setState(() {});
    if (saved == false) {
      _showSaveFailure();
    } else if (saved == _AddressDeleteFailure.clearing) {
      _showDeleteBlocked(clearing: true);
    } else if (saved == _AddressDeleteFailure.blocked) {
      _showDeleteBlocked(clearing: false);
    } else if (saved == _AddressDeleteFailure.unknown) {
      _showDeleteFailure();
    }
  }

  Future<void> _delete(SavedAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir endereço?'),
        content: Text(address.summary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await EnderecoService.excluir(address.id);
        if (mounted) setState(() {});
      } catch (_) {
        if (mounted) _showDeleteFailure();
      }
    }
  }

  void _showSaveFailure() {
    _showMessage(_saveFailureMessage);
  }

  void _showDeleteBlocked({required bool clearing}) {
    _showMessage(
      clearing
          ? 'A exclusão individual foi bloqueada enquanto os dados estavam '
                'sendo limpos.'
          : 'O armazenamento está indisponível. O endereço não foi excluído.',
    );
  }

  void _showDeleteFailure() {
    _showMessage(
      'Não foi possível concluir a exclusão. Confira se o endereço continua '
      'na lista e tente novamente.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final addresses = EnderecoService.addresses;

    return Scaffold(
      extendBody: !desktop,
      backgroundColor: VetColors.pink,
      bottomNavigationBar: SizedBox(
        height: desktop ? 88 : 50,
        child: VetBottomNav(
          key: const ValueKey('addresses-bottom-navigation'),
          selectedIndex: 4,
          compact: !desktop,
          onSelected: (index) =>
              vetNavigate(context, index, selected: 4, isTabRoot: false),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const VetHeader(title: 'Endereços', showBack: false),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final contentWidth = desktop
                        ? constraints.maxWidth.clamp(0.0, 800.0)
                        : constraints.maxWidth;
                    final cardWidth = desktop
                        ? (contentWidth - 18) / 2
                        : (constraints.maxWidth - 70).clamp(0.0, 320.0);
                    final cards = Wrap(
                      alignment: desktop
                          ? WrapAlignment.center
                          : WrapAlignment.start,
                      spacing: 18,
                      runSpacing: 22,
                      children: [
                        for (var index = 0; index < addresses.length; index++)
                          SizedBox(
                            width: cardWidth,
                            child: _addressCard(
                              addresses[index],
                              cardWidth: cardWidth,
                              minimumHeight: desktop || index == 0 ? 173 : 175,
                              desktop: desktop,
                            ),
                          ),
                      ],
                    );
                    final showFigmaScrollbar =
                        !desktop && addresses.length >= 3;

                    return Padding(
                      padding: EdgeInsets.only(right: desktop ? 0 : 20),
                      child: ScrollbarTheme(
                        data: showFigmaScrollbar
                            ? _figmaAddressScrollbarTheme
                            : Theme.of(context).scrollbarTheme,
                        child: Scrollbar(
                          thumbVisibility: showFigmaScrollbar,
                          child: SingleChildScrollView(
                            key: const ValueKey('addresses-list-viewport'),
                            padding: EdgeInsets.fromLTRB(
                              desktop ? 24 : 30,
                              28,
                              desktop ? 24 : 20,
                              16,
                            ),
                            child: Center(
                              key: desktop
                                  ? const ValueKey('addresses-desktop-grid')
                                  : null,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: desktop ? 800 : double.infinity,
                                ),
                                child: _loadingAddresses
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 24),
                                        child: Center(child: CircularProgressIndicator()),
                                      )
                                    : addresses.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 24,
                                        ),
                                        child: Text(
                                          'Nenhum endereço cadastrado',
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : cards,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                key: const ValueKey('addresses-footer'),
                width: double.infinity,
                child: ColoredBox(
                  color: VetColors.pink,
                  child: SafeArea(
                    top: false,
                    bottom: desktop,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        desktop ? 0 : 31,
                        0,
                        desktop ? 43 : 67,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: _usesExpandedText ? null : 161,
                          height: _usesExpandedText ? null : 67,
                          child: ElevatedButton(
                            onPressed: () => _edit(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VetColors.brown,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: VetColors.shadowDark,
                              minimumSize: _usesExpandedText
                                  ? const Size(161, 67)
                                  : null,
                              padding: _usesExpandedText
                                  ? const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    )
                                  : EdgeInsets.zero,
                              shape: const StadiumBorder(),
                              textStyle: const TextStyle(
                                fontFamily: PetsTheme.fontMontserratAlternates,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Novo Endereço'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addressCard(
    SavedAddress address, {
    required double cardWidth,
    required double minimumHeight,
    required bool desktop,
  }) {
    const actionTargetHeight = 48.0;
    const bottomPadding = 11.0;
    final stackActions = _usesExpandedText || cardWidth < 204;
    final stackDetails = _usesExpandedText || cardWidth < 240;
    final matchesMobileFigmaFrame = !desktop && cardWidth >= 320;
    final identity = _addressIdentity(address);
    final actions = [
      _addressAction(
        label: 'Editar',
        background: const Color.fromRGBO(255, 255, 255, .5),
        foreground: VetColors.brown,
        semanticsLabel: 'Editar endereço $identity',
        onPressed: () => _edit(address),
        compact: !stackActions,
      ),
      _addressAction(
        label: 'Deletar',
        background: const Color(0xFF940000),
        foreground: Colors.white,
        semanticsLabel: 'Deletar endereço $identity',
        onPressed: () => _delete(address),
        compact: !stackActions,
      ),
    ];

    const caption = Text('Endereço:', style: _labelStyle);
    final description = Text(_addressLines(address), style: _valueStyle);

    return Container(
      decoration: inset_shadow.BoxDecoration(
        color: VetColors.roseOverlay50,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          inset_shadow.BoxShadow(
            color: VetColors.shadowDark,
            offset: Offset(2, 2),
            blurRadius: 2,
            inset: true,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minimumHeight - actionTargetHeight - bottomPadding,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(19, 11, 19, 8),
              child: stackDetails
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [caption, description],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 107, child: caption),
                        Expanded(child: description),
                      ],
                    ),
            ),
          ),
          if (stackActions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: actions,
              ),
            )
          else
            Padding(
              padding: matchesMobileFigmaFrame
                  ? const EdgeInsets.only(left: 36, right: 37)
                  : EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: matchesMobileFigmaFrame
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.spaceAround,
                children: actions,
              ),
            ),
          const SizedBox(height: bottomPadding),
        ],
      ),
    );
  }

  String _addressLines(SavedAddress address) {
    final secondLine = [
      address.complement,
      address.number,
    ].where((part) => part.trim().isNotEmpty).join(' - ');
    return [
      address.street,
      secondLine,
      address.city,
    ].where((part) => part.trim().isNotEmpty).join('\n');
  }

  String _addressIdentity(SavedAddress address) => [
    address.street.trim(),
    address.number.trim(),
    address.complement.trim(),
  ].where((value) => value.isNotEmpty).join(', ');
  Widget _addressAction({
    required String label,
    required String semanticsLabel,
    required Color background,
    required Color foreground,
    required VoidCallback onPressed,
    required bool compact,
  }) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        minimumSize: compact ? null : const Size(0, 48),
        padding: compact
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: PetsTheme.fontComfortaa,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(label),
    );
    if (!compact) {
      return Semantics(
        button: true,
        enabled: true,
        label: semanticsLabel,
        onTap: onPressed,
        excludeSemantics: true,
        child: button,
      );
    }
    return FigmaActionTarget(
      width: 90,
      label: semanticsLabel,
      onPressed: onPressed,
      child: SizedBox(width: 90, height: 34, child: button),
    );
  }
}

class AddressEditorPage extends StatelessWidget {
  const AddressEditorPage({super.key, this.address, this.modal = false});
  final SavedAddress? address;
  final bool modal;

  Future<void> _navigateFromModal(BuildContext context, int index) async {
    final canLeave = await vetConfirmLeavingForm(
      context,
      title: 'Sair da edição?',
      message:
          'Se você ainda não salvou, as alterações do endereço serão '
          'descartadas ao trocar de tela.',
    );
    if (!canLeave || !context.mounted) return;
    vetNavigate(context, index, selected: 4, isTabRoot: false);
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final compactEditor = address != null && !desktop;
    final mobileNavigationHeight = (50 - MediaQuery.paddingOf(context).bottom)
        .clamp(0.0, 50.0)
        .toDouble();
    final form = AddressForm(
      figmaEditLayout: compactEditor,
      pinSaveAction: address == null && !desktop,
      title: address == null ? 'Novo endereço' : 'Editar endereço',
      initial: address,
      saveErrorMessage: (error) {
        if (error is PersistenceClearingException) {
          return 'O endereço não foi salvo porque os dados locais estão sendo '
              'limpos. Os dados digitados continuam no formulário.';
        }
        if (error is PersistenceBlockedException) {
          return 'O endereço não foi salvo porque o armazenamento local está '
              'bloqueado. Os dados digitados continuam no formulário.';
        }
        return 'Não foi possível confirmar o salvamento. Os dados digitados '
            'continuam no formulário; confira a lista antes de tentar novamente.';
      },
      onSaved: (value) async {
        try {
          await EnderecoService.salvar(value);
          if (context.mounted) Navigator.pop(context, true);
        } catch (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
            );
          }
        }
      },
      routeButton: modal && compactEditor
          ? VetRouteMenuButton(
              key: const ValueKey('address-editor-modal-route-menu'),
              onSelected: (index) => _navigateFromModal(context, index),
            )
          : null,
      onDelete: (value) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir endereço?'),
            content: Text(value.summary),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;
        try {
          await EnderecoService.excluir(value.id);
          if (context.mounted) Navigator.pop(context, null);
        } on PersistenceClearingException {
          if (context.mounted) {
            Navigator.pop(context, _AddressDeleteFailure.clearing);
          }
        } on PersistenceBlockedException {
          if (context.mounted) {
            Navigator.pop(context, _AddressDeleteFailure.blocked);
          }
        } catch (_) {
          if (context.mounted) {
            Navigator.pop(context, _AddressDeleteFailure.unknown);
          }
        }
      },
    );

    if (modal && compactEditor) {
      return Semantics(
        container: true,
        label: 'Editar endereço',
        explicitChildNodes: true,
        child: Dialog(
          key: const ValueKey('address-editor-dialog'),
          insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          child: SingleChildScrollView(
            key: const ValueKey('address-editor-viewport'),
            child: _editorPanel(form),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: VetColors.pink,
      appBar: compactEditor ? null : AppBar(backgroundColor: VetColors.pink),
      bottomNavigationBar: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 88),
        child: VetBottomNav(
          key: const ValueKey('address-editor-bottom-navigation'),
          selectedIndex: 4,
          compact: !desktop,
          onSelected: (index) async {
            final canLeave = await vetConfirmLeavingForm(
              context,
              title: 'Sair da edição?',
              message:
                  'Se você ainda não salvou, as alterações deste formulário '
                  'serão descartadas ao trocar de tela.',
            );
            if (!canLeave || !context.mounted) return;
            vetNavigate(context, index, selected: 4, isTabRoot: false);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: compactEditor ? mobileNavigationHeight : 0,
        ),
        child: SafeArea(
          child: compactEditor
              ? LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    key: const ValueKey('address-editor-viewport'),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(child: _editorPanel(form)),
                    ),
                  ),
                )
              : form,
        ),
      ),
    );
  }

  Widget _editorPanel(Widget form) => Container(
    key: const ValueKey('address-editor-panel'),
    width: 290,
    constraints: const BoxConstraints(minHeight: 546),
    clipBehavior: Clip.antiAlias,
    decoration: inset_shadow.BoxDecoration(
      color: VetColors.pink,
      borderRadius: BorderRadius.circular(30),
      boxShadow: const [
        inset_shadow.BoxShadow(
          color: VetColors.shadowDark,
          offset: Offset(2, 2),
          blurRadius: 5,
          inset: true,
        ),
      ],
    ),
    child: form,
  );
}
