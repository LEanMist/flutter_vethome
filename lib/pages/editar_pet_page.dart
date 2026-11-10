import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import '../core/utils/vet_nav.dart';
import '../core/utils/formatters.dart';
import '../core/utils/pet_images.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../theme/vet_colors.dart';
import '../widgets/pet_form.dart';
import '../widgets/vet/vet_bottom_nav.dart';

class EditarPetPage extends StatelessWidget {
  const EditarPetPage({super.key, required this.pet, this.modal = false});
  final PetModel pet;
  final bool modal;

  Future<void> _navigateFromModal(BuildContext context, int index) async {
    final canLeave = await vetConfirmLeavingForm(
      context,
      title: 'Sair da edição?',
      message:
          'Se você ainda não salvou, as alterações do pet serão descartadas '
          'ao trocar de tela.',
    );
    if (!canLeave || !context.mounted) return;
    vetNavigate(context, index, selected: 0, isTabRoot: false);
  }

  Future<void> _delete(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir pet?'),
        content: Text(
          'Deseja excluir ${pet.name}? As consultas e vacinas salvas para '
          'este pet também serão excluídas deste dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!context.mounted || yes != true) return;
    VetRepository.removePet(pet);
    final saved = await VetRepository.flush();
    if (!context.mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pet removido nesta sessão. Não foi possível salvar localmente.',
          ),
        ),
      );
    }
    Navigator.pop(context, 'deleted');
  }

  @override
  Widget build(BuildContext context) {
    final current = VetRepository.petById(pet.id) ?? pet;
    final form = PetForm(
      title: 'Editar pet',
      pet: current,
      modal: modal,
      onCancel: modal ? () => Navigator.pop(context) : null,
      onDelete: () => _delete(context),
      onSaved: (v) async {
        final age = ageInYears(v.birth, DateTime.now());
        final updated = current.copyWith(
          name: v.name,
          species: v.species,
          sex: v.sex,
          weightKg: v.weight,
          birthDate: v.birth,
          breed: v.breed,
          photoBase64: v.photo,
          neutered: v.neutered,
          imagePath:
              v.species == current.species ||
                  PetImages.hasImage(current.imagePath)
              ? current.imagePath
              : PetImages.forSpecies(v.species) ?? '',
          description: '${v.species} • $age ${age == 1 ? 'ano' : 'anos'}',
        );
        VetRepository.updatePet(current, updated);
        final saved = await VetRepository.flush();
        if (!context.mounted) return;
        if (!saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Dados atualizados nesta sessão. Não foi possível salvar localmente.',
              ),
            ),
          );
        }
        Navigator.pop(context, updated);
      },
    );
    if (modal) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              key: const ValueKey('edit-pet-modal-surface'),
              width: 310,
              height: 480,
              clipBehavior: Clip.antiAlias,
              decoration: inset_shadow.BoxDecoration(
                color: const Color(0xFFFBDCDD),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  inset_shadow.BoxShadow(
                    inset: true,
                    color: VetColors.shadowDark,
                    offset: Offset(2, 2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: form,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Material(
                color: const Color(0xFFFBDCDD),
                shape: const CircleBorder(),
                elevation: 2,
                child: VetRouteMenuButton(
                  key: const ValueKey('pet-edit-modal-route-menu'),
                  onSelected: (index) => _navigateFromModal(context, index),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: VetColors.pink,
      appBar: AppBar(backgroundColor: VetColors.pink, toolbarHeight: 44),
      bottomNavigationBar: VetBottomNav(
        key: const ValueKey('pet-editor-bottom-navigation'),
        selectedIndex: 0,
        compact: MediaQuery.sizeOf(context).width < 900,
        onSelected: (index) async {
          final canLeave = await vetConfirmLeavingForm(
            context,
            title: 'Sair da edição?',
            message:
                'Se você ainda não salvou, as alterações do pet serão '
                'descartadas ao trocar de tela.',
          );
          if (!canLeave || !context.mounted) return;
          vetNavigate(context, index, selected: 0, isTabRoot: false);
        },
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: form,
          ),
        ),
      ),
    );
  }
}
