import 'package:flutter/material.dart';

import '../../data/vet_repository.dart';
import '../../models/pet_model.dart';
import '../../pages/agendamentos_page.dart';
import '../../pages/perfil_page.dart';
import '../../pages/pets_page.dart';

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

  final PetModel p = pet ?? VetRepository.pets.first;
  final Widget? page = switch (index) {
    0 => const PetsPage(),
    1 => const PerfilPage(),
    3 => AgendamentosPage(pet: p),
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
