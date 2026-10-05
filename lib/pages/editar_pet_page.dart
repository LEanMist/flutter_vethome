import 'package:flutter/material.dart';
import '../core/utils/pet_images.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../theme/vet_colors.dart';
import '../widgets/pet_form.dart';

class EditarPetPage extends StatelessWidget {
  const EditarPetPage({super.key, required this.pet, this.modal = false});
  final PetModel pet;
  final bool modal;
  Future<void> _delete(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir pet?'),
        content: Text('Deseja excluir ${pet.name} da sua lista?'),
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
        final updated = current.copyWith(
          name: v.name,
          species: v.species,
          sex: v.sex,
          weightKg: v.weight,
          birthDate: v.birth,
          breed: v.breed,
          photoBase64: v.photo,
          imagePath:
              v.species == current.species ||
                  PetImages.hasImage(current.imagePath)
              ? current.imagePath
              : PetImages.forSpecies(v.species) ?? '',
          description:
              '${v.species} • ${DateTime.now().year - v.birth.year} anos',
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
        backgroundColor: VetColors.pink,
        insetPadding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 390,
            maxHeight: MediaQuery.sizeOf(context).height - 24,
          ),
          child: form,
        ),
      );
    }
    return Scaffold(
      backgroundColor: VetColors.pink,
      appBar: AppBar(backgroundColor: VetColors.pink, toolbarHeight: 44),
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
