import 'package:flutter/material.dart';

import '../../../models/pet_model.dart';
import '../../../pages/consultas/agenda_page.dart';
import '../../../pages/chat_page.dart';
import '../../../pages/config_page.dart';
import '../../../pages/cliente/perfil_page.dart';
import '../../../pages/pets/pets_page.dart';

class VetRouteMenuButton extends StatelessWidget {
  const VetRouteMenuButton({super.key, required this.onSelected});

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () => onSelected(0),
    );
  }
}

Future<bool> vetConfirmLeavingForm(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Sair'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
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
  PetModel? pet,
  int selected = 0,
  bool isTabRoot = false,
}) {
  if (isTabRoot && index == selected) return;

  final Widget? page = switch (index) {
    0 => const PetsPage(),
    1 => const PerfilPage(),
    2 => const ChatScreen(),
    3 => const AgendaScreen(),
    4 => const ConfigScreen(),
    _ => null,
  };

  if (page == null) {
    vetSoon(context);
    return;
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => page),
    (route) => route.isFirst,
  );
}

void vetSoon(BuildContext context, [String msg = 'Em breve']) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}
