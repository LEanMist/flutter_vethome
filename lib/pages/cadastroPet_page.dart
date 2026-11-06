// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../widgets/pet_form.dart';
import '../theme.dart';

class CadastroPetScreen extends StatelessWidget {
  const CadastroPetScreen({super.key, this.initialData = const {}});
  final Map<String, String> initialData;
  bool _registerClientIfNeeded() {
    if (!initialData.containsKey('client.E-mail')) return false;
    VetRepository.registerClient(initialData);
    return true;
  }

  Future<void> _waitForSave(BuildContext context) async {
    final saved = await VetRepository.flush();
    if (!saved && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Dados atualizados nesta sessão. Não foi possível salvar localmente.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: PetForm(
            title: 'Cadastro Pet',
            onSaved: (v) async {
              final pet = VetRepository.addPet(
                name: v.name,
                species: v.species,
                sex: v.sex,
                weightKg: v.weight,
                birthDate: v.birth,
                breed: v.breed,
                photoBase64: v.photo,
                neutered: v.neutered,
              );
              _registerClientIfNeeded();
              await _waitForSave(context);
              if (!context.mounted) return;
              if (initialData['flow'] == 'addPet') {
                VetRepository.selectedPetId = pet.id;
                Navigator.pop(context, pet);
              } else {
                Navigator.pushNamed(context, '/sucesso');
              }
            },
            onSkip: () async {
              if (_registerClientIfNeeded()) {
                await _waitForSave(context);
                if (!context.mounted) return;
              }
              if (initialData['flow'] == 'addPet') {
                Navigator.pop(context);
              } else {
                Navigator.pushNamed(context, '/sucesso');
              }
            },
          ),
        ),
      ),
    ),
  );
}
