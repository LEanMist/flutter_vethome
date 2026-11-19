import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;

import '../models/saved_address.dart';
import '../theme/vet_colors.dart';

class AppointmentAddressDialog extends StatefulWidget {
  const AppointmentAddressDialog({
    super.key,
    required this.addresses,
    required this.selectedId,
  });

  final List<SavedAddress> addresses;
  final String? selectedId;

  @override
  State<AppointmentAddressDialog> createState() =>
      _AppointmentAddressDialogState();
}

class _AppointmentAddressDialogState extends State<AppointmentAddressDialog> {
  final _scrollController = ScrollController();
  SavedAddress? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.addresses
        .where((address) => address.id == widget.selectedId)
        .firstOrNull;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.addresses.isEmpty;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: VetColors.pink,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        namesRoute: true,
        label: 'Escolher endereço da consulta',
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            key: const ValueKey('appointment-address-dialog'),
            width: math.min(390, constraints.maxWidth),
            height: math.min(isEmpty ? 224 : 446, constraints.maxHeight),
            child: Column(
              children: [
                Expanded(
                  child: isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Nenhum endereço cadastrado. Você pode adicionar '
                              'um em Configurações > Endereços.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: VetColors.brown),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(18, 17, 20, 0),
                          child: RawScrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            thumbColor: VetColors.brown,
                            thickness: 3,
                            radius: const Radius.circular(2),
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(right: 26),
                              itemCount: widget.addresses.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 19),
                              itemBuilder: (context, index) {
                                final address = widget.addresses[index];
                                return _AddressOption(
                                  address: address,
                                  selected: address.id == _selected?.id,
                                  onTap: () =>
                                      setState(() => _selected = address),
                                );
                              },
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 23),
                  child: ElevatedButton(
                    onPressed: _selected != null || isEmpty
                        ? () => Navigator.pop(context, _selected)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VetColors.brown,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(91, 46),
                      visualDensity: VisualDensity.standard,
                      tapTargetSize: MaterialTapTargetSize.padded,
                      textStyle: const TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('OK'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressOption extends StatelessWidget {
  const _AddressOption({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final SavedAddress address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = address.name.trim();
    final street = [
      address.street,
      address.number,
    ].where((part) => part.trim().isNotEmpty).join(', ');
    final lines = [
      street,
      address.complement,
      [
        address.city,
        address.cep,
      ].where((part) => part.trim().isNotEmpty).join(' · '),
    ].where((part) => part.trim().isNotEmpty);
    final largeText = MediaQuery.textScalerOf(context).scale(18) > 24;
    const radius = BorderRadius.all(Radius.circular(25));
    const rowStyle = TextStyle(
      color: VetColors.brown,
      fontFamily: 'Comfortaa',
      fontWeight: FontWeight.bold,
    );
    const titleStyle = TextStyle(fontSize: 18, height: 1.25);
    final mark = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: VetColors.brown, width: 1.5),
        color: selected ? VetColors.brown : Colors.transparent,
      ),
      child: selected
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
    );
    final addressText = Text(lines.join('\n'));
    return Semantics(
      key: ValueKey('appointment-address-option-${address.id}'),
      checked: selected,
      inMutuallyExclusiveGroup: true,
      label: [if (name.isNotEmpty) name, address.summary].join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Ink(
          decoration: const inset.BoxDecoration(
            color: VetColors.roseOverlay50,
            borderRadius: radius,
            boxShadow: [
              inset.BoxShadow(
                color: Color(0x40000000),
                offset: Offset(2, 2),
                blurRadius: 2,
                inset: true,
              ),
            ],
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            focusColor: VetColors.brown.withValues(alpha: .22),
            child: Container(
              constraints: const BoxConstraints(minHeight: 121),
              padding: const EdgeInsets.fromLTRB(17, 13, 17, 15),
              child: DefaultTextStyle(
                style: rowStyle.copyWith(fontSize: 12, height: 1.55),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name.isNotEmpty) ...[
                      if (largeText) ...[
                        const Text('Nome:', style: titleStyle),
                        Text(name),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 119,
                              child: Text('Nome:', style: titleStyle),
                            ),
                            Expanded(child: Text(name)),
                          ],
                        ),
                      const SizedBox(height: 6),
                    ],
                    if (largeText) ...[
                      const Text('Endereço:', style: titleStyle),
                      addressText,
                      const SizedBox(height: 10),
                      mark,
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 119,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Endereço:', style: titleStyle),
                                const SizedBox(height: 13),
                                mark,
                              ],
                            ),
                          ),
                          Expanded(child: addressText),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
