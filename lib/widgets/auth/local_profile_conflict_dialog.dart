import 'package:flutter/material.dart';

Future<void> showLocalProfileConflictDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      key: const ValueKey('local-profile-conflict-dialog'),
      title: const Text('Cadastro não disponível'),
      content: const Text(
        'Esta demonstração salva apenas um perfil neste dispositivo e não '
        'oferece contas separadas. Os dados enviados não correspondem ao '
        'perfil salvo, então não foram gravados para evitar misturar endereço, '
        'pets e consultas. Os dados atuais continuam intactos.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );
}
