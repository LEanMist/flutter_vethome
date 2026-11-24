// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../../core/utils/vet_nav.dart';
import '../../../data/vet_repository.dart';
import '../../../core/utils/form_fields.dart';
import '../../../widgets/pet_form.dart';
import '../../../widgets/auth/local_profile_conflict_dialog.dart';
import '../../../theme.dart';
import '../../../widgets/vet/vet_bottom_nav.dart';
import '../cadastro_page.dart';
import '../../../data/session.dart';
import '../../../service/pet_service.dart';

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

  Future<bool> _canContinueRegistration(BuildContext context) async {
    if (ModalRoute.isCurrentOf(context) == false) return false;
    if (initialData['flow'] != 'addPet' &&
        !_hasSavedTutor &&
        !hasCompleteTutorRegistrationData(initialData)) {
      Navigator.pushReplacementNamed(
        context,
        '/cadastro',
        arguments: CadastroEntry.fromPet,
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

  EdgeInsets _registrationInsets(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final useReferenceSpacing =
        initialData['flow'] != 'addPet' &&
        size.width >= 322 &&
        size.width < 600 &&
        size.height >= 800 &&
        MediaQuery.textScalerOf(context).scale(14) <= 15.4;
    // O quadro de referência inclui 24 px acima do conteúdo.
    // SafeArea desconta a barra de status quando ela está presente.
    return useReferenceSpacing
        ? const EdgeInsets.only(top: 24)
        : EdgeInsets.zero;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    bottomNavigationBar: initialData['flow'] == 'addPet'
        ? SafeArea(
            top: false,
            child: VetBottomNav(
              selectedIndex: 0,
              compact: MediaQuery.sizeOf(context).width < VH.desktopBreakpoint,
              onSelected: (index) async {
                final canLeave = await vetConfirmLeavingForm(
                  context,
                  title: 'Sair do cadastro?',
                  message:
                      'Se ainda não salvou, os dados deste pet serão '
                      'descartados ao trocar de tela.',
                );
                if (!canLeave || !context.mounted) return;
                if (index == 0 && Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                  return;
                }
                vetNavigate(context, index, selected: 0, isTabRoot: false);
              },
            ),
          )
        : null,
    body: SafeArea(
      minimum: _registrationInsets(context),
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
                final cpf = Session.clientCpf.replaceAll(RegExp(r'\D'), '');
                if (cpf.isNotEmpty) {
                  try {
                    await PetService.cadastrarPet({
                      'nome': v.name,
                      'especie': v.species,
                      'sexo': v.sex,
                      'peso': v.weight.toString(),
                      'dataNasc': '${v.birth.day.toString().padLeft(2, '0')}/${v.birth.month.toString().padLeft(2, '0')}/${v.birth.year}',
                      'raca': v.breed,
                      'cpfCliente': cpf,
                    });
                    final pets = await PetService.listarPets(cpfCliente: cpf);
                    VetRepository.pets
                      ..clear()
                      ..addAll(pets);
                    final pet = pets.firstWhere(
                      (item) => item.name.toLowerCase() == v.name.trim().toLowerCase(),
                      orElse: () => throw Exception(
                        'O pet foi salvo, mas não apareceu na listagem. Atualize a tela.',
                      ),
                    );
                    _registerClientIfNeeded();
                    if (!context.mounted || ModalRoute.isCurrentOf(context) == false) return;
                    if (initialData['flow'] == 'addPet') {
                      VetRepository.selectedPetId = pet.id;
                      Navigator.pop(context, pet);
                    } else {
                      Navigator.pushNamed(context, '/sucesso', arguments: true);
                    }
                    return;
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Não foi possível cadastrar o pet: $error')),
                      );
                    }
                    return;
                  }
                }
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
                if (!context.mounted ||
                    ModalRoute.isCurrentOf(context) == false) {
                  return;
                }
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
                if (initialData['flow'] == 'addPet') {
                  Navigator.pop(context);
                  return;
                }
                final statusFromAddress = initialData['_registrationSaved'];
                final saved =
                    _registerClientIfNeeded() || statusFromAddress == null
                    ? await _waitForSave(context)
                    : statusFromAddress == 'true';
                if (!context.mounted ||
                    ModalRoute.isCurrentOf(context) == false) {
                  return;
                }
                Navigator.pushNamed(context, '/sucesso', arguments: saved);
              },
            ),
          ),
        ),
      ),
    ),
  );
}
