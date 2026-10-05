import 'package:flutter/material.dart';

import '../../models/pet_model.dart';

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
