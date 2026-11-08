// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../core/utils/form_fields.dart';
import '../widgets/pet_form.dart';
import '../widgets/auth/local_profile_conflict_dialog.dart';
import '../theme.dart';

class CadastroPetScreen extends StatelessWidget {
  const CadastroPetScreen({super.key, this.initialData = const {}});
  final Map<String, String> initialData;
  bool _registerClientIfNeeded() {
    if (!initialData.containsKey('client.E-mail')) return false;
    VetRepository.registerClient(initialData);
    return true;
  }

  bool get _hasSavedTutor =>
      VetRepository.clientName.trim().isNotEmpty &&
      RegExp(
        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
      ).hasMatch(VetRepository.clientEmail.trim());

  bool get _registrationWasSaved => initialData['_registrationSaved'] == 'true';

  Future<bool> _canContinueRegistration(BuildContext context) async {
    if (initialData['flow'] != 'addPet' &&
        !_hasSavedTutor &&
        !hasCompleteTutorRegistrationData(initialData)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Conclua os dados obrigatórios do tutor antes de avançar.',
            ),
          ),
        );
      return false;
    }
    if (!VetRepository.hasLocalClientIdentityConflict(
      email: initialData['client.E-mail'],
      name: initialData['client.Nome Completo'],
    )) {
      return true;
    }
    await showLocalProfileConflictDialog(context);
    return false;
  }

  Future<bool> _waitForSave(BuildContext context) async {
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
    return saved;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: TextButtonTheme(
            data: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: VH.foreground,
                textStyle: const TextStyle(
                  fontFamily: VH.bodyFontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            child: PetForm(
              title: 'Cadastro Pet',
              onSaved: (v) async {
                final canContinue = await _canContinueRegistration(context);
                if (!canContinue || !context.mounted) return;
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
                final saved = await _waitForSave(context);
                if (!context.mounted) return;
                if (initialData['flow'] == 'addPet') {
                  VetRepository.selectedPetId = pet.id;
                  Navigator.pop(context, pet);
                } else {
                  Navigator.pushNamed(context, '/sucesso', arguments: saved);
                }
              },
              onSkip: () async {
                final canContinue = await _canContinueRegistration(context);
                if (!canContinue || !context.mounted) return;
                var saved = _registrationWasSaved;
                if (_registerClientIfNeeded()) {
                  saved = await _waitForSave(context);
                  if (!context.mounted) return;
                }
                if (initialData['flow'] == 'addPet') {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamed(context, '/sucesso', arguments: saved);
                }
              },
            ),
          ),
        ),
      ),
    ),
  );
}
