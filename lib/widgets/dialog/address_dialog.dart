import 'package:flutter/material.dart';

import '../../theme.dart';

class AddressDialog extends StatefulWidget {
  const AddressDialog({super.key, required this.initialAddress});

  final String initialAddress;

  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  late final _controller = TextEditingController(text: widget.initialAddress);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: VH.background,
        title: const Text('Meus Endereços'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Endereço',
            hintText: 'Rua, número, cidade e CEP',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      );
}