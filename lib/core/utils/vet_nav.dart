import 'package:flutter/material.dart';

import '../../models/pet_model.dart';
import '../../pages/perfil_page.dart';
import '../../pages/pets_page.dart';
import '../../screens/outros.dart' show AgendaScreen, ChatScreen, ConfigScreen;

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
