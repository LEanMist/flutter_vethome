import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

import '../data/vet_repository.dart';
import '../models/saved_address.dart';
import '../theme/vet_colors.dart';
import '../widgets/address_form.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet/vet_header.dart';
import '../widgets/vet/vet_bottom_nav.dart';
import '../core/utils/vet_nav.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  static const _saveFailureMessage =
      'Dados atualizados nesta sessão. Não foi possível salvar localmente.';

  static const _labelStyle = TextStyle(
    fontFamily: PetsTheme.fontComfortaa,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: VetColors.brown,
  );

  static const _valueStyle = TextStyle(
    fontFamily: PetsTheme.fontComfortaa,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    height: 1.67,
    color: VetColors.brownOnRoseCard,
  );

  Future<void> _edit([SavedAddress? address]) async {
    final saved = await Navigator.pushNamed(
      context,
      '/editar-endereco',
      arguments: address,
    );
    if (!mounted) return;
    setState(() {});
    if (saved == false) _showSaveFailure();
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
      setState(() => VetRepository.removeAddress(address.id));
      final saved = await VetRepository.flush();
      if (!saved && mounted) _showSaveFailure();
    }
  }

  void _showSaveFailure() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(_saveFailureMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final addresses = VetRepository.addresses;

    return Scaffold(
      extendBody: !desktop,
      backgroundColor: VetColors.pink,
      bottomNavigationBar: desktop
          ? null
          : VetBottomNav(
              key: const ValueKey('addresses-bottom-navigation'),
              selectedIndex: 4,
              compact: true,
              onSelected: (index) =>
                  vetNavigate(context, index, selected: 4, isTabRoot: false),
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const VetHeader(
                title: 'Endereços',
                showBack: false,
                showDebugTools: false,
              ),
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
                            height: desktop || index == 0 ? 173 : 175,
                            child: _addressCard(addresses[index]),
                          ),
                      ],
                    );

                    return Padding(
                      padding: EdgeInsets.only(right: desktop ? 0 : 20),
                      child: Scrollbar(
                        thumbVisibility: !desktop && addresses.length >= 3,
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
                              child: addresses.isEmpty
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
                          width: 161,
                          height: 67,
                          child: ElevatedButton(
                            onPressed: () => _edit(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VetColors.brown,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: VetColors.shadowDark,
                              padding: EdgeInsets.zero,
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

  Widget _addressCard(SavedAddress address) => Container(
    height: 173,
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
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(19, 11, 19, 0),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 107,
                    child: Text('Nome:', style: _labelStyle),
                  ),
                  Expanded(
                    child: Text(
                      address.name.isEmpty ? '—' : address.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _valueStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 107,
                    child: Text('Endereço:', style: _labelStyle),
                  ),
                  Expanded(
                    child: Text(
                      _addressLines(address),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: _valueStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        LayoutBuilder(
          builder: (context, constraints) {
            final matchesMobileFigmaFrame =
                MediaQuery.sizeOf(context).width < 900 &&
                constraints.maxWidth >= 320;
            return Padding(
              padding: matchesMobileFigmaFrame
                  ? const EdgeInsets.only(left: 36, right: 37)
                  : EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: matchesMobileFigmaFrame
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.spaceAround,
                children: [
                  _addressAction(
                    label: 'Editar',
                    background: const Color.fromRGBO(255, 255, 255, .5),
                    foreground: VetColors.brown,
                    onPressed: () => _edit(address),
                  ),
                  _addressAction(
                    label: 'Deletar',
                    background: const Color(0xFF940000),
                    foreground: Colors.white,
                    onPressed: () => _delete(address),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 11),
      ],
    ),
  );

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

  Widget _addressAction({
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onPressed,
  }) => SizedBox(
    width: 90,
    height: 34,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: const StadiumBorder(),
        textStyle: TextStyle(
          fontFamily: PetsTheme.fontComfortaa,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(label),
    ),
  );
}

class AddressEditorPage extends StatelessWidget {
  const AddressEditorPage({super.key, this.address});
  final SavedAddress? address;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VetColors.pink,
    appBar: AppBar(backgroundColor: VetColors.pink),
    body: SafeArea(
      child: AddressForm(
        title: address == null ? 'Novo endereço' : 'Editar endereço',
        initial: address,
        onSaved: (value) async {
          VetRepository.saveAddress(value);
          final saved = await VetRepository.flush();
          if (context.mounted) Navigator.pop(context, saved);
        },
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
          VetRepository.removeAddress(value.id);
          final saved = await VetRepository.flush();
          if (context.mounted) Navigator.pop(context, saved ? null : false);
        },
      ),
    ),
  );
}
