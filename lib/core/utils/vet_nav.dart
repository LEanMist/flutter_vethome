import 'package:flutter/material.dart';

class VetRouteMenuButton extends StatelessWidget {
  const VetRouteMenuButton({super.key, required this.onSelected});

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
    tooltip: 'Trocar de tela',
    padding: EdgeInsets.zero,
    icon: const Icon(Icons.apps_rounded),
    onSelected: onSelected,
    itemBuilder: (context) => const [
      PopupMenuItem(value: 0, child: Text('Pets')),
      PopupMenuItem(value: 1, child: Text('Perfil')),
      PopupMenuItem(value: 2, child: Text('Conversa')),
      PopupMenuItem(value: 3, child: Text('Agenda')),
      PopupMenuItem(value: 4, child: Text('Configurações')),
    ],
  );
}

Future<bool> vetConfirmLeavingForm(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final shouldLeave = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Continuar editando'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Sair sem salvar'),
        ),
      ],
    ),
  );
  return context.mounted && shouldLeave == true;
}

/// Barra inferior (igual ao Figma):
/// 0 Pets · 1 Perfil · 2 WhatsApp · 3 Agenda · 4 Configurações
///
/// Troca de aba SUBSTITUI a pilha (não empilha telas a cada toque).
/// Ajuste o `(route) => route.isFirst` se a rota-base do app for outra
/// (ex.: a tela de menu).
void vetNavigate(
  BuildContext context,
  int index, {
  int selected = 0,
  bool isTabRoot = false,
  DateTime? initialDate,
}) {
  if (isTabRoot && index == selected) return;

  final String? routeName = switch (index) {
    0 => '/pets',
    1 => '/perfil',
    2 => '/chat',
    3 => '/agenda',
    4 => '/config',
    _ => null,
  };

  if (routeName == null) {
    vetSoon(context);
    return;
  }

  Navigator.pushNamedAndRemoveUntil(
    context,
    routeName,
    (route) => route.isFirst,
    arguments: index == 3 ? initialDate : null,
  );
}

void vetSoon(BuildContext context, [String msg = 'Em breve']) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}
